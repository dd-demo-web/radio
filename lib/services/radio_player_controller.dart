import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track_metadata.dart';
import 'radio_api_service.dart';
import 'radio_config.dart';

/// Stato riproduzione radio in diretta.
enum RadioPlaybackStatus { idle, loading, playing, paused, error }

/// Controller che gestisce lo stream audio live e il polling dei metadata
/// del brano attualmente in onda.
class RadioPlayerController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RadioApiService _apiService;

  RadioPlaybackStatus status = RadioPlaybackStatus.idle;
  TrackMetadata currentTrack = TrackMetadata.empty();
  String? errorMessage;

  /// True quando il browser ha bloccato l'autoplay (richiede un tap
  /// dell'utente prima di poter avviare l'audio, es. su web).
  bool autoplayBlocked = false;

  Timer? _metadataTimer;
  StreamSubscription<PlayerState>? _playerStateSub;

  RadioPlayerController({RadioApiService? apiService})
    : _apiService = apiService ?? RadioApiService() {
    _playerStateSub = _audioPlayer.playerStateStream.listen(_onPlayerState);
  }

  bool get isPlaying => status == RadioPlaybackStatus.playing;

  /// Carica lo stream, prova l'autoplay e avvia comunque il polling dei
  /// metadata (indipendente dall'esito dell'autoplay: se il browser lo
  /// blocca, titolo/artista/copertina restano comunque aggiornati).
  Future<void> init() async {
    status = RadioPlaybackStatus.loading;
    notifyListeners();

    // Il polling dei metadata non dipende dalla riproduzione audio: lo
    // avviamo subito così titolo/artista/copertina sono sempre disponibili.
    _startMetadataPolling();

    try {
      await _audioPlayer.setUrl(RadioConfig.streamUrl);
      await _audioPlayer.play();
    } catch (e) {
      final message = e.toString();
      if (message.contains('NotAllowedError') ||
          message.contains('play() failed')) {
        // Autoplay bloccato dal browser: l'utente deve avviare manualmente.
        autoplayBlocked = true;
        status = RadioPlaybackStatus.paused;
      } else {
        status = RadioPlaybackStatus.error;
        errorMessage = 'Impossibile avviare lo stream: $e';
      }
      notifyListeners();
    }
  }

  void _onPlayerState(PlayerState state) {
    if (state.playing) {
      autoplayBlocked = false;
      status = RadioPlaybackStatus.playing;
    } else if (status != RadioPlaybackStatus.error &&
        status != RadioPlaybackStatus.loading) {
      status = RadioPlaybackStatus.paused;
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      try {
        // Se lo stream era stato fermato, ricarichiamolo (i live stream
        // icecast non si "riprendono" da dove interrotti).
        if (_audioPlayer.processingState == ProcessingState.idle) {
          await _audioPlayer.setUrl(RadioConfig.streamUrl);
        }
        await _audioPlayer.play();
        autoplayBlocked = false;
        errorMessage = null;
      } catch (e) {
        status = RadioPlaybackStatus.error;
        errorMessage = 'Errore di riproduzione: $e';
        notifyListeners();
      }
    }
  }

  void _startMetadataPolling() {
    _fetchMetadata();
    _metadataTimer?.cancel();
    _metadataTimer = Timer.periodic(
      RadioConfig.metadataPollInterval,
      (_) => _fetchMetadata(),
    );
  }

  Future<void> _fetchMetadata() async {
    try {
      final track = await _apiService.fetchCurrentTrack();
      currentTrack = track;
      notifyListeners();
    } catch (e) {
      // Manteniamo l'ultimo brano noto in caso di errore di rete transitorio,
      // ma logghiamo per facilitare il debug in caso di problemi persistenti.
      debugPrint('Errore nel recupero dei metadata: $e');
    }
  }

  @override
  void dispose() {
    _metadataTimer?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    _apiService.dispose();
    super.dispose();
  }
}
