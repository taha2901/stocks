
// صف التقسيم
import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart' show Responsive;

class DivisionRow extends StatelessWidget {
  final String title;
  final String value;
  final String count;
  final Color color;

  const DivisionRow({super.key, 
    required this.title,
    required this.value,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.spacing(context, 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 4)),
              Text(
                count,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: Responsive.fontSize(context, 12),
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }
}
