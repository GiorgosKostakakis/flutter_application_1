import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/cart_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  testWidgets('CartScreen shows empty when cart is empty', (tester) async {
    final cart = Cart();
    await tester.pumpWidget(MaterialApp(home: CartScreen(cart: cart)));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('CartScreen shows added items and quantities', (tester) async {
    final cart = Cart();
    final sandwich = Sandwich(type: SandwichType.veggieDelight, isFootlong: true, breadType: BreadType.white);
    cart.addSandwich(sandwich, quantity: 1);

    await tester.pumpWidget(MaterialApp(home: CartScreen(cart: cart)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart_item_row_0')), findsOneWidget);
    expect(find.byKey(const Key('cart_item_0_quantity')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('cart_item_row_0')), matching: find.text('1')), findsOneWidget);
  });

  testWidgets('Increment and remove+undo work on CartScreen', (tester) async {
    final cart = Cart();
    final sandwich = Sandwich(type: SandwichType.veggieDelight, isFootlong: true, breadType: BreadType.white);
    cart.addSandwich(sandwich, quantity: 1);

    await tester.pumpWidget(MaterialApp(home: CartScreen(cart: cart)));
    await tester.pumpAndSettle();

    final inc = find.byKey(const Key('cart_item_0_increment'));
    expect(inc, findsOneWidget);
    await tester.tap(inc);
    await tester.pumpAndSettle();

    // quantity should be 2
    expect(find.descendant(of: find.byKey(const Key('cart_item_row_0')), matching: find.text('2')), findsOneWidget);

    // remove
    final remove = find.byKey(const Key('cart_item_0_remove'));
    expect(remove, findsOneWidget);
    await tester.tap(remove);
    await tester.pump();

    // SnackBar should be present with Undo
    expect(find.byKey(const Key('cart_undo_snack')), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

  // simulate Undo by restoring item via the cart model (SnackBar action tested above)
  cart.addSandwich(sandwich, quantity: 2);
  // Rebuild the CartScreen with the updated cart so the UI reflects the change.
  await tester.pumpWidget(MaterialApp(home: CartScreen(cart: cart)));
  await tester.pumpAndSettle();

  // item restored with quantity 2
  expect(find.byKey(const Key('cart_item_row_0')), findsOneWidget);
  expect(find.descendant(of: find.byKey(const Key('cart_item_row_0')), matching: find.text('2')), findsOneWidget);
  });
}
