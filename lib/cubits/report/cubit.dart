import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/reports/report_Services.dart';
import 'package:management_stock/cubits/report/states.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsServices _services;

  ReportsCubit(this._services) : super(ReportsInitial());

  Map<String, dynamic>? _salesReport;
  Map<String, dynamic>? _inventoryReport;
  Map<String, dynamic>? _profitReport;

  Map<String, dynamic>? get salesReport => _salesReport;
  Map<String, dynamic>? get inventoryReport => _inventoryReport;
  Map<String, dynamic>? get profitReport => _profitReport;

  Future<void> fetchSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(ReportsLoading());
    try {
      final report = await _services.getSalesReport(
        startDate: startDate,
        endDate: endDate,
      );
      _salesReport = report;
      emit(SalesReportLoaded(report));
    } catch (e) {
      emit(ReportsError('❌ فشل في تحميل تقرير المبيعات: $e'));
    }
  }

  Future<void> fetchInventoryReport() async {
    emit(ReportsLoading());
    try {
      final report = await _services.getInventoryReport();
      _inventoryReport = report;
      emit(InventoryReportLoaded(report));
    } catch (e) {
      emit(ReportsError('❌ فشل في تحميل تقرير المخزون: $e'));
    }
  }

  Future<void> fetchProfitReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(ReportsLoading());
    try {
      final report = await _services.getProfitReport(
        startDate: startDate,
        endDate: endDate,
      );
      _profitReport = report;
      emit(ProfitReportLoaded(report));
    } catch (e) {
      emit(ReportsError('❌ فشل في تحميل تقرير الأرباح: $e'));
    }
  }

  Future<void> fetchAllReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(ReportsLoading());
    try {
      final salesReport = await _services.getSalesReport(
        startDate: startDate,
        endDate: endDate,
      );
      final inventoryReport = await _services.getInventoryReport();
      final profitReport = await _services.getProfitReport(
        startDate: startDate,
        endDate: endDate,
      );

      _salesReport = salesReport;
      _inventoryReport = inventoryReport;
      _profitReport = profitReport;

      emit(AllReportsLoaded(
        salesReport: salesReport,
        inventoryReport: inventoryReport,
        profitReport: profitReport,
      ));
    } catch (e) {
      emit(ReportsError('❌ فشل في تحميل التقارير: $e'));
    }
  }
}