
import 'package:flutter/material.dart';

class ProductActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const ProductActions({super.key, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(icon: const Icon(Icons.edit, color: Colors.lightBlueAccent), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
      ],
    );
  }
}