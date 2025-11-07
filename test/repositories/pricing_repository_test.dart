import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

void main() {
  group('PricingRepository', () {
    test('zero quantity should cost 0', () {
      final repo = PricingRepository();
      expect(repo.totalPrice(quantity: 0, isFootlong: false), 0);
      expect(repo.totalPrice(quantity: 0, isFootlong: true), 0);
    });

    test('six-inch price is applied correctly', () {
      final repo = PricingRepository();
      expect(repo.totalPrice(quantity: 1, isFootlong: false), 7);
      expect(repo.totalPrice(quantity: 3, isFootlong: false), 21);
    });

    test('footlong price is applied correctly', () {
      final repo = PricingRepository();
      expect(repo.totalPrice(quantity: 1, isFootlong: true), 11);
      expect(repo.totalPrice(quantity: 2, isFootlong: true), 22);
    });

    test('custom prices via constructor', () {
      final repo = PricingRepository(sixInchPrice: 5, footlongPrice: 9);
      expect(repo.totalPrice(quantity: 2, isFootlong: false), 10);
      expect(repo.totalPrice(quantity: 2, isFootlong: true), 18);
    });
  });
}
