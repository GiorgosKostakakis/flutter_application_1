import 'package:flutter/material.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/app_styles.dart';

class EditItemModal extends StatefulWidget {
  final Sandwich sandwich;

  const EditItemModal({super.key, required this.sandwich});

  @override
  State<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends State<EditItemModal> {
  late bool _isFootlong;
  late BreadType _breadType;

  @override
  void initState() {
    super.initState();
    _isFootlong = widget.sandwich.isFootlong;
    _breadType = widget.sandwich.breadType;
  }

  void _onSave() {
    final updated = Sandwich(
      type: widget.sandwich.type,
      isFootlong: _isFootlong,
      breadType: _breadType,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: Key('edit_item_modal_${widget.sandwich.type.name}_${widget.sandwich.isFootlong ? 'footlong' : 'six'}'),
      title: Text('Edit ${widget.sandwich.name}', style: heading2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Six-inch', style: normalText),
              Switch(value: _isFootlong, onChanged: (v) => setState(() => _isFootlong = v)),
              const Text('Footlong', style: normalText),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButton<BreadType>(
            value: _breadType,
            items: BreadType.values
                .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _breadType = v);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('edit_item_cancel'),
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const Key('edit_item_save'),
          onPressed: _onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
