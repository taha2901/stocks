import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/city_row.dart';
import 'package:management_stock/screens/suppliers/state_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final suppliers = dummySuppliers;
    final totalSuppliers = suppliers.length;

    // Count suppliers by city
    final cityCount = <String, int>{};
    for (var supplier in suppliers) {
      cityCount[supplier.address] = (cityCount[supplier.address] ?? 0) + 1;
    }

    final sortedCities = cityCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue),
              SizedBox(width: 8),
              Text('إحصائيات', style: TextStyle(color: Colors.white)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Responsive.value(
                  context: context,
                  mobile: double.infinity,
                  tablet: 700,
                  desktop: 900,
                ),
              ),
              child: Column(
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
                    value: totalSuppliers.toString(),
                  ),
                  const SizedBox(height: 16),
                  StateCard(
                    icon: Icons.location_city,
                    iconColor: Colors.teal,
                    label: 'عدد المدن المختلفة',
                    value: cityCount.length.toString(),
                  ),
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
                      child: CityRow(city: entry.key, count: entry.value),
                    ),
                  ),
                  const SizedBox(height: 32),
                  StateCard(
                    icon: Icons.trending_up,
                    iconColor: Colors.green,
                    label: 'أكثر مدينة بها موردين',
                    value:
                        '${sortedCities.first.key} (${sortedCities.first.value})',
                  ),
                  const SizedBox(height: 16),
                  StateCard(
                    icon: Icons.trending_down,
                    iconColor: Colors.red,
                    label: 'أقل مدينة بها موردين',
                    value:
                        '${sortedCities.last.key} (${sortedCities.last.value})',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
