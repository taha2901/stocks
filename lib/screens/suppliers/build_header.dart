import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/add_edit_suppliers_page.dart';
import 'package:management_stock/screens/suppliers/statistics_page.dart';

class BuildHeader extends StatefulWidget {
  const BuildHeader({super.key});

  @override
  State<BuildHeader> createState() => _BuildHeaderState();
}

class _BuildHeaderState extends State<BuildHeader> {
  List<Supplier> suppliers = List.from(dummySuppliers);
  List<Supplier> filteredSuppliers = List.from(dummySuppliers);
  String searchQuery = '';
  String? cityFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2, color: Colors.orange, size: 28),
        ),
        const SizedBox(width: 12),
        Text(
          'قائمة الموردين',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),

        if (!Responsive.isMobile(context))
          CustomButton(
            text: "إحصائيات",
            icon: Icons.bar_chart,
            backgroundColor: Colors.white,
            textColor: Colors.blue,
            borderColor: Colors.blue,
            fullWidth: false,
            onPressed: () => _navigateToStatistics(context),
            isOutlined: true,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        const SizedBox(width: 12),

        // 🔹 زر مورد جديد
        CustomButton(
          text: Responsive.isMobile(context) ? "" : "مورد جديد",
          icon: Icons.add,
          backgroundColor: Colors.green,
          fullWidth: false,
          onPressed: () => _navigateToAddSupplier(context),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),

        if (!Responsive.isMobile(context)) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.dashboard, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('لوحة التحكم', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _filterSuppliers() {
    setState(() {
      filteredSuppliers = suppliers.where((supplier) {
        final matchesSearch =
            supplier.name.contains(searchQuery) ||
            supplier.phone.contains(searchQuery);
        final matchesCity =
            cityFilter == null || supplier.address.contains(cityFilter!);
        return matchesSearch && matchesCity;
      }).toList();
    });
  }

  void _navigateToAddSupplier(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSupplierPage(
          onSave: (supplier) {
            setState(() {
              suppliers.add(supplier);
              _filterSuppliers();
            });
          },
        ),
      ),
    );
  }

  void _navigateToStatistics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsPage()),
    );
  }
}
