import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_wah/models/schedule.dart';
import 'package:radio_wah/models/track_metadata.dart';
import 'package:radio_wah/services/radio_api_service.dart';
import 'package:radio_wah/services/radio_audio_handler.dart';
import 'package:radio_wah/services/radio_player_controller.dart';

class _AudioHandler extends RadioAudioHandler {
  final titles = StreamController<String?>.broadcast(sync: true);

  @override
  Stream<String?> get icyTitles => titles.stream;

  @override
  Future<void> dispose() async {
    await titles.close();
    unawaited(super.dispose());
  }
}

class _ApiService extends RadioApiService {
  final requests = <Completer<TrackMetadata>>[];

  @override
  Future<TrackMetadata> fetchCurrentTrack() {
    final request = Completer<TrackMetadata>();
    requests.add(request);
    return request.future;
  }

  @override
  Future<WeeklySchedule> fetchWeeklySchedule() async =>
      WeeklySchedule(days: {});
}

void main() {
  testWidgets(
    'ICY aggiorna subito e l API arricchisce solo il brano corrente',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final audio = _AudioHandler();
      final api = _ApiService();
      final controller = RadioPlayerController(audio, apiService: api)
        ..currentTrack = TrackMetadata(
          title: 'Vecchio',
          artist: 'Artista',
          artworkLarge: 'https://example.com/old.jpg',
        )
        ..start();
      addTearDown(() async {
        controller.dispose();
        await audio.dispose();
      });
      await tester.pump();

      audio.titles.add('Nuovo artista - Nuovo brano');
      expect(controller.currentTrack.title, 'Nuovo brano');
      expect(controller.currentTrack.artist, 'Nuovo artista');
      expect(controller.currentTrack.artworkLarge, isNull);
      expect(audio.mediaItem.value?.title, 'Nuovo brano');
      expect(api.requests, hasLength(2));

      api.requests[0].complete(
        TrackMetadata(title: 'Vecchio', artist: 'Artista'),
      );
      api.requests[1].complete(
        TrackMetadata(title: 'Vecchio', artist: 'Artista'),
      );
      await tester.pump();
      expect(controller.currentTrack.title, 'Nuovo brano');

      await tester.pump(const Duration(seconds: 3));
      expect(api.requests, hasLength(3));
      api.requests[2].complete(
        TrackMetadata(
          title: 'Nuovo brano',
          artist: 'NUOVO ARTISTA',
          album: 'Album',
          artworkLarge: 'https://example.com/new.jpg',
        ),
      );
      await tester.pump();
      expect(controller.currentTrack.album, 'Album');
      expect(
        controller.currentTrack.artworkLarge,
        'https://example.com/new.jpg',
      );
      expect(
        audio.mediaItem.value?.artUri.toString(),
        'https://example.com/new.jpg',
      );

      audio.titles.add('Nuovo artista - Nuovo brano');
      expect(controller.currentTrack.album, 'Album');
      expect(api.requests, hasLength(3));
    },
  );

  testWidgets(
    'risposte fuori ordine non sovrascrivono un evento ICY successivo',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final audio = _AudioHandler();
      final api = _ApiService();
      final controller = RadioPlayerController(audio, apiService: api)..start();
      addTearDown(() async {
        controller.dispose();
        await audio.dispose();
      });
      await tester.pump();

      audio.titles.add('Artista - Primo');
      audio.titles.add('Artista - Secondo');
      await tester.pump(const Duration(seconds: 30));
      api.requests[3].complete(
        TrackMetadata(title: 'Secondo', artist: 'Artista', album: 'Nuovo'),
      );
      await tester.pump();
      api.requests[2].complete(
        TrackMetadata(title: 'Secondo', artist: 'Artista', album: 'Vecchio'),
      );
      api.requests[1].complete(
        TrackMetadata(title: 'Primo', artist: 'Artista', album: 'Vecchio'),
      );
      api.requests[0].complete(
        TrackMetadata(title: 'Primo', artist: 'Artista'),
      );
      await tester.pump();

      expect(controller.currentTrack.title, 'Secondo');
      expect(controller.currentTrack.album, 'Nuovo');
    },
  );

  testWidgets('il polling riprende se ICY non emette nuovi titoli', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final audio = _AudioHandler();
    final api = _ApiService();
    final controller = RadioPlayerController(audio, apiService: api)..start();
    addTearDown(() async {
      controller.dispose();
      await audio.dispose();
    });
    await tester.pump();
    audio.titles.add('Solo titolo');
    expect(controller.currentTrack.title, 'Solo titolo');
    expect(controller.currentTrack.artist, isEmpty);

    api.requests.last.complete(
      TrackMetadata(title: 'Titolo dal polling', artist: 'Artista'),
    );
    await tester.pump();
    expect(controller.currentTrack.title, 'Solo titolo');
    await tester.pump(const Duration(minutes: 2));
    api.requests.last.complete(
      TrackMetadata(title: 'Titolo dal polling', artist: 'Artista'),
    );
    await tester.pump();
    expect(controller.currentTrack.title, 'Titolo dal polling');
  });

  testWidgets('un brano lungo mantiene la priorità ICY', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final audio = _AudioHandler();
    final api = _ApiService();
    final controller = RadioPlayerController(audio, apiService: api)..start();
    addTearDown(() async {
      controller.dispose();
      await audio.dispose();
    });
    await tester.pump();
    audio.titles.add('Artista - Brano lungo');
    api.requests.last.complete(
      TrackMetadata(title: 'Brano lungo', artist: 'Artista'),
    );
    await tester.pump();

    await tester.pump(const Duration(minutes: 3));
    api.requests.last.complete(
      TrackMetadata(title: 'Brano successivo', artist: 'Artista'),
    );
    await tester.pump();
    expect(controller.currentTrack.title, 'Brano lungo');

    audio.titles.add('Artista - Brano successivo');
    expect(controller.currentTrack.title, 'Brano successivo');
  });

  testWidgets('senza ICY il polling continua ad aggiornare i metadati', (
    tester,
  ) async {
    final audio = _AudioHandler();
    final api = _ApiService();
    final controller = RadioPlayerController(audio, apiService: api)..start();
    addTearDown(() async {
      controller.dispose();
      await audio.dispose();
    });
    await tester.pump();
    audio.titles.add(null);
    audio.titles.add('  ');
    expect(api.requests, hasLength(1));
    api.requests.single.complete(
      TrackMetadata(title: 'Brano API', artist: 'Artista'),
    );
    await tester.pump();
    expect(controller.currentTrack.title, 'Brano API');
  });
}
