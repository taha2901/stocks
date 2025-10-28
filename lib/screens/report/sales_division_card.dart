import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/report/division_row.dart';

class SalesDivisionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const SalesDivisionCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'تقسيم المبيعات',
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          DivisionRow(
            title: 'البيع السريع (POS)',
            value: currencyFormat.format(data['totalPosSales'] ?? 0),
            count: '${data['totalPosTransactions'] ?? 0} فاتورة',
            color: Colors.green,
          ),
          Divider(
            color: Colors.white24,
            height: Responsive.spacing(context, 20),
          ),
          DivisionRow(
            title: 'البيع بالجملة',
            value: currencyFormat.format(data['totalWholesaleSales'] ?? 0),
            count: '${data['totalWholesaleTransactions'] ?? 0} فاتورة',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
