// // models/deferred_account_model.dart
// import 'package:management_stock/models/sales_invoice_model.dart';

// class DeferredAccountModel {
//   final String customerName;
//   final int invoiceCount;
//   final double totalAmount;
//   final double paid;
//   final double remaining;

//   DeferredAccountModel({
//     required this.customerName,
//     required this.invoiceCount,
//     required this.totalAmount,
//     required this.paid,
//     required this.remaining,
//   });

//   factory DeferredAccountModel.fromInvoices(
//       String name, List<SalesInvoiceModel> invoices) {
//     final deferredInvoices =
//         invoices.where((i) => i.paymentType == 'آجل').toList();

//     final total = deferredInvoices.fold<double>(
//         0, (sum, i) => sum + i.totalAfterDiscount);
//     final paid = deferredInvoices.fold<double>(
//         0, (sum, i) => sum + (i.paidNow ?? 0));
//     final remaining = total - paid;

//     return DeferredAccountModel(
//       customerName: name,
//       invoiceCount: deferredInvoices.length,
//       totalAmount: total,
//       paid: paid,
//       remaining: remaining,
//     );
//   }
// }
