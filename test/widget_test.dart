// Basic smoke test: verifica che l'app Radio Wah si avvii e mostri il
// pulsante di play/pause principale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    final appState = tester
        .element(find.byType(MainNavigationShell))
        .read<RadioAppState>();
    // Solo Live e Palinsesto sono attive: Esplora e Info sono nascoste.
    for (final label in ['Esplora', 'Info']) {
      expect(find.text(label), findsNothing);
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
}
