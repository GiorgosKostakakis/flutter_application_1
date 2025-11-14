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
        expect(find.text('0'), findsWidgets); // Now finds 2: quantity and cart count
        
        // Decrement button should still work at 0, but quantity stays at 0
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();
        expect(find.text('0'), findsWidgets); // Still finds 2: quantity and cart count
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

    group('Cart Summary', () {
      testWidgets('displays initial cart summary with zero items',
          (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        // Scroll to make cart summary visible
        await tester.dragUntilVisible(
          find.text('Cart Summary'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );

        expect(find.text('Cart Summary'), findsOneWidget);
        expect(find.byKey(const Key('cart_item_count')), findsOneWidget);
        expect(find.byKey(const Key('cart_total_price')), findsOneWidget);
        
        // Initially 0 items and £0.00
        expect(find.text('0'), findsOneWidget);
        expect(find.text('£0.00'), findsOneWidget);
      });

      testWidgets('updates cart summary when item is added',
          (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        // Scroll to make Add to Cart button visible
        await tester.dragUntilVisible(
          find.text('Add to Cart'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );

        // Add item to cart (default: 1 Veggie Delight footlong on white bread)
        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // Scroll to see cart summary
        await tester.dragUntilVisible(
          find.text('Cart Summary'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );

        // Check that cart summary updated
        final itemCountText = tester.widget<Text>(find.byKey(const Key('cart_item_count')));
        expect(itemCountText.data, '1');
        
        final totalPriceText = tester.widget<Text>(find.byKey(const Key('cart_total_price')));
        expect(totalPriceText.data, '£11.00'); // 1 footlong = £11.00
      });

      testWidgets('updates cart summary with multiple items',
          (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        // Scroll to quantity controls
        await tester.dragUntilVisible(
          find.byIcon(Icons.add).last,
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );

        // Increase quantity to 3
        await tester.tap(find.byIcon(Icons.add).last);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add).last);
        await tester.pumpAndSettle();

        // Scroll to Add to Cart button
        await tester.dragUntilVisible(
          find.text('Add to Cart'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );

        // Add 3 items to cart
        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // Scroll to cart summary
        await tester.dragUntilVisible(
          find.text('Cart Summary'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );

        // Check cart summary shows 3 items and correct price
        final itemCountText = tester.widget<Text>(find.byKey(const Key('cart_item_count')));
        expect(itemCountText.data, '3');
        
        final totalPriceText = tester.widget<Text>(find.byKey(const Key('cart_total_price')));
        expect(totalPriceText.data, '£33.00'); // 3 footlongs = 3 × £11.00
      });

      testWidgets('cart summary accumulates items from multiple additions',
          (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        // Add first item
        await tester.dragUntilVisible(
          find.text('Add to Cart'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );
        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // Add second item
        await tester.dragUntilVisible(
          find.text('Add to Cart'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );
        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // Check cart summary
        await tester.dragUntilVisible(
          find.text('Cart Summary'),
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );

        final itemCountText = tester.widget<Text>(find.byKey(const Key('cart_item_count')));
        expect(itemCountText.data, '2');
        
        final totalPriceText = tester.widget<Text>(find.byKey(const Key('cart_total_price')));
        expect(totalPriceText.data, '£22.00'); // 2 footlongs = 2 × £11.00
      });
    });
  }
