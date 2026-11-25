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
import 'package:radio_wah/services/radio_audio_handler.dart';
import 'package:radio_wah/services/radio_player_controller.dart';

void main() {
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
