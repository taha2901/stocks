
import 'package:flutter/material.dart';

class ProductInfoChip extends StatelessWidget {
  final String? title;
  final String? value;

  const ProductInfoChip({super.key, this.title, this.value});

  @override
  Widget build(BuildContext context) {
    final text = title != null && value != null ? "$title: $value" : (title ?? value ?? "");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
