import 'package:management_stock/models/purchase/purchase_invoice_item.dart';

abstract class PurchaseInvoiceState {}

class PurchaseInvoiceInitial extends PurchaseInvoiceState {}

class PurchaseInvoiceLoading extends PurchaseInvoiceState {}

class PurchaseInvoiceSuccess extends PurchaseInvoiceState {
  final String message;
  PurchaseInvoiceSuccess(this.message);
}

class PurchaseInvoiceLoaded extends PurchaseInvoiceState {
  final List<PurchaseInvoiceModel> invoices;
  PurchaseInvoiceLoaded(this.invoices);
}

class PurchaseInvoiceError extends PurchaseInvoiceState {
  final String message;
  PurchaseInvoiceError(this.message);
}