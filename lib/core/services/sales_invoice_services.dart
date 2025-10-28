import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/core/services/product_service.dart';
import 'package:management_stock/models/sales_invoice_model.dart';
import 'package:management_stock/models/product.dart';

abstract class SalesInvoiceServices {
  Future<void> createSalesInvoice(SalesInvoiceModel invoice);
  Future<List<SalesInvoiceModel>> getSalesInvoices();
  Future<SalesInvoiceModel> getSalesInvoiceById(String invoiceId);
}

class SalesInvoiceServicesImpl implements SalesInvoiceServices {
  final _firestore = FirestoreServices.instance;
  final _productServices = ProductServicesImpl();

  @override
  Future<void> createSalesInvoice(SalesInvoiceModel invoice) async {
    // 1️⃣ التحقق من توفر الكميات المطلوبة
    for (var item in invoice.items) {
      final product = await _firestore.getDocument<ProductModel>(
        path: ApiPaths.product(item.product.id),
        builder: (data, docId) => ProductModel.fromMap({...data, 'id': docId}),
      );

      if (product.quantity < item.quantity) {
        throw Exception(
          '❌ الكمية المتاحة من "${product.name}" غير كافية!\n'
          'المتاح: ${product.quantity} | المطلوب: ${item.quantity}',
        );
      }
    }

    // 2️⃣ حفظ الفاتورة
    await _firestore.setData(
      path: ApiPaths.salesInvoice(invoice.id),
      data: invoice.toMap(),
    );

    // 3️⃣ خصم الكميات من المنتجات
    for (var item in invoice.items) {
      final existingProduct = await _firestore.getDocument<ProductModel>(
        path: ApiPaths.product(item.product.id),
        builder: (data, docId) => ProductModel.fromMap({...data, 'id': docId}),
      );

      final updatedProduct = ProductModel(
        id: existingProduct.id,
        name: existingProduct.name,
        category: existingProduct.category,
        image: existingProduct.image,
        purchasePrice: existingProduct.purchasePrice,
        sellPrice: item.sellPrice, // تحديث سعر البيع
        pointPrice: existingProduct.pointPrice,
        quantity: existingProduct.quantity - item.quantity, // 🔥 خصم الكمية
        barcode: existingProduct.barcode,
      );

      await _productServices.updateProduct(updatedProduct);
    }
  }

  @override
  Future<List<SalesInvoiceModel>> getSalesInvoices() async {
    return await _firestore.getCollection(
      path: ApiPaths.salesInvoices(),
      builder: (data, documentId) => SalesInvoiceModel.fromMap({
        ...data,
        'id': documentId,
      }),
      sort: (a, b) => b.invoiceDate!.compareTo(a.invoiceDate!), // الأحدث أولاً
    );
  }

  @override
  Future<SalesInvoiceModel> getSalesInvoiceById(String invoiceId) async {
    return await _firestore.getDocument(
      path: ApiPaths.salesInvoice(invoiceId),
      builder: (data, documentId) => SalesInvoiceModel.fromMap({
        ...data,
        'id': documentId,
      }),
    );
  }
}