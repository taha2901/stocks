import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/services/export_services.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/report/cubit.dart';
import 'package:management_stock/cubits/report/states.dart';
import 'package:management_stock/screens/report/error_widget.dart';
import 'package:management_stock/screens/report/export_button.dart';
import 'package:management_stock/screens/report/inventory_report_widget.dart';
import 'package:management_stock/screens/report/period_button.dart';
import 'package:management_stock/screens/report/profile_report_widget.dart';
import 'package:management_stock/screens/report/report_tab.dart';
import 'package:management_stock/screens/report/sales_report_widget.dart';
import 'package:open_file/open_file.dart';

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
          _buildExportButtons(),
          _buildPeriodFilter(),
          _buildReportTabs(),
          Expanded(child: _buildReportBody()),
        ],
      ),
    );
  }

  // ==================== AppBar ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
          const Spacer(),
          Text(
            'التقارير والإحصائيات 📊',
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.fontSize(context, 20),
            ),
          ),
          const SizedBox(width: 8),
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
      backgroundColor: const Color(0xFF2C2F48),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadReports,
        ),
      ],
    );
  }

  // ==================== Export Buttons ====================
  Widget _buildExportButtons() {
    final isDesktop = Responsive.isDesktop(context);
    
    return Container(
      color: const Color(0xFF2C2F48),
      padding: Responsive.value(
        context: context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ExportButton(
              label: 'تصدير CSV',
              icon: Icons.table_chart,
              color: Colors.green,
              onPressed: _exportToCSV,
            ),
          ),
          SizedBox(width: Responsive.spacing(context, 12)),
          Expanded(
            child: ExportButton(
              label: 'تصدير PDF',
              icon: Icons.picture_as_pdf,
              color: Colors.redAccent,
              onPressed: _exportToPDF,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Period Filter ====================
  Widget _buildPeriodFilter() {
    return Container(
      color: const Color(0xFF2C2F48),
      padding: Responsive.value(
        context: context,
        mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PeriodButton(
              label: 'مخصص',
              icon: Icons.date_range,
              isSelected: selectedPeriod == 'مخصص',
              onPressed: _selectCustomDateRange,
            ),
            const SizedBox(width: 8),
            PeriodButton(
              label: 'الكل',
              icon: Icons.all_inclusive,
              isSelected: selectedPeriod == 'الكل',
              onPressed: () {
                _setDateRange('الكل');
                _loadReports();
              },
            ),
            const SizedBox(width: 8),
            PeriodButton(
              label: 'السنة',
              icon: Icons.calendar_today,
              isSelected: selectedPeriod == 'السنة',
              onPressed: () {
                _setDateRange('السنة');
                _loadReports();
              },
            ),
            const SizedBox(width: 8),
            PeriodButton(
              label: 'الشهر',
              icon: Icons.calendar_month,
              isSelected: selectedPeriod == 'الشهر',
              onPressed: () {
                _setDateRange('الشهر');
                _loadReports();
              },
            ),
            const SizedBox(width: 8),
            PeriodButton(
              label: 'الأسبوع',
              icon: Icons.calendar_view_week,
              isSelected: selectedPeriod == 'الأسبوع',
              onPressed: () {
                _setDateRange('الأسبوع');
                _loadReports();
              },
            ),
            const SizedBox(width: 8),
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

  // ==================== Report Tabs ====================
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

  // ==================== Report Body ====================
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
                if (selectedReportTab == 0)
                  SalesReportWidget(data: state.salesReport),
                if (selectedReportTab == 1)
                  InventoryReportWidget(data: state.inventoryReport),
                if (selectedReportTab == 2)
                  ProfitReportWidget(data: state.profitReport),
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

  // ==================== Export Functions ====================
  Future<void> _exportToCSV() async {
    try {
      final exportService = ExportServicesImpl();
      String? filePath;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );

      if (selectedReportTab == 0) {
        final salesReport = context.read<ReportsCubit>().salesReport;
        if (salesReport != null) {
          filePath = await exportService.exportSalesReportToCSV(salesReport);
        }
      } else if (selectedReportTab == 1) {
        final inventoryReport = context.read<ReportsCubit>().inventoryReport;
        if (inventoryReport != null) {
          filePath = await exportService.exportInventoryReportToCSV(inventoryReport);
        }
      } else if (selectedReportTab == 2) {
        final profitReport = context.read<ReportsCubit>().profitReport;
        if (profitReport != null) {
          filePath = await exportService.exportProfitReportToCSV(profitReport);
        }
      }

      Navigator.pop(context);

      if (filePath != null) {
        final result = await OpenFile.open(filePath);
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم التصدير والفتح بنجاح! ✅', textAlign: TextAlign.right),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التصدير: $e', textAlign: TextAlign.right),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final exportService = ExportServicesImpl();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );

      if (selectedReportTab == 0) {
        final salesReport = context.read<ReportsCubit>().salesReport;
        if (salesReport != null) {
          await exportService.exportSalesReportToPDF(salesReport, selectedPeriod);
        }
      } else if (selectedReportTab == 1) {
        final inventoryReport = context.read<ReportsCubit>().inventoryReport;
        if (inventoryReport != null) {
          await exportService.exportInventoryReportToPDF(inventoryReport);
        }
      } else if (selectedReportTab == 2) {
        final profitReport = context.read<ReportsCubit>().profitReport;
        if (profitReport != null) {
          await exportService.exportProfitReportToPDF(profitReport, selectedPeriod);
        }
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم فتح PDF! 📄', textAlign: TextAlign.right),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التصدير: $e', textAlign: TextAlign.right),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
