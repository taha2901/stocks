
// تاب التقرير
import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';

class ReportTab extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onPressed;

  const ReportTab({super.key, 
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: label,
      textColor: isSelected ? Colors.white : Colors.white70,
      backgroundColor: isSelected ? Colors.blueAccent : Colors.transparent,
      fontSize: Responsive.fontSize(context, isSelected ? 16 : 14),
      borderColor: isSelected ? Colors.blueAccent : Colors.white30,
      onPressed: onPressed,
    );
  }
}
