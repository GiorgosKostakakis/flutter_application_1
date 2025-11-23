import 'package:flutter/material.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/app_styles.dart';

typedef VoidIntCallback = void Function(int index);

class CartItemRow extends StatelessWidget {
  final CartItem item;
  final int index;
  final VoidIntCallback onIncrement;
  final VoidIntCallback onDecrement;
  final VoidIntCallback onRemove;
  final void Function(int index, Sandwich newConfig) onEdit;

  const CartItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final sandwich = item.sandwich;
    final id = index; // temporary stable identifier until Cart adds ids

    return Card(
      key: Key('cart_item_row_$id'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(sandwich.image, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sandwich.name, style: heading2),
                  const SizedBox(height: 4),
                  Text(
                      '${sandwich.isFootlong ? 'Footlong' : 'Six-inch'} · ${sandwich.breadType.name}',
                      style: normalText),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      key: Key('cart_item_${id}_decrement'),
                      onPressed: () => onDecrement(index),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${item.quantity}', key: Key('cart_item_${id}_quantity'), style: heading2),
                    IconButton(
                      key: Key('cart_item_${id}_increment'),
                      onPressed: () => onIncrement(index),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      key: Key('cart_item_${id}_edit'),
                      onPressed: () {
                        // open edit handled by parent via onEdit
                        onEdit(index, item.sandwich);
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      key: Key('cart_item_${id}_remove'),
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
