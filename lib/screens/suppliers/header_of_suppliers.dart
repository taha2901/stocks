import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/screens/suppliers/add_edit_suppliers_page.dart';
import 'package:management_stock/screens/suppliers/statistics_page.dart';

class ResponsiveHeader extends StatelessWidget {
  const ResponsiveHeader({super.key});

  void _navigateToAddSupplier(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSupplierPage(
          onSave: (supplier) {
            context.read<SupplierCubit>().addSupplier(supplier);
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

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);
    bool isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: Responsive.pagePadding(context),
      child: Row(
        children: [
          if (!isMobile)
            CustomButton(
              text: "الرجوع ل الصفحة الرئيسية",
              icon: Icons.home,
              backgroundColor: Colors.white,
              textColor: Colors.blue,
              borderColor: Colors.blue,
              fullWidth: false,
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),

          CustomButton(
            text: isMobile ? "" : "إحصائيات",
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

          CustomButton(
            text: isMobile ? "" : "مورد جديد",
            icon: Icons.add,
            backgroundColor: Colors.green,
            fullWidth: false,
            onPressed: () => _navigateToAddSupplier(context),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),

          const Spacer(),

          if (isDesktop || isTablet)
            Row(
              children: [
                Text(
                  'قائمة الموردين',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
              ],
            )
          else
            // للهاتف فقط أيقونة بدون نص
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Colors.orange,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}
