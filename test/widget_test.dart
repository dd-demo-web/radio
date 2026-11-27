// Basic smoke test: verifica che l'app Radio Wah si avvii e mostri il
// pulsante di play/pause principale.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:radio_wah/main.dart';
import 'package:radio_wah/models/app_state.dart';
import 'package:radio_wah/models/schedule.dart';
import 'package:radio_wah/models/track_metadata.dart';
import 'package:radio_wah/screens/player_screen.dart';
import 'package:radio_wah/services/radio_audio_handler.dart';
import 'package:radio_wah/services/radio_player_controller.dart';

void main() {
  for (final size in [
    const Size(320, 480),
    const Size(320, 568),
    const Size(375, 667),
    const Size(390, 844),
  ]) {
    testWidgets('player visibile senza scroll a $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = RadioPlayerController(RadioAudioHandler())
        ..currentShow = ScheduleItem(
          hourStart: '08:30',
          hourEnd: '10:00',
          title: 'Moka',
          subtitle: 'Pop',
        )
        ..currentTrack = TrackMetadata(
          title: 'Brano in onda',
          artist: 'Artista',
          album: 'Album',
          year: '2026',
        );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => RadioAppState()),
            ChangeNotifierProvider.value(value: controller),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: const EdgeInsets.only(top: 24, bottom: 116),
                ),
                child: const PlayerScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final play = find.byType(FloatingActionButton);
      expect(play.hitTestable(), findsOneWidget);
      expect(tester.getRect(play).bottom, lessThanOrEqualTo(size.height - 116));
      expect(
        tester.getRect(find.byTooltip('Mostra controlli volume')).bottom,
        lessThanOrEqualTo(size.height - 116),
      );
      expect(find.byType(Scrollable), findsNothing);
      final playRect = tester.getRect(play);
      await tester.drag(find.byType(PlayerScreen), const Offset(0, -150));
      await tester.pump();
      expect(tester.getRect(play), playRect);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final size in [const Size(320, 568), const Size(375, 667)]) {
    testWidgets(
      'il player resta sopra il menu nella schermata completa $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);

        final controller = RadioPlayerController(RadioAudioHandler());
        await tester.pumpWidget(RadioWahApp(controller: controller));
        await tester.pump();

        final play = find.byType(FloatingActionButton);
        final navItem = find.bySemanticsLabel('Live');
        expect(play.hitTestable(), findsOneWidget);
        expect(
          tester.getRect(play).bottom,
          lessThan(tester.getRect(navItem).top),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('testi ingranditi restano visibili senza scroll sul mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RadioPlayerController(RadioAudioHandler())
      ..currentShow = ScheduleItem(
        hourStart: '08:30',
        hourEnd: '10:00',
        title: 'Un programma radio dal titolo molto lungo',
        subtitle: 'Musica e notizie per tutta la mattina',
      );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RadioAppState()),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 24, bottom: 116),
                textScaler: const TextScaler.linear(1.5),
              ),
              child: const PlayerScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Un programma radio dal titolo molto lungo'),
      findsOneWidget,
    );
    final titleRect = tester.getRect(
      find.text('Un programma radio dal titolo molto lungo'),
    );
    expect(titleRect.top, greaterThanOrEqualTo(24));
    expect(titleRect.bottom, lessThanOrEqualTo(568 - 116));
    expect(find.byType(Scrollable), findsNothing);
    expect(find.byType(FloatingActionButton).hitTestable(), findsOneWidget);
    expect(
      tester.getRect(find.byType(FloatingActionButton)).bottom,
      lessThanOrEqualTo(568 - 116),
    );
    expect(
      find.byTooltip('Mostra controlli volume').hitTestable(),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Mostra controlli volume'));
    await tester.pump();
    expect(find.bySemanticsLabel('Volume'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('il player desktop mantiene lo scroll con testi ingranditi', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RadioPlayerController(RadioAudioHandler())
      ..currentShow = ScheduleItem(
        hourStart: '08:30',
        hourEnd: '10:00',
        title: 'Un programma radio dal titolo molto lungo',
        subtitle: 'Musica e notizie per tutta la mattina',
      );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RadioAppState()),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 24, bottom: 116),
                textScaler: const TextScaler.linear(1.5),
              ),
              child: const PlayerScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .maxScrollExtent,
      greaterThan(0),
    );
    await tester.ensureVisible(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.byType(FloatingActionButton).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('RadioWahApp avvia e mostra il titolo', (
    WidgetTester tester,
  ) async {
    final controller = RadioPlayerController(RadioAudioHandler());
    await tester.pumpWidget(RadioWahApp(controller: controller));
    await tester.pump();

    expect(find.text('Radio Wah'), findsWidgets);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsNothing,
    );

    final appState = tester
        .element(find.byType(MainNavigationShell))
        .read<RadioAppState>();
    // Solo Live e Palinsesto sono attive.
    for (final label in ['Esplora', 'Info']) {
      expect(find.text(label), findsOneWidget);
      final semantics = tester.widget<Semantics>(find.bySemanticsLabel(label));
      expect(semantics.properties.enabled, isFalse);
      expect(semantics.properties.onTap, isNull);
      await tester.tap(find.text(label), warnIfMissed: false);
      await tester.pump();
      expect(appState.currentNavIndex, 0);
    }
    expect(appState.currentNavIndex, 0);

    await tester.tap(find.text('Palinsesto').last);
    await tester.pump();
    expect(appState.currentNavIndex, 1);
    expect(find.textContaining('Settimana '), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Live').last);
    await tester.pump();
    expect(appState.currentNavIndex, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final sunday in ['"sun":[]', '']) {
    testWidgets(
      'giorno senza programmi mostra il pulsante mixtape disabilitato ($sunday)',
      (WidgetTester tester) async {
        await http.runWithClient(
          () async {
            final controller = RadioPlayerController(RadioAudioHandler());
            await tester.pumpWidget(RadioWahApp(controller: controller));
            await tester.pump();
            await tester.tap(find.text('Palinsesto').last);
            await tester.pump();
            await tester.pump();

            final selector = find.ancestor(
              of: find.bySemanticsLabel(RegExp(r'^LUN, ')),
              matching: find.byType(ListView),
            );
            await tester.drag(selector, const Offset(-500, 0));
            await tester.pump();
            await tester.tap(find.bySemanticsLabel(RegExp(r'^DOM, ')));
            await tester.pump();

            expect(find.text('Weekend in silenzio'), findsOneWidget);
            final button = tester.widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Apri i mixtape'),
            );
            expect(button.onPressed, isNull);
            await tester.tap(find.text('Apri i mixtape'), warnIfMissed: false);
            await tester.pump();
            expect(
              tester
                  .element(find.byType(MainNavigationShell))
                  .read<RadioAppState>()
                  .currentNavIndex,
              1,
            );
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          },
          () => MockClient(
            (_) async => http.Response(
              '{"result":{"days":{"mon":[{"title":"Moka"}]${sunday.isEmpty ? '' : ',$sunday'}}}}',
              200,
            ),
          ),
        );
      },
    );
  }

  testWidgets('pannello volume sovrapposto e chiuso al tocco esterno', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = RadioPlayerController(RadioAudioHandler());
    await tester.pumpWidget(RadioWahApp(controller: controller));
    await tester.pump();

    expect(find.bySemanticsLabel('Live'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Mostra controlli volume'));
    await tester.pump();
    expect(
      tester.getSemantics(find.byTooltip('Mostra controlli volume')).tooltip,
      'Mostra controlli volume',
    );
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    final playButtonRect = tester.getRect(find.byType(FloatingActionButton));
    await tester.tap(find.byTooltip('Mostra controlli volume'));
    await tester.pump();
    expect(tester.getRect(find.byType(FloatingActionButton)), playButtonRect);
    expect(find.bySemanticsLabel('Volume'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final volumeButtonRect = tester.getRect(
      find.byTooltip('Nascondi controlli volume'),
    );
    final volumeBefore = tester
        .getSemantics(find.bySemanticsLabel('Volume'))
        .value;
    final sliderRect = tester.getRect(find.byType(CupertinoSlider));
    expect(sliderRect.bottom, lessThan(volumeButtonRect.top));
    await tester.dragFrom(
      Offset(sliderRect.left + sliderRect.width * 0.8, sliderRect.center.dy),
      const Offset(-40, 0),
    );
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Volume')).value,
      isNot(volumeBefore),
    );

    await tester.tap(find.bySemanticsLabel('Palinsesto'));
    await tester.pump();
    expect(find.bySemanticsLabel('Volume'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('oggi')), findsOneWidget);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
  });
}
