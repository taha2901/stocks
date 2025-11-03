
// زر الفترة الزمنية
import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class PeriodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  // ignore: use_key_in_widget_constructors
  const PeriodButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blueAccent : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : Colors.white70,
        side: BorderSide(
          color: isSelected ? Colors.blueAccent : Colors.white30,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.value(
            context: context,
            mobile: 10,
            tablet: 12,
            desktop: 14,
          ),
          vertical: 8,
        ),
      ),
    );
  }
}
