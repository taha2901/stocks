class DeferredAccountModel {
  final String customerId;
  final String customerName;
  final int invoiceCount;
  final double totalAmount;
  final double paid;
  final double remaining;
  final List<DeferredInvoice> invoices;

  DeferredAccountModel({
    required this.customerId,
    required this.customerName,
    this.invoiceCount = 0,
    this.totalAmount = 0,
    this.paid = 0,
    this.remaining = 0,
    List<DeferredInvoice>? invoices,
  }) : invoices = invoices ?? [];

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'invoiceCount': invoiceCount,
      'totalAmount': totalAmount,
      'paid': paid,
      'remaining': remaining,
      'invoices': invoices.map((e) => e.toMap()).toList(),
    };
  }

  factory DeferredAccountModel.fromMap(Map<String, dynamic> map) {
    return DeferredAccountModel(
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      invoiceCount: map['invoiceCount']?.toInt() ?? 0,
      totalAmount: map['totalAmount']?.toDouble() ?? 0,
      paid: map['paid']?.toDouble() ?? 0,
      remaining: map['remaining']?.toDouble() ?? 0,
      invoices: (map['invoices'] as List?)
              ?.map((e) => DeferredInvoice.fromMap(e))
              .toList() ??
          [],
    );
  }
}

class DeferredInvoice {
  final String invoiceId;
  final DateTime invoiceDate;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final double interestRate;
  final List<PaymentRecord> payments;

  DeferredInvoice({
    required this.invoiceId,
    required this.invoiceDate,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.remainingAmount,
    this.interestRate = 0,
    List<PaymentRecord>? payments,
  }) : payments = payments ?? [];

  Map<String, dynamic> toMap() {
    return {
      'invoiceId': invoiceId,
      'invoiceDate': invoiceDate.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'interestRate': interestRate,
      'payments': payments.map((e) => e.toMap()).toList(),
    };
  }

  factory DeferredInvoice.fromMap(Map<String, dynamic> map) {
    return DeferredInvoice(
      invoiceId: map['invoiceId'] ?? '',
      invoiceDate: map['invoiceDate'] != null
          ? DateTime.parse(map['invoiceDate'])
          : DateTime.now(),
      totalAmount: map['totalAmount']?.toDouble() ?? 0,
      paidAmount: map['paidAmount']?.toDouble() ?? 0,
      remainingAmount: map['remainingAmount']?.toDouble() ?? 0,
      interestRate: map['interestRate']?.toDouble() ?? 0,
      payments: (map['payments'] as List?)
              ?.map((e) => PaymentRecord.fromMap(e))
              .toList() ??
          [],
    );
  }
}

class PaymentRecord {
  final String id;
  final DateTime paymentDate;
  final double amount;
  final String paymentMethod;
  final String? notes;

  PaymentRecord({
    required this.id,
    required this.paymentDate,
    required this.amount,
    this.paymentMethod = 'كاش',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paymentDate': paymentDate.toIso8601String(),
      'amount': amount,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] ?? '',
      paymentDate: map['paymentDate'] != null
          ? DateTime.parse(map['paymentDate'])
          : DateTime.now(),
      amount: map['amount']?.toDouble() ?? 0,
      paymentMethod: map['paymentMethod'] ?? 'كاش',
      notes: map['notes'],
    );
  }
}
