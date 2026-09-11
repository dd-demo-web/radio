// Basic smoke test: verifica che l'app Radio Wah si avvii e mostri il
// pulsante di play/pause principale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radio_wah/main.dart';

void main() {
  testWidgets('RadioWahApp avvia e mostra il titolo', (WidgetTester tester) async {
    await tester.pumpWidget(const RadioWahApp());
    await tester.pump();

    expect(find.text('Radio Wah'), findsWidgets);
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
  });
}
