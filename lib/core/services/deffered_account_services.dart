import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/models/deffered/defferred_account_model.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';

abstract class DeferredAccountServices {
  Future<List<DeferredAccountModel>> getDeferredAccounts();
  Future<DeferredAccountModel> getCustomerDeferredAccount(String customerId);
  Future<void> addPaymentToInvoice({
    required String customerId,
    required String invoiceId,
    required PaymentRecord payment,
  });
  Future<void> updateDeferredAccount(DeferredAccountModel account);
  Stream<List<DeferredAccountModel>> deferredAccountsStream();
}

class DeferredAccountServicesImpl implements DeferredAccountServices {
  final _firestore = FirestoreServices.instance;

  @override
  Future<List<DeferredAccountModel>> getDeferredAccounts() async {
    // جلب جميع فواتير البيع الآجل
    final salesInvoices = await _firestore.getCollection<SalesInvoiceModel>(
      path: ApiPaths.salesInvoices(),
      builder: (data, documentId) =>
          SalesInvoiceModel.fromMap({...data, 'id': documentId}),
      queryBuilder: (query) =>
          query.where('paymentType', isEqualTo: 'آجل'),
    );

    // تجميع الفواتير حسب العميل
    final Map<String, List<SalesInvoiceModel>> customerInvoices = {};
    for (var invoice in salesInvoices) {
      if (invoice.customerId != null) {
        customerInvoices.putIfAbsent(invoice.customerId!, () => []);
        customerInvoices[invoice.customerId]!.add(invoice);
      }
    }

    // إنشاء حسابات آجلة لكل عميل
    final List<DeferredAccountModel> accounts = [];
    for (var entry in customerInvoices.entries) {
      final customerId = entry.key;
      final invoices = entry.value;

      double totalAmount = 0;
      double totalPaid = 0;
      List<DeferredInvoice> deferredInvoices = [];

      for (var invoice in invoices) {
        totalAmount += invoice.totalAfterInterest;
        totalPaid += invoice.paidNow;

        deferredInvoices.add(DeferredInvoice(
          invoiceId: invoice.id,
          invoiceDate: invoice.invoiceDate ?? DateTime.now(),
          totalAmount: invoice.totalAfterInterest,
          paidAmount: invoice.paidNow,
          remainingAmount: invoice.remaining,
          interestRate: invoice.interestRate,
          payments: [
            if (invoice.paidNow > 0)
              PaymentRecord(
                id: 'initial_${invoice.id}',
                paymentDate: invoice.invoiceDate ?? DateTime.now(),
                amount: invoice.paidNow,
                paymentMethod: 'كاش',
              ),
          ],
        ));
      }

      accounts.add(DeferredAccountModel(
        customerId: customerId,
        customerName: invoices.first.customerName ?? 'غير معروف',
        invoiceCount: invoices.length,
        totalAmount: totalAmount,
        paid: totalPaid,
        remaining: totalAmount - totalPaid,
        invoices: deferredInvoices,
      ));
    }

    return accounts;
  }

  @override
  Future<DeferredAccountModel> getCustomerDeferredAccount(
      String customerId) async {
    final accounts = await getDeferredAccounts();
    return accounts.firstWhere(
      (account) => account.customerId == customerId,
      orElse: () => DeferredAccountModel(
        customerId: customerId,
        customerName: 'غير معروف',
      ),
    );
  }

  @override
  Future<void> addPaymentToInvoice({
    required String customerId,
    required String invoiceId,
    required PaymentRecord payment,
  }) async {
    // جلب الفاتورة
    final invoice = await _firestore.getDocument<SalesInvoiceModel>(
      path: ApiPaths.salesInvoice(invoiceId),
      builder: (data, docId) =>
          SalesInvoiceModel.fromMap({...data, 'id': docId}),
    );

    // تحديث المبلغ المدفوع
    final updatedInvoice = SalesInvoiceModel(
      id: invoice.id,
      customerId: invoice.customerId,
      customerName: invoice.customerName,
      paymentType: invoice.paymentType,
      invoiceDate: invoice.invoiceDate,
      items: invoice.items,
      discount: invoice.discount,
      paidNow: invoice.paidNow + payment.amount,
      interestRate: invoice.interestRate,
    );

    // حفظ التحديث
    await _firestore.setData(
      path: ApiPaths.salesInvoice(invoiceId),
      data: updatedInvoice.toMap(),
    );

    // حفظ سجل الدفع
    await _firestore.setData(
      path: 'payments/${payment.id}',
      data: {
        ...payment.toMap(),
        'customerId': customerId,
        'invoiceId': invoiceId,
      },
    );
  }

  @override
  Future<void> updateDeferredAccount(DeferredAccountModel account) async {
    await _firestore.setData(
      path: 'deferredAccounts/${account.customerId}',
      data: account.toMap(),
    );
  }

  @override
  Stream<List<DeferredAccountModel>> deferredAccountsStream() {
    return _firestore.collectionStream<SalesInvoiceModel>(
      path: ApiPaths.salesInvoices(),
      builder: (data, documentId) =>
          SalesInvoiceModel.fromMap({...data, 'id': documentId}),
      queryBuilder: (query) =>
          query.where('paymentType', isEqualTo: 'آجل'),
    ).asyncMap((invoices) async {
      // تحويل الفواتير إلى حسابات آجلة
      final Map<String, List<SalesInvoiceModel>> customerInvoices = {};
      for (var invoice in invoices) {
        if (invoice.customerId != null) {
          customerInvoices.putIfAbsent(invoice.customerId!, () => []);
          customerInvoices[invoice.customerId]!.add(invoice);
        }
      }

      final List<DeferredAccountModel> accounts = [];
      for (var entry in customerInvoices.entries) {
        final customerId = entry.key;
        final invoicesList = entry.value;

        double totalAmount = 0;
        double totalPaid = 0;
        List<DeferredInvoice> deferredInvoices = [];

        for (var invoice in invoicesList) {
          totalAmount += invoice.totalAfterInterest;
          totalPaid += invoice.paidNow;

          deferredInvoices.add(DeferredInvoice(
            invoiceId: invoice.id,
            invoiceDate: invoice.invoiceDate ?? DateTime.now(),
            totalAmount: invoice.totalAfterInterest,
            paidAmount: invoice.paidNow,
            remainingAmount: invoice.remaining,
            interestRate: invoice.interestRate,
          ));
        }

        accounts.add(DeferredAccountModel(
          customerId: customerId,
          customerName: invoicesList.first.customerName ?? 'غير معروف',
          invoiceCount: invoicesList.length,
          totalAmount: totalAmount,
          paid: totalPaid,
          remaining: totalAmount - totalPaid,
          invoices: deferredInvoices,
        ));
      }

      return accounts;
    });
  }
}
