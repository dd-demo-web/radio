// Basic smoke test: verifica che l'app Radio Wah si avvii e mostri il
// pulsante di play/pause principale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:radio_wah/main.dart';
import 'package:radio_wah/models/app_state.dart';

void main() {
  testWidgets('RadioWahApp avvia e mostra il titolo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RadioWahApp());
    await tester.pump();

    expect(find.text('Radio Wah'), findsWidgets);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);

    final appState = tester
        .element(find.byType(MainNavigationShell))
        .read<RadioAppState>();
    for (final label in ['Discover', 'Preferiti', 'Profilo']) {
      await tester.tap(find.text(label).last);
      await tester.pump();
      expect(appState.currentNavIndex, 0);
    }

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
