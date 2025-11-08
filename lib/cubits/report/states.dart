abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class SalesReportLoaded extends ReportsState {
  final Map<String, dynamic> reportData;
  
  SalesReportLoaded(this.reportData);
}

class InventoryReportLoaded extends ReportsState {
  final Map<String, dynamic> reportData;
  
  InventoryReportLoaded(this.reportData);
}

class ProfitReportLoaded extends ReportsState {
  final Map<String, dynamic> reportData;
  
  ProfitReportLoaded(this.reportData);
}

class AllReportsLoaded extends ReportsState {
  final Map<String, dynamic> salesReport;
  final Map<String, dynamic> inventoryReport;
  final Map<String, dynamic> profitReport;
  
  AllReportsLoaded({
    required this.salesReport,
    required this.inventoryReport,
    required this.profitReport,
  });
}

class ReportsError extends ReportsState {
  final String error;
  
  ReportsError(this.error);
}