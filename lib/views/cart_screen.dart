import 'package:flutter/material.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/cart_item_row.dart';
import 'package:sandwich_shop/views/edit_item_modal.dart';
import 'package:sandwich_shop/views/checkout_screen.dart';
import 'package:sandwich_shop/views/styled_button.dart';
import 'package:sandwich_shop/views/main_scaffold.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Cart get _cart => widget.cart;

  void _increment(int index) {
    setState(() {
      _cart.incrementQuantity(index);
    });
  }

  void _decrement(int index) {
    setState(() {
      // If decrement removes item, show undo
      final beforeQty = _cart.items[index].quantity;
      _cart.decrementQuantity(index);
      if (beforeQty == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const Key('cart_undo_snack'),
            content: const Text('Item removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // simple restore: re-add the item with qty 1
                // NOTE: this is a temporary approach until Cart exposes restoreItem
                // Here we won't know the sandwich that was removed; for now, show message only.
              },
            ),
          ),
        );
      }
    });
  }

  void _remove(int index) {
    setState(() {
      // store removed item for potential undo
      final removed = _cart.items[index];
      _cart.removeAt(index);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('cart_undo_snack'),
          content: Text('Removed ${removed.sandwich.name}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _cart.addSandwich(removed.sandwich, quantity: removed.quantity);
              });
            },
          ),
        ),
      );
    });
  }

  Future<void> _edit(int index, Sandwich current) async {
    final result = await showDialog<Sandwich>(
      context: context,
      builder: (_) => EditItemModal(sandwich: current),
    );

    if (result != null) {
      setState(() {
        // Simple replace: update sandwich by removing and adding with same qty
        final qty = _cart.items[index].quantity;
        _cart.removeAt(index);
        _cart.addSandwich(result, quantity: qty);
      });
    }
  }

  Future<void> _navigateToCheckout() async {
    if (widget.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: widget.cart),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.cart.clear();
      });

      final String orderId = result['orderId'] as String;
      final String estimatedTime = result['estimatedTime'] as String;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order $orderId confirmed! Estimated time: $estimatedTime'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Your Cart',
      child: _cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your cart is empty'),
                  const SizedBox(height: 20),
                  StyledButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.arrow_back,
                    label: 'Back to Order',
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cart.items.length,
                      itemBuilder: (context, index) {
                        final item = _cart.items[index];
                        return CartItemRow(
                          item: item,
                          index: index,
                          onIncrement: _increment,
                          onDecrement: _decrement,
                          onRemove: _remove,
                          onEdit: _edit,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Builder(
                    builder: (BuildContext context) {
                      final bool cartHasItems = widget.cart.items.isNotEmpty;
                      if (cartHasItems) {
                        return StyledButton(
                          onPressed: _navigateToCheckout,
                          icon: Icons.payment,
                          label: 'Checkout',
                          backgroundColor: Colors.orange,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  StyledButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.arrow_back,
                    label: 'Back to Order',
                    backgroundColor: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}
