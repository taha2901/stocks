import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/city_row.dart';

class CitiesDistributionSection extends StatelessWidget {
  final List<MapEntry<String, int>> sortedCities;

  const CitiesDistributionSection({
    super.key,
    required this.sortedCities,
  });

  @override
  Widget build(BuildContext context) {
    if (sortedCities.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.pink),
            const SizedBox(width: 8),
            Text(
              'توزيع الموردين حسب المدينة:',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...sortedCities.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CityRow(
              city: entry.key,
              count: entry.value,
            ),
          ),
        ),
      ],
    );
  }
}
