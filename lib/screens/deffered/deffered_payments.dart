import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class DeferredAccountsScreen extends StatefulWidget {
  const DeferredAccountsScreen({super.key});

  @override
  State<DeferredAccountsScreen> createState() => _DeferredAccountsScreenState();
}

class _DeferredAccountsScreenState extends State<DeferredAccountsScreen> {
  final TextEditingController searchController = TextEditingController();

  // 🔹 داتا دامي للعملاء
  final List<Map<String, dynamic>> customers = [
    {
      "name": "سيف الدين طارق محمد",
      "invoiceCount": 5,
      "totalAmount": 4347.00,
      "paid": 1070.00,
      "remaining": 3277.00,
    },
    {
      "name": "علاء محمد",
      "invoiceCount": 1,
      "totalAmount": 5700.00,
      "paid": 700.00,
      "remaining": 5000.00,
    },
    {
      "name": "seif",
      "invoiceCount": 2,
      "totalAmount": 2400.00,
      "paid": 0.00,
      "remaining": 2400.00,
    },
    {
      "name": "مخزن 1",
      "invoiceCount": 2,
      "totalAmount": 6973.00,
      "paid": 874.00,
      "remaining": 6099.00,
    },
  ];

  List<Map<String, dynamic>> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    filteredCustomers = customers;
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers
            .where(
              (customer) => customer['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "حسابات العملاء (آجل)",
              style: TextStyle(
                color: const Color(0xFF1976D2),
                fontSize: Responsive.fontSize(context, 22),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 8)),
            Container(
              padding: EdgeInsets.all(Responsive.spacing(context, 6)),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: Responsive.value(
                  context: context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
            ),
          ],
        ),
        elevation: 2,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.all(Responsive.spacing(context, 8)),
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("رجوع للوحة التحكم ↩️"),
                    backgroundColor: Colors.grey,
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.grey,
                size: Responsive.value(
                  context: context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
              ),
              label: Text(
                "رجوع للوحة التحكم",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: Responsive.fontSize(context, 14),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, 16),
                  vertical: Responsive.spacing(context, 12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: padding,
        child: Column(
          children: [
            SizedBox(height: Responsive.spacing(context, 16)),

            // 🔹 شريط البحث
            _buildSearchBar(context),

            SizedBox(height: Responsive.spacing(context, 20)),

            // 🔹 الجدول
            Expanded(
              child: isMobile
                  ? _buildMobileView()
                  : _buildTableView(context, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  // داخل _buildSearchBar()
  Widget _buildSearchBar(BuildContext context) {
    return CustomInputField(
      controller: searchController,
      label: "بحث باسم العميل",
      hint: "اكتب اسم العميل للبحث...",

      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      onChanged: _filterCustomers,
    );
  }

  // 🔹 عرض الموبايل (Cards)
  Widget _buildMobileView() {
    return ListView.builder(
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return Card(
          margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
          elevation: 2,
          color: const Color(0xFF2C2F48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(Responsive.spacing(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("عرض تفاصيل ${customer['name']}"),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.visibility,
                        color: Color(0xFF1976D2),
                        size: 16,
                      ),
                      label: Text(
                        "عرض",
                        style: TextStyle(
                          color: const Color(0xFF1976D2),
                          fontSize: Responsive.fontSize(context, 13),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1976D2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.spacing(context, 12),
                          vertical: Responsive.spacing(context, 8),
                        ),
                      ),
                    ),
                    Text(
                      customer['name'],
                      style: TextStyle(
                        color:  Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(context, 12)),
                _buildMobileInfoRow(
                  "عدد الفواتير 📋",
                  color:  Colors.white,
                  "${customer['invoiceCount']}",
                ),
                _buildMobileInfoRow(
                  "إجمالي الأجل 💰",
                  color:  Colors.white,
                  "${customer['totalAmount'].toStringAsFixed(2)} جنيه",
                ),
                _buildMobileInfoRow(
                  "المدفوع ✅",
                  "${customer['paid'].toStringAsFixed(2)} جنيه",
                  color: Colors.green,
                ),
                _buildMobileInfoRow(
                  "المتبقي ⚠️",
                  "${customer['remaining'].toStringAsFixed(2)} جنيه",
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? const Color(0xFF2C2F48),
              fontWeight: FontWeight.w500,
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 عرض التابلت والديسكتوب (Table)
  Widget _buildTableView(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس الجدول
          Container(
            padding: EdgeInsets.symmetric(
              vertical: Responsive.spacing(context, 16),
              horizontal: Responsive.spacing(context, 12),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2F48),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeader(context, "تفاصيل 🔍", flex: 1),
                _buildTableHeader(context, "المتبقي ⚠️", flex: 2),
                _buildTableHeader(context, "المدفوع ✅", flex: 2),
                _buildTableHeader(context, "إجمالي الأجل 💰", flex: 2),
                _buildTableHeader(
                  context,
                  "عدد الفواتير 📋",
                  flex: isTablet ? 1 : 2,
                ),
                _buildTableHeader(context, "اسم العميل 👤", flex: 3),
              ],
            ),
          ),

          // محتوى الجدول
          Expanded(
            child: filteredCustomers.isEmpty
                ? Center(
                    child: Text(
                      "لا يوجد عملاء",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: Responsive.fontSize(context, 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.spacing(context, 16),
                            horizontal: Responsive.spacing(context, 12),
                          ),
                          child: Row(
                            children: [
                              // زر عرض
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "عرض تفاصيل ${customer['name']}",
                                          ),
                                          backgroundColor: Colors.blue,
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      color: const Color(0xFF1976D2),
                                      size: Responsive.value(
                                        context: context,
                                        mobile: 16,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                    ),
                                    label: Text(
                                      "عرض",
                                      style: TextStyle(
                                        color: const Color(0xFF1976D2),
                                        fontSize: Responsive.fontSize(
                                          context,
                                          14,
                                        ),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Responsive.spacing(
                                          context,
                                          12,
                                        ),
                                        vertical: Responsive.spacing(
                                          context,
                                          8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // المتبقي
                              _buildTableCell(
                                context,
                                "${customer['remaining'].toStringAsFixed(2)} جنيه",
                                flex: 2,
                                color: Colors.red,
                              ),
                              // المدفوع
                              _buildTableCell(
                                context,
                                "${customer['paid'].toStringAsFixed(2)} جنيه",
                                flex: 2,
                                color: Colors.green,
                              ),
                              // الإجمالي
                              _buildTableCell(
                                context,
                                "${customer['totalAmount'].toStringAsFixed(2)} جنيه",
                                color: Colors.yellow,
                                flex: 2,
                              ),
                              // عدد الفواتير
                              _buildTableCell(
                                context,
                                "${customer['invoiceCount']}",
                                color:  const Color(0xFF1976D2),
                                flex: isTablet ? 1 : 2,
                              ),
                              // اسم العميل
                              _buildTableCell(
                                context,
                                customer['name'],
                                flex: 3,
                                color:   Colors.white,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(
    BuildContext context,
    String text, {
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 14),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    BuildContext context,
    String text, {
    required int flex,
    Color? color,
    bool isBold = false,
  }) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color ?? const Color(0xFF2C2F48),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: Responsive.fontSize(context, 14),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
