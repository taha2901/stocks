// كارت الإحصائية
import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        Responsive.value(context: context, mobile: 12, tablet: 16, desktop: 20),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: Responsive.value(
              context: context,
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: Responsive.fontSize(context, 12),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.spacing(context, 4)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: Responsive.fontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
