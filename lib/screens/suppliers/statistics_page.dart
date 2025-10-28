import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/cubits/suppliers/states.dart';
import 'package:management_stock/screens/suppliers/city_row.dart';
import 'package:management_stock/screens/suppliers/state_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    // جلب الإحصائيات عند فتح الصفحة
    context.read<SupplierCubit>().fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue),
              SizedBox(width: 8),
              Text('إحصائيات الموردين', style: TextStyle(color: Colors.white)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<SupplierCubit, SupplierState>(
          builder: (context, state) {
            if (state is SupplierStatisticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SupplierStatisticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SupplierCubit>().fetchStatistics();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is SupplierStatisticsLoaded) {
              final sortedCities = state.cityCount.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return SingleChildScrollView(
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
                          value: state.totalSuppliers.toString(),
                        ),
                        const SizedBox(height: 16),
                        StateCard(
                          icon: Icons.search,
                          iconColor: Colors.blue,
                          label: 'عدد الموردين بعد التصفية',
                          value: state.filteredSuppliers.toString(),
                        ),
                        const SizedBox(height: 16),
                        StateCard(
                          icon: Icons.location_city,
                          iconColor: Colors.teal,
                          label: 'عدد المدن المختلفة',
                          value: state.cityCount.length.toString(),
                        ),
                        if (sortedCities.isNotEmpty) ...[
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
                      ],
                    ),
                  ),
                ),
              );
            }

            // حالة افتراضية - محاولة جلب البيانات
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}