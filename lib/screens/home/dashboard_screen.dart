import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/screens/home/widgets/dashbord_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    // ✅ استخدم DashboardCard بدل _DashboardItem
    final List<Map<String, dynamic>> items = [
      {
        "title": "إدارة المنتجات",
        "icon": Icons.inventory_2_outlined,
        "route": Routers.productRoute,
      },
      {
        "title": "إدارة العملاء",
        "icon": Icons.people_outline,
        "route": Routers.customersRoute,
      },
      {
        "title": "إدارة الموردين",
        "icon": Icons.handshake_outlined,
        "route": Routers.suppliersRoute,
      },
      {
        "title": "إضافة فاتورة شراء",
        "icon": Icons.receipt_long_outlined,
        "route": Routers.purchaseInvoiceRoute,
      },
      {
        "title": "إنشاء فاتورة بيع",
        "icon": Icons.point_of_sale_outlined,
        "route": Routers.salesInvoiceRoute,
      },
      {
        "title": "البيع السريع (POS)",
        "icon": Icons.qr_code_scanner_outlined,
        "route": Routers.quickSaleRoute,
      },
      {
        "title": "إدارة الفواتير الأجلة",
        "icon": Icons.description_outlined,
        "route": Routers.deferredAccountsRoute,
      },
      {
        "title": "تقارير المبيعات",
        "icon": Icons.show_chart_outlined,
        "route": null, // لسه هيتعمل لاحقًا
      },
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(
          "taha@se.co (admin)",
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  "أهلاً، الأسطورة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(context, 16),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.person, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: ResponsiveLayout(
                mobile: _buildMobileList(items, context),
                tablet: _buildGrid(items, crossAxisCount: 2, context: context),
                desktop: _buildGrid(items, crossAxisCount: 3, context: context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 ListView للموبايل
  Widget _buildMobileList(List<Map<String, dynamic>> items, BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardCard(
          title: item["title"],
          icon: item["icon"],
          onTap: item["route"] != null
              ? () => Navigator.pushNamed(context, item["route"])
              : null,
        );
      },
    );
  }

  // 🔹 Grid للتابلت والويب
  Widget _buildGrid(
    List<Map<String, dynamic>> items, {
    required int crossAxisCount,
    required BuildContext context,
  }) {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: Responsive.spacing(context, 20),
        mainAxisSpacing: Responsive.spacing(context, 20),
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardCard(
          title: item["title"],
          icon: item["icon"],
          onTap: item["route"] != null
              ? () => Navigator.pushNamed(context, item["route"])
              : null,
        );
      },
    );
  }
}