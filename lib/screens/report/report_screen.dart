import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/report/cubit.dart';
import 'package:management_stock/cubits/report/states.dart';
import 'package:management_stock/screens/report/widgets/error_widget.dart';
import 'package:management_stock/screens/report/widgets/inventory_report_widget.dart';
import 'package:management_stock/screens/report/widgets/period_button.dart';
import 'package:management_stock/screens/report/widgets/prints/inventory_print.dart';
import 'package:management_stock/screens/report/widgets/prints/profir_report_print.dart';
import 'package:management_stock/screens/report/widgets/prints/sales_report_print.dart';
import 'package:management_stock/screens/report/widgets/profile_report_widget.dart';
import 'package:management_stock/screens/report/widgets/report_tab.dart';
import 'package:management_stock/screens/report/widgets/sales_report_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int selectedReportTab = 0;
  DateTime? startDate;
  DateTime? endDate;
  String selectedPeriod = 'اليوم';

  @override
  void initState() {
    super.initState();
    _setDateRange(selectedPeriod);
    _loadReports();
  }

  void _setDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      selectedPeriod = period;
      switch (period) {
        case 'اليوم':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'الأسبوع':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          endDate = now;
          break;
        case 'الشهر':
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
        case 'السنة':
          startDate = DateTime(now.year, 1, 1);
          endDate = now;
          break;
        case 'الكل':
          startDate = null;
          endDate = null;
          break;
      }
    });
  }

  void _loadReports() {
    context.read<ReportsCubit>().fetchAllReports(
          startDate: startDate,
          endDate: endDate,
        );
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              surface: Color(0xFF2C2F48),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedPeriod = 'مخصص';
        startDate = picked.start;
        endDate = picked.end;
      });
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPrintButton(), // 🔥 زر الطباعة
          _buildPeriodFilter(),
          _buildReportTabs(),
          Expanded(child: _buildReportBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2C2F48),
      automaticallyImplyLeading: false,
      title: ResponsiveLayout(
        mobile: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.blue),
              onPressed: () => Navigator.pop(context),
              tooltip: 'الرجوع للصفحة الرئيسية',
            ),
            Expanded(
              child: Text(
                'التقارير 📊',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 20),
            ),
          ],
        ),
        tablet: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              text: "الرجوع للصفحة الرئيسية",
              icon: Icons.home,
              backgroundColor: Colors.white,
              textColor: Colors.blue,
              borderColor: Colors.blue,
              fullWidth: false,
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
            ),
            const SizedBox(width: 16),
            const Text(
              'التقارير 📊',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 زر الطباعة
  Widget _buildPrintButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _handlePrint,
            icon: const Icon(Icons.print, size: 20),
            label: Text(
              'طباعة التقرير',
              style: TextStyle(fontSize: Responsive.fontSize(context, 16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrint() {
    final state = context.read<ReportsCubit>().state;
    if (state is! AllReportsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد بيانات للطباعة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedReportTab == 0) {
      // تقرير المبيعات
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SalesReportPrintWidget(
            data: state.salesReport,
            period: selectedPeriod,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      );
    } else if (selectedReportTab == 1) {
      // تقرير المخزون
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InventoryReportPrintWidget(
            data: state.inventoryReport,
            period: selectedPeriod,
          ),
        ),
      );
    } else if (selectedReportTab == 2) {
      // تقرير الأرباح
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfitReportPrintWidget(
            data: state.profitReport,
            period: selectedPeriod,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      );
    }
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: Responsive.pagePadding(context),
      color: const Color(0xFF2C2F48),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PeriodButton(
              label: 'مخصص',
              icon: Icons.date_range,
              isSelected: selectedPeriod == 'مخصص',
              onPressed: _selectCustomDateRange,
            ),
            SizedBox(width: Responsive.spacing(context, 8)),
            PeriodButton(
              label: 'الكل',
              icon: Icons.all_inclusive,
              isSelected: selectedPeriod == 'الكل',
              onPressed: () {
                _setDateRange('الكل');
                _loadReports();
              },
            ),
            SizedBox(width: Responsive.spacing(context, 8)),
            PeriodButton(
              label: 'السنة',
              icon: Icons.calendar_today,
              isSelected: selectedPeriod == 'السنة',
              onPressed: () {
                _setDateRange('السنة');
                _loadReports();
              },
            ),
            SizedBox(width: Responsive.spacing(context, 8)),
            PeriodButton(
              label: 'الشهر',
              icon: Icons.calendar_view_month,
              isSelected: selectedPeriod == 'الشهر',
              onPressed: () {
                _setDateRange('الشهر');
                _loadReports();
              },
            ),
            SizedBox(width: Responsive.spacing(context, 8)),
            PeriodButton(
              label: 'الأسبوع',
              icon: Icons.calendar_view_week,
              isSelected: selectedPeriod == 'الأسبوع',
              onPressed: () {
                _setDateRange('الأسبوع');
                _loadReports();
              },
            ),
            SizedBox(width: Responsive.spacing(context, 8)),
            PeriodButton(
              label: 'اليوم',
              icon: Icons.today,
              isSelected: selectedPeriod == 'اليوم',
              onPressed: () {
                _setDateRange('اليوم');
                _loadReports();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTabs() {
    return Container(
      color: const Color(0xFF2C2F48),
      padding: Responsive.value(
        context: context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ReportTab(
              label: 'الأرباح 💰',
              index: 2,
              isSelected: selectedReportTab == 2,
              onPressed: () => setState(() => selectedReportTab = 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ReportTab(
              label: 'المخزون 📦',
              index: 1,
              isSelected: selectedReportTab == 1,
              onPressed: () => setState(() => selectedReportTab = 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ReportTab(
              label: 'المبيعات 📈',
              index: 0,
              isSelected: selectedReportTab == 0,
              onPressed: () => setState(() => selectedReportTab = 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportBody() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        if (state is ReportsError) {
          return ErrorButton(
            error: state.error,
            onRetry: _loadReports,
          );
        }

        if (state is AllReportsLoaded) {
          return SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: Column(
              children: [
                if (selectedReportTab == 0) SalesReportWidget(data: state.salesReport),
                if (selectedReportTab == 1) InventoryReportWidget(data: state.inventoryReport),
                if (selectedReportTab == 2) ProfitReportWidget(data: state.profitReport),
              ],
            ),
          );
        }

        return const Center(
          child: Text(
            'اضغط على تحديث لتحميل التقارير',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        );
      },
    );
  }
}