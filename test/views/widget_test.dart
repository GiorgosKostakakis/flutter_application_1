// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sandwich_shop/main.dart';

void main() {
  testWidgets('App starts with initial quantity of 1', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Verify that our counter starts at 1 (new default).
    expect(find.text('1'), findsWidgets);
    expect(find.text('Sandwich Counter'), findsOneWidget);
  });

  testWidgets('Switch toggles sandwich size between six-inch and footlong', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Initially the switch should be on (footlong)
    final switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isTrue);

    // Toggle the switch
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // After toggling, the switch should be off (six-inch)
    final switchWidgetAfter = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidgetAfter.value, isFalse);
  });
}
