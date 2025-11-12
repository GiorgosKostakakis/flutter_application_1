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
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

  // Verify that our counter starts at 0 (app shows descriptive text).
  expect(find.textContaining('0 white footlong'), findsOneWidget);
  expect(find.textContaining('1 white footlong'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

  // Verify that our counter has incremented.
  expect(find.textContaining('0 white footlong'), findsNothing);
  expect(find.textContaining('1 white footlong'), findsOneWidget);
  });

  testWidgets('Switch toggles sandwich size between six-inch and footlong', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Initially the app should display the item type as `footlong` (default)
    expect(find.text('0 white footlong sandwich(es): '), findsOneWidget);

  // Find the size Switch (use a key because there are multiple Switch widgets)
  final switchFinder = find.byKey(const Key('size_switch'));
  expect(switchFinder, findsOneWidget);
  await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // After toggling, the displayed item type should switch to `six-inch`
    expect(find.text('0 white six-inch sandwich(es): '), findsOneWidget);
  });
}
