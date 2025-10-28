
// زر التصدير
import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ExportButton({super.key, 
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: Responsive.fontSize(context, 18)),
      label: Text(
        label,
        style: TextStyle(fontSize: Responsive.fontSize(context, 14)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: Responsive.value(
            context: context,
            mobile: 10,
            tablet: 12,
            desktop: 14,
          ),
        ),
      ),
    );
  }
}
