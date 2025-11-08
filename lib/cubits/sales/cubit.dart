import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/sales/sales_invoice_services.dart';
import 'package:management_stock/cubits/sales/states.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';

class SalesInvoiceCubit extends Cubit<SalesInvoiceState> {
  final SalesInvoiceServices _services;

  SalesInvoiceCubit(this._services) : super(SalesInvoiceInitial());

  List<SalesInvoiceModel> _invoices = [];
  List<SalesInvoiceModel> get invoices => _invoices;

  Future<void> createInvoice(SalesInvoiceModel invoice) async {
    emit(SalesInvoiceLoading());
    try {
      await _services.createSalesInvoice(invoice);
      emit(SalesInvoiceSuccess("✅ تم حفظ فاتورة البيع وخصم الكميات من المخزون"));
      await fetchInvoices(); // تحديث القائمة
    } catch (e) {
      emit(SalesInvoiceError(e.toString()));
    }
  }

  Future<void> fetchInvoices() async {
    emit(SalesInvoiceLoading());
    try {
      final invoices = await _services.getSalesInvoices();
      _invoices = invoices;
      emit(SalesInvoiceLoaded(invoices));
    } catch (e) {
      emit(SalesInvoiceError("❌ فشل في تحميل الفواتير: $e"));
    }
  }

  Future<SalesInvoiceModel?> getInvoiceById(String id) async {
    try {
      return await _services.getSalesInvoiceById(id);
    } catch (e) {
      emit(SalesInvoiceError("❌ فشل في تحميل الفاتورة: $e"));
      return null;
    }
  }
}