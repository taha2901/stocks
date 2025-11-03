
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final Map<String, dynamic>? categoryCount;
  final Map<String, dynamic>? categoryValue;

  const CategoryBreakdownCard({super.key, 
    required this.categoryCount,
    required this.categoryValue,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryCount == null || categoryCount!.isEmpty) {
      return const SizedBox.shrink();
    }

    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);

    return Container(
      padding: EdgeInsets.all(Responsive.value(
        context: context,
        mobile: 12,
        tablet: 16,
        desktop: 20,
      )),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'المخزون حسب الفئة 📂',
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          ...categoryCount!.entries.map((entry) {
            final category = entry.key;
            final count = entry.value;
            final value = categoryValue?[category] ?? 0;

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
                        '$count منتج',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: Responsive.fontSize(context, 12),
                        ),
                      ),
                      Text(
                        currencyFormat.format(value),
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
