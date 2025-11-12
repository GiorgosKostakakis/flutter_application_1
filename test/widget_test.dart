import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/main.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('App', () {
    testWidgets('renders OrderScreen as home', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(OrderScreen), findsOneWidget);
    });
  });

  group('OrderScreen - UI Elements', () {
    testWidgets('shows title and initial quantity',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('Sandwich Counter'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Initial quantity
    });

    testWidgets('shows sandwich type dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(DropdownMenu<SandwichType>), findsOneWidget);
    });

    testWidgets('shows bread type dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(DropdownMenu<BreadType>), findsOneWidget);
    });

    testWidgets('shows size switch', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Six-inch'), findsOneWidget);
      expect(find.text('Footlong'), findsOneWidget);
    });

    testWidgets('shows Add to Cart button', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
    });
  });

  group('OrderScreen - Quantity Controls', () {
    testWidgets('increments quantity when + button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      expect(find.text('1'), findsWidgets);
      
      // Scroll to make the button visible
      await tester.dragUntilVisible(
        find.byIcon(Icons.add),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();
      
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('decrements quantity when - button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      // Scroll to make the buttons visible
      await tester.dragUntilVisible(
        find.byIcon(Icons.add),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      
      // First increment to 2
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      
      // Then decrement back to 1
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('does not decrement below zero', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      // Scroll to make the button visible
      await tester.dragUntilVisible(
        find.byIcon(Icons.remove),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      
      expect(find.text('1'), findsWidgets);
      
      // Try to decrement to 0
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      
      // Decrement button should still work at 0, but quantity stays at 0
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('OrderScreen - Size Toggle', () {
    testWidgets('toggles between six-inch and footlong',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      
      // Initially footlong (switch is on)
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
      
      // Toggle to six-inch
      await tester.tap(find.byType(Switch));
      await tester.pump();
      
      final switchWidgetAfter = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidgetAfter.value, isFalse);
    });
  });

  group('StyledButton', () {
    testWidgets('renders with icon and label', (WidgetTester tester) async {
      const testButton = StyledButton(
        onPressed: null,
        icon: Icons.add,
        label: 'Test Add',
        backgroundColor: Colors.blue,
      );
      const testApp = MaterialApp(
        home: Scaffold(body: testButton),
      );
      await tester.pumpWidget(testApp);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Test Add'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
