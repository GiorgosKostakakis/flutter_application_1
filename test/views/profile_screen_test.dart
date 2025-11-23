import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/main.dart';

void main() {
  testWidgets('open profile screen and save', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Scroll and tap the profile button (it's below the fold)
    await tester.dragUntilVisible(
      find.byKey(const Key('profile_button')),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    expect(find.byKey(const Key('profile_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile_button')),
        warnIfMissed: false);
    await tester.pumpAndSettle();

    // We should now be on the Profile screen
    expect(find.text('Profile'), findsOneWidget);

    // Fill form
    await tester.enterText(find.byKey(const Key('profile_name')), 'Test User');
    await tester.enterText(find.byKey(const Key('profile_email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('profile_phone')), '1234567890');

  // Tap Save
  await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pumpAndSettle();

    // SnackBar should be shown
    expect(find.text('Profile saved'), findsOneWidget);
  });
}
