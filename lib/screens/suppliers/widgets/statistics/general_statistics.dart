import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/state_card.dart';

class GeneralStatisticsSection extends StatelessWidget {
  final int totalSuppliers;
  final int filteredSuppliers;
  final int citiesCount;

  const GeneralStatisticsSection({
    super.key,
    required this.totalSuppliers,
    required this.filteredSuppliers,
    required this.citiesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات عامة',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        StateCard(
          icon: Icons.inventory_2,
          iconColor: Colors.orange,
          label: 'عدد الموردين الكلي',
          value: totalSuppliers.toString(),
        ),
        const SizedBox(height: 16),
        StateCard(
          icon: Icons.search,
          iconColor: Colors.blue,
          label: 'عدد الموردين بعد التصفية',
          value: filteredSuppliers.toString(),
        ),
        const SizedBox(height: 16),
        StateCard(
          icon: Icons.location_city,
          iconColor: Colors.teal,
          label: 'عدد المدن المختلفة',
          value: citiesCount.toString(),
        ),
      ],
    );
  }
}
