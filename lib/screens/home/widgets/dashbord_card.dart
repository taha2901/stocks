import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F48),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              icon,
              color: Colors.blueAccent,
              size: Responsive.fontSize(context, 28),
            ),
          ],
        ),
      ),
    );
  }
}
