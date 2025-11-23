import 'package:flutter/material.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/cart_item_row.dart';
import 'package:sandwich_shop/views/edit_item_modal.dart';
import 'package:sandwich_shop/views/app_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: _cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total: £${_cart.totalPrice.toStringAsFixed(2)}', style: heading2),
            ElevatedButton(
              onPressed: _cart.isEmpty ? null : () {},
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
