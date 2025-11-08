import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/purchase/purchase_invoice_service.dart';
import 'package:management_stock/cubits/purchase/states.dart';
import 'package:management_stock/models/purchase/purchase_invoice_item.dart';

class PurchaseInvoiceCubit extends Cubit<PurchaseInvoiceState> {
  final PurchaseInvoiceServices _services;

  PurchaseInvoiceCubit(this._services) : super(PurchaseInvoiceInitial());

  List<PurchaseInvoiceModel> _invoices = [];
  List<PurchaseInvoiceModel> get invoices => _invoices;

  Future<void> createInvoice(PurchaseInvoiceModel invoice) async {
    emit(PurchaseInvoiceLoading());
    try {
      await _services.createPurchaseInvoice(invoice);
      emit(PurchaseInvoiceSuccess("✅ تم حفظ فاتورة الشراء بنجاح"));
      await fetchInvoices(); // تحديث القائمة
    } catch (e) {
      emit(PurchaseInvoiceError("❌ فشل في حفظ الفاتورة: $e"));
    }
  }

  Future<void> fetchInvoices() async {
    emit(PurchaseInvoiceLoading());
    try {
      final invoices = await _services.getPurchaseInvoices();
      _invoices = invoices;
      emit(PurchaseInvoiceLoaded(invoices));
    } catch (e) {
      emit(PurchaseInvoiceError("❌ فشل في تحميل الفواتير: $e"));
    }
  }

  

  Future<PurchaseInvoiceModel?> getInvoiceById(String id) async {
    try {
      return await _services.getPurchaseInvoiceById(id);
    } catch (e) {
      emit(PurchaseInvoiceError("❌ فشل في تحميل الفاتورة: $e"));
      return null;
    }
  }
}