import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_button.dart';

class SupplierErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SupplierErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: "إعادة المحاولة",
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
