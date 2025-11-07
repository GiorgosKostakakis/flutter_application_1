class PricingRepository {
  final int sixInchPrice; // in pounds
  final int footlongPrice; // in pounds

  PricingRepository({this.sixInchPrice = 7, this.footlongPrice = 11});

  /// Calculate total price in whole pounds for the given quantity and size.
  int totalPrice({required int quantity, required bool isFootlong}) {
    final unit = isFootlong ? footlongPrice : sixInchPrice;
    return unit * quantity;
  }
}
