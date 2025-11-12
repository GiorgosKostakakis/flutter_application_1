import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

void main() {
  group('Cart', () {
    late Cart cart;
    late Sandwich veggieFootlong;
    late Sandwich chickenSixInch;

    setUp(() {
      cart = Cart(pricing: PricingRepository());
      veggieFootlong = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      chickenSixInch = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: false,
        breadType: BreadType.wheat,
      );
    });

    test('starts empty', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.totalQuantity, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('adds a sandwich to cart', () {
      cart.addSandwich(veggieFootlong);
      
      expect(cart.isEmpty, isFalse);
      expect(cart.itemCount, 1);
      expect(cart.totalQuantity, 1);
      expect(cart.items[0].sandwich.type, SandwichType.veggieDelight);
    });

    test('increases quantity when adding same sandwich', () {
      cart.addSandwich(veggieFootlong);
      cart.addSandwich(veggieFootlong);
      
      expect(cart.itemCount, 1);
      expect(cart.totalQuantity, 2);
      expect(cart.items[0].quantity, 2);
    });

    test('adds multiple different sandwiches', () {
      cart.addSandwich(veggieFootlong);
      cart.addSandwich(chickenSixInch);
      
      expect(cart.itemCount, 2);
      expect(cart.totalQuantity, 2);
    });

    test('adds sandwich with specific quantity', () {
      cart.addSandwich(veggieFootlong, quantity: 3);
      
      expect(cart.itemCount, 1);
      expect(cart.totalQuantity, 3);
      expect(cart.items[0].quantity, 3);
    });

    test('increments quantity of item', () {
      cart.addSandwich(veggieFootlong);
      cart.incrementQuantity(0);
      
      expect(cart.totalQuantity, 2);
      expect(cart.items[0].quantity, 2);
    });

    test('decrements quantity of item', () {
      cart.addSandwich(veggieFootlong, quantity: 2);
      cart.decrementQuantity(0);
      
      expect(cart.totalQuantity, 1);
      expect(cart.items[0].quantity, 1);
    });

    test('removes item when quantity reaches 0', () {
      cart.addSandwich(veggieFootlong);
      cart.decrementQuantity(0);
      
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
    });

    test('removes item at index', () {
      cart.addSandwich(veggieFootlong);
      cart.addSandwich(chickenSixInch);
      cart.removeAt(0);
      
      expect(cart.itemCount, 1);
      expect(cart.items[0].sandwich.type, SandwichType.chickenTeriyaki);
    });

    test('updates quantity of item', () {
      cart.addSandwich(veggieFootlong);
      cart.updateQuantity(0, 5);
      
      expect(cart.items[0].quantity, 5);
      expect(cart.totalQuantity, 5);
    });

    test('removes item when updating quantity to 0', () {
      cart.addSandwich(veggieFootlong);
      cart.updateQuantity(0, 0);
      
      expect(cart.isEmpty, isTrue);
    });

    test('calculates total price correctly', () {
      // PricingRepository: footlong = £11.00, six-inch = £7.00
      cart.addSandwich(veggieFootlong, quantity: 2); // 2 x £11.00 = £22.00
      cart.addSandwich(chickenSixInch, quantity: 1); // 1 x £7.00 = £7.00
      
      expect(cart.totalPrice, 29.00); // £22.00 + £7.00 = £29.00
    });

    test('clears all items from cart', () {
      cart.addSandwich(veggieFootlong);
      cart.addSandwich(chickenSixInch);
      cart.clear();
      
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.totalQuantity, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('ignores adding sandwich with quantity <= 0', () {
      cart.addSandwich(veggieFootlong, quantity: 0);
      cart.addSandwich(chickenSixInch, quantity: -1);
      
      expect(cart.isEmpty, isTrue);
    });

    test('handles out of bounds operations gracefully', () {
      cart.addSandwich(veggieFootlong);
      
      // These should not throw errors
      cart.removeAt(5);
      cart.incrementQuantity(10);
      cart.decrementQuantity(-1);
      cart.updateQuantity(99, 5);
      
      expect(cart.itemCount, 1);
    });
  });
}
