import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_stock/models/sales/sales_invoice_item.dart';
import 'package:uuid/uuid.dart';

class SalesInvoiceModel {
  String id;
  String? customerId; // بدل supplier هتبقى customerId
  String? customerName;
  String? paymentType;
  DateTime? invoiceDate;
  List<SalesInvoiceItem> items;
  double discount;
  
  // للدفع الآجل
  double paidNow;
  double interestRate;
  
  SalesInvoiceModel({
    String? id,
    this.customerId,
    this.customerName,
    this.paymentType,
    this.invoiceDate,
    List<SalesInvoiceItem>? items,
    this.discount = 0,
    this.paidNow = 0,
    this.interestRate = 0,
  })  : id = id ?? const Uuid().v4(),
        items = items ?? [];

  double get totalBeforeDiscount =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double get totalAfterDiscount => totalBeforeDiscount - discount;

  double get totalAfterInterest =>
      totalAfterDiscount + (totalAfterDiscount * interestRate / 100);

  double get remaining => totalAfterInterest - paidNow;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'paymentType': paymentType,
      'invoiceDate': invoiceDate?.toIso8601String(),
      'discount': discount,
      'paidNow': paidNow,
      'interestRate': interestRate,
      'totalBeforeDiscount': totalBeforeDiscount,
      'totalAfterDiscount': totalAfterDiscount,
      'totalAfterInterest': totalAfterInterest,
      'remaining': remaining,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory SalesInvoiceModel.fromMap(Map<String, dynamic> map) {
    return SalesInvoiceModel(
      id: map['id'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      paymentType: map['paymentType'],
      invoiceDate: map['invoiceDate'] != null
          ? DateTime.parse(map['invoiceDate'])
          : null,
      discount: map['discount']?.toDouble() ?? 0,
      paidNow: map['paidNow']?.toDouble() ?? 0,
      interestRate: map['interestRate']?.toDouble() ?? 0,
      items: (map['items'] as List?)
              ?.map((item) => SalesInvoiceItem.fromMap(item))
              .toList() ??
          [],
    );
  }
}