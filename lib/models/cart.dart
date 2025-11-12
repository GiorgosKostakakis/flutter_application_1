import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

/// Represents a sandwich in the cart with its quantity.
class CartItem {
  final Sandwich sandwich;
  int quantity;

  CartItem({
    required this.sandwich,
    this.quantity = 1,
  }) : assert(quantity > 0, 'Quantity must be greater than 0');

  /// Calculate the total price for this cart item.
  double totalPrice(PricingRepository pricing) {
    return pricing.calculatePrice(
      quantity: quantity,
      isFootlong: sandwich.isFootlong,
    );
  }
}

/// Shopping cart for a food delivery app.
/// Manages a collection of sandwiches with their quantities.
class Cart {
  final PricingRepository _pricing;
  final List<CartItem> _items = [];

  Cart({PricingRepository? pricing})
      : _pricing = pricing ?? PricingRepository();

  /// Get all items in the cart (read-only).
  List<CartItem> get items => List.unmodifiable(_items);

  /// Total number of items in cart.
  int get itemCount => _items.length;

  /// Total quantity of all sandwiches.
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price of all items in the cart.
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice(_pricing));

  /// Check if cart is empty.
  bool get isEmpty => _items.isEmpty;

  /// Add a sandwich to the cart.
  /// If the same sandwich already exists, increase its quantity.
  void addSandwich(Sandwich sandwich, {int quantity = 1}) {
    if (quantity <= 0) return;

    // Check if this sandwich is already in the cart
    final existingIndex = _items.indexWhere(
      (item) =>
          item.sandwich.type == sandwich.type &&
          item.sandwich.isFootlong == sandwich.isFootlong &&
          item.sandwich.breadType == sandwich.breadType,
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(sandwich: sandwich, quantity: quantity));
    }
  }

  /// Remove an item from the cart by index.
  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  /// Increase quantity of item at index.
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
    }
  }

  /// Decrease quantity of item at index.
  /// Removes the item if quantity reaches 0.
  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity--;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
    }
  }

  /// Update quantity of item at index.
  /// Removes the item if quantity is 0 or less.
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
    }
  }

  /// Clear all items from the cart.
  void clear() => _items.clear();
}
