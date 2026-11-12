import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/schedule.dart';
import '../models/track_metadata.dart';
import 'radio_config.dart';

/// Unico punto che possiede il player audio.
///
/// Registrato con audio_service, è quello che pilotano anche il sistema
/// (schermata di blocco, Centro di Controllo, cuffie, notifica Android),
/// CarPlay (tramite MPRemoteCommandCenter) e Android Auto (browse tree qui sotto).
class RadioAudioHandler extends BaseAudioHandler {
  static const String liveMediaId = 'radio-wah-live';

  final AudioPlayer _player = AudioPlayer();
  final StreamController<Object> _errors = StreamController.broadcast();

  /// L'utente vuole ascoltare: se lo stream cade, riproviamo da soli.
  bool _wantsToPlay = false;
  DateTime? _pausedAt;
  Timer? _reconnectTimer;

  RadioAudioHandler() {
    mediaItem.add(_liveItem());
    _player.playbackEventStream.listen(
      (_) => _broadcastState(),
      onError: (Object e, StackTrace st) => _onPlaybackError(e),
    );
    _player.processingStateStream.listen((state) {
      // Un live che "finisce" vuol dire che il server ha chiuso lo stream.
      if (state == ProcessingState.completed) _scheduleReconnect();
    });
    _configureSession();
  }

  /// Errori di riproduzione (es. autoplay bloccato dal browser).
  Stream<Object> get errors => _errors.stream;

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('AudioSession non configurata: $e');
    }
  }

  // MARK: comandi

  @override
  Future<void> play() async {
    _wantsToPlay = true;
    _reconnectTimer?.cancel();
    await _startStream();
  }

  @override
  Future<void> pause() async {
    _wantsToPlay = false;
    _reconnectTimer?.cancel();
    _pausedAt = DateTime.now();
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _wantsToPlay = false;
    _reconnectTimer?.cancel();
    _pausedAt = null;
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() => stop();

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  // MARK: Android Auto / browse

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    if (parentMediaId == AudioService.browsableRootId) {
      return [mediaItem.value ?? _liveItem()];
    }
    return const [];
  }

  @override
  Future<MediaItem?> getMediaItem(String mediaId) async =>
      mediaId == liveMediaId ? mediaItem.value : null;

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) => play();

  @override
  Future<void> playFromSearch(String query, [Map<String, dynamic>? extras]) =>
      play();

  @override
  Future<void> prepare() async {
    if (_player.processingState == ProcessingState.idle) {
      await _player.setUrl(RadioConfig.streamUrl);
    }
  }

  // MARK: metadata

  /// Aggiorna quello che il sistema mostra in "In riproduzione".
  void updateLive(TrackMetadata track, ScheduleItem? show) {
    final hasTrack = track.title.isNotEmpty && track.title != 'Radio Wah';
    final art = track.artworkLarge ?? track.artworkSmall ?? show?.image;
    final item = _liveItem(
      title: hasTrack ? track.title : (show?.title ?? 'Radio WAH'),
      artist: hasTrack ? track.artist : 'In diretta',
      album: show?.title ?? 'Radio WAH',
      artUri: art == null ? null : Uri.tryParse(art),
    );
    // Confronto campo per campo: l'uguaglianza di MediaItem non è affidabile per questo.
    final current = mediaItem.value;
    if (current == null ||
        current.title != item.title ||
        current.artist != item.artist ||
        current.album != item.album ||
        current.artUri != item.artUri) {
      mediaItem.add(item);
    }
  }

  static MediaItem _liveItem({
    String title = 'Radio WAH',
    String artist = 'In diretta',
    String album = 'Radio WAH',
    Uri? artUri,
  }) => MediaItem(
    id: liveMediaId,
    title: title,
    artist: artist,
    album: album,
    artUri: artUri,
    playable: true,
  );

  // MARK: stream

  Future<void> _startStream({bool reload = false}) async {
    try {
      final pausedAt = _pausedAt;
      final stale =
          pausedAt != null &&
          DateTime.now().difference(pausedAt) > RadioConfig.liveResumeThreshold;
      if (reload ||
          stale ||
          _player.processingState == ProcessingState.idle ||
          _player.processingState == ProcessingState.completed) {
        await _player.setUrl(RadioConfig.streamUrl);
      }
      _pausedAt = null;
      // play() completa solo quando la riproduzione si ferma: non lo aspettiamo.
      unawaited(
        _player.play().catchError((Object e) => _onPlaybackError(e)),
      );
    } catch (e) {
      _onPlaybackError(e);
    }
  }

  void _onPlaybackError(Object error) {
    if (error is PlayerInterruptedException) return;
    _errors.add(error);
    final message = error.toString();
    if (message.contains('NotAllowedError') ||
        message.contains('play() failed')) {
      // Autoplay bloccato dal browser: serve un tap, niente retry.
      _wantsToPlay = false;
      _broadcastState();
      return;
    }
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        playing: false,
      ),
    );
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_wantsToPlay) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(RadioConfig.reconnectDelay, () {
      if (_wantsToPlay) _startStream(reload: true);
    });
  }

  void _broadcastState() {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.playPause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
      ),
    );
  }

  Future<void> dispose() async {
    _reconnectTimer?.cancel();
    await _errors.close();
    await _player.dispose();
  }
}

/// Registra l'handler presso il sistema. Dove audio_service non è disponibile
/// (piattaforme non supportate) l'app funziona lo stesso, senza controlli di sistema.
Future<RadioAudioHandler> initRadioAudio() async {
  try {
    return await AudioService.init(
      builder: RadioAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.dddl.radiowah.playback',
        androidNotificationChannelName: 'Radio WAH',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  } catch (e) {
    debugPrint('audio_service non disponibile, player senza controlli di sistema: $e');
    return RadioAudioHandler();
  }
}
