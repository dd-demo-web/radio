import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/schedule.dart';
import 'radio_player_controller.dart';

/// Lato Dart del canale `radio_wah/carplay` (lato nativo: `ios/Runner/RadioCarPlay.swift`).
///
/// Spinge a CarPlay lo stato del live (brano, programma, palinsesto di oggi)
/// e riceve il comando "play" quando si tocca la diretta sullo schermo dell'auto.
class CarPlayBridge {
  CarPlayBridge._();

  static const MethodChannel _channel = MethodChannel('radio_wah/carplay');
  /// Stato già inviato, senza la lista 'today' (confrontata tramite 'todayKey').
  static Map<String, Object?>? _lastSignature;

  static void attach(RadioPlayerController controller) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'play':
          await controller.play();
          return null;
        default:
          throw MissingPluginException('Metodo ${call.method} non gestito');
      }
    });

    void push() {
      final state = _stateOf(controller);
      final signature = Map.of(state)..remove('today');
      if (mapEquals(signature, _lastSignature)) return;
      _lastSignature = signature;
      _channel.invokeMethod<void>('state', state).catchError((Object e) {
        debugPrint('CarPlayBridge: stato non inviato: $e');
      });
    }

    controller.addListener(push);
    push();
  }

  static Map<String, Object?> _stateOf(RadioPlayerController c) {
    final track = c.currentTrack;
    final show = c.currentShow;
    final now = DateTime.now();
    final today = c.schedule?.itemsFor(now) ?? const <ScheduleItem>[];
    return {
      'isPlaying': c.isPlaying,
      'title': track.title,
      'artist': track.artist,
      'artworkUrl': track.artworkLarge ?? track.artworkSmall ?? show?.image,
      'showTitle': show?.title,
      'showTime': show == null ? null : '${show.hourStart}–${show.hourEnd}',
      'today': [
        for (final item in today)
          {
            'start': item.hourStart,
            'end': item.hourEnd,
            'title': item.title,
            'subtitle': item.subtitle,
            'onAir': identical(item, show),
          },
      ],
      // Firma della lista, per non reinviare lo stato se non è cambiato nulla.
      'todayKey': today
          .map((i) => '${i.hourStart}|${i.title}|${identical(i, show)}')
          .join(';'),
    };
  }
}
