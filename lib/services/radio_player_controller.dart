import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';

import '../models/schedule.dart';
import '../models/track_metadata.dart';
import 'radio_api_service.dart';
import 'radio_audio_handler.dart';
import 'radio_config.dart';

/// Stato riproduzione radio in diretta.
enum RadioPlaybackStatus { idle, loading, playing, paused, error }

/// Stato del live per la UI: riproduzione, brano in onda e programma in onda.
///
/// Viene creato in `main()` e non dentro un widget, perché deve funzionare
/// anche senza UI (CarPlay a telefono bloccato, Android Auto).
/// L'audio vero lo gestisce [RadioAudioHandler].
class RadioPlayerController extends ChangeNotifier {
  final RadioAudioHandler _audio;
  final RadioApiService _apiService;

  RadioPlaybackStatus status = RadioPlaybackStatus.idle;
  TrackMetadata currentTrack = TrackMetadata.empty();
  String? errorMessage;

  /// Palinsesto settimanale e programma in onda adesso (null se non noto).
  WeeklySchedule? schedule;
  ScheduleItem? currentShow;
  DateTime? _scheduleLoadedAt;

  /// True quando il browser ha bloccato l'autoplay (richiede un tap
  /// dell'utente prima di poter avviare l'audio, es. su web).
  bool autoplayBlocked = false;

  Timer? _metadataTimer;
  Timer? _onAirTimer;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _autoplayAttempted = false;

  RadioPlayerController(this._audio, {RadioApiService? apiService})
    : _apiService = apiService ?? RadioApiService();

  bool get isPlaying => status == RadioPlaybackStatus.playing;

  /// Avvia ascolto dello stato audio, polling dei metadata e palinsesto.
  /// Non avvia la musica: per quello c'è [autoplayOnce].
  void start() {
    _subscriptions
      ..add(_audio.playbackState.listen(_onPlaybackState))
      ..add(_audio.errors.listen(_onError));

    _fetchMetadata();
    _metadataTimer = Timer.periodic(
      RadioConfig.metadataPollInterval,
      (_) => _fetchMetadataIfUseful(),
    );

    _refreshOnAir();
    _onAirTimer = Timer.periodic(
      RadioConfig.onAirRefreshInterval,
      (_) => _refreshOnAir(),
    );
  }

  /// Autoplay all'apertura, una volta sola e solo quando la UI è visibile
  /// (chiamato dopo il primo frame): CarPlay e Android Auto avviano l'app
  /// senza UI e lì la musica deve partire solo su richiesta.
  void autoplayOnce() {
    if (_autoplayAttempted) return;
    _autoplayAttempted = true;
    status = RadioPlaybackStatus.loading;
    notifyListeners();
    play();
  }

  Future<void> play() async {
    autoplayBlocked = false;
    errorMessage = null;
    await _audio.play();
  }

  Future<void> pause() => _audio.pause();

  Future<void> togglePlayPause() => isPlaying ? pause() : play();

  Future<void> setVolume(double volume) => _audio.setVolume(volume / 100);

  // MARK: stato audio

  void _onPlaybackState(PlaybackState state) {
    final wasPlaying = isPlaying;
    final RadioPlaybackStatus next;
    if (state.processingState == AudioProcessingState.error) {
      next = RadioPlaybackStatus.error;
    } else if (state.playing) {
      next = RadioPlaybackStatus.playing;
    } else if (state.processingState == AudioProcessingState.loading ||
        state.processingState == AudioProcessingState.buffering) {
      next = RadioPlaybackStatus.loading;
    } else if (state.processingState == AudioProcessingState.idle &&
        status == RadioPlaybackStatus.loading) {
      next = RadioPlaybackStatus.loading;
    } else {
      next = RadioPlaybackStatus.paused;
    }
    if (next == RadioPlaybackStatus.playing) {
      autoplayBlocked = false;
      errorMessage = null;
    }
    if (next != status) {
      status = next;
      notifyListeners();
    }
    // Appena riparte, aggiorniamo subito il brano invece di aspettare il polling.
    if (!wasPlaying && isPlaying) _fetchMetadata();
  }

  void _onError(Object error) {
    final message = error.toString();
    if (message.contains('NotAllowedError') ||
        message.contains('play() failed')) {
      autoplayBlocked = true;
      status = RadioPlaybackStatus.paused;
    } else {
      status = RadioPlaybackStatus.error;
      errorMessage = 'Il live si è interrotto. Riproviamo tra pochi secondi.';
      debugPrint('Errore di riproduzione: $error');
    }
    notifyListeners();
  }

  // MARK: brano in onda

  /// Il polling serve solo se si sta ascoltando o se qualcuno guarda lo schermo.
  void _fetchMetadataIfUseful() {
    final visible =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (isPlaying || visible) _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
    try {
      final track = await _apiService.fetchCurrentTrack();
      if (track.title == currentTrack.title &&
          track.artist == currentTrack.artist &&
          track.artworkLarge == currentTrack.artworkLarge) {
        return;
      }
      currentTrack = track;
      _audio.updateLive(currentTrack, currentShow);
      notifyListeners();
    } catch (e) {
      // Manteniamo l'ultimo brano noto in caso di errore di rete transitorio.
      debugPrint('Errore nel recupero dei metadata: $e');
    }
  }

  // MARK: programma in onda

  Future<void> _refreshOnAir() async {
    final now = DateTime.now();
    final loadedAt = _scheduleLoadedAt;
    if (schedule == null ||
        loadedAt == null ||
        now.difference(loadedAt) > RadioConfig.scheduleMaxAge ||
        now.day != loadedAt.day) {
      try {
        schedule = await _apiService.fetchWeeklySchedule();
        _scheduleLoadedAt = now;
      } catch (e) {
        debugPrint('Errore nel recupero del palinsesto: $e');
      }
    }
    final show = schedule?.onAirAt(DateTime.now());
    if (show?.title != currentShow?.title ||
        show?.hourStart != currentShow?.hourStart ||
        loadedAt != _scheduleLoadedAt) {
      currentShow = show;
      _audio.updateLive(currentTrack, currentShow);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _metadataTimer?.cancel();
    _onAirTimer?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _apiService.dispose();
    super.dispose();
  }
}
