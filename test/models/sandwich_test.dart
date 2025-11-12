import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('Sandwich', () {
    test('returns correct name for sandwich types', () {
      final veggie = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      expect(veggie.name, 'Veggie Delight');

      final chicken = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: true,
        breadType: BreadType.white,
      );
      expect(chicken.name, 'Chicken Teriyaki');
    });

    test('returns correct image path for footlong', () {
      final sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      expect(sandwich.image, 'assets/images/veggieDelight_footlong.png');
    });

    test('returns correct image path for six-inch', () {
      final sandwich = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: false,
        breadType: BreadType.wheat,
      );
      expect(sandwich.image, 'assets/images/tunaMelt_six_inch.png');
    });
  });
}
