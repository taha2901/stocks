import 'package:management_stock/models/sales/sales_invoice_model.dart';

abstract class SalesInvoiceState {}

class SalesInvoiceInitial extends SalesInvoiceState {}

class SalesInvoiceLoading extends SalesInvoiceState {}

class SalesInvoiceSuccess extends SalesInvoiceState {
  final String message;
  SalesInvoiceSuccess(this.message);
}

class SalesInvoiceLoaded extends SalesInvoiceState {
  final List<SalesInvoiceModel> invoices;
  SalesInvoiceLoaded(this.invoices);
}

class SalesInvoiceError extends SalesInvoiceState {
  final String error;
  SalesInvoiceError(this.error);
}
