import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_button.dart';

class POSActionButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onCheckout;
  final bool hasCart;

  const POSActionButtons({
    super.key,
    required this.onBack,
    required this.onCheckout,
    required this.hasCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "عودة",
            icon: Icons.arrow_forward,
            backgroundColor: Colors.blueAccent,
            fullWidth: true,
            onPressed: onBack,
          ),
        ),
        const SizedBox(width: 12),
        if (hasCart)
          Expanded(
            child: CustomButton(
              text: "إتمام البيع",
              icon: Icons.check_circle,
              backgroundColor: Colors.green,
              fullWidth: true,
              onPressed: onCheckout,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: "تسجيل خروج",
            icon: Icons.exit_to_app,
            backgroundColor: const Color(0xFFE57373),
            fullWidth: true,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم تسجيل الخروج 🚪")),
            ),
          ),
        ),
      ],
    );
  }
}
