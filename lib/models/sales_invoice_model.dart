import 'package:management_stock/models/sales_invoice_item.dart';

class SalesInvoiceModel {
  String? supplier;
  String? paymentType;
  DateTime? invoiceDate;
  List<SalesInvoiceItem> items;
  double discount;

  SalesInvoiceModel({
    this.supplier,
    this.paymentType,
    this.invoiceDate,
    List<SalesInvoiceItem>? items,
    this.discount = 0,
  }) : items = items ?? [];

  double get totalBeforeDiscount =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double get totalAfterDiscount => totalBeforeDiscount - discount;

  Map<String, dynamic> toMap() {
    return {
      'supplier': supplier,
      'paymentType': paymentType,
      'invoiceDate': invoiceDate?.toIso8601String(),
      'discount': discount,
      'totalBeforeDiscount': totalBeforeDiscount,
      'totalAfterDiscount': totalAfterDiscount,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
