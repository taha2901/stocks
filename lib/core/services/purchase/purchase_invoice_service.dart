import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/core/services/products/product_service.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/purchase/purchase_invoice_item.dart';

abstract class PurchaseInvoiceServices {
  Future<void> createPurchaseInvoice(PurchaseInvoiceModel invoice);
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices();
  Future<PurchaseInvoiceModel> getPurchaseInvoiceById(String invoiceId);
}

class PurchaseInvoiceServicesImpl implements PurchaseInvoiceServices {
  final _firestore = FirestoreServices.instance;
  final _productServices = ProductServicesImpl();

  @override
  Future<void> createPurchaseInvoice(PurchaseInvoiceModel invoice) async {
    // 1️⃣ حفظ الفاتورة
    await _firestore.setData(
      path: ApiPaths.purchaseInvoice(invoice.id),
      data: invoice.toMap(),
    );

    // 2️⃣ تحديث المنتجات (زيادة الكمية أو إضافة منتج جديد)
    for (var item in invoice.items) {
      try {
        // محاولة جلب المنتج الموجود
        final existingProduct = await _firestore.getDocument<ProductModel>(
          path: ApiPaths.product(item.product.id),
          builder: (data, docId) => ProductModel.fromMap({...data, 'id': docId}),
        );

        // المنتج موجود → نزود الكمية
        final updatedProduct = ProductModel(
          id: existingProduct.id,
          name: existingProduct.name,
          category: existingProduct.category,
          purchasePrice: item.buyPrice, // تحديث سعر الشراء
          sellPrice: item.sellPrice, // تحديث سعر البيع
          pointPrice: existingProduct.pointPrice,
          quantity: existingProduct.quantity + item.quantity, // 🔥 زيادة الكمية
          barcode: existingProduct.barcode,
        );

        await _productServices.updateProduct(updatedProduct);
      } catch (e) {
        // المنتج مش موجود → نضيفه جديد
        final newProduct = ProductModel(
          id: item.product.id,
          name: item.product.name,
          category: item.product.category,
          purchasePrice: item.buyPrice,
          sellPrice: item.sellPrice,
          pointPrice: item.sellPrice,
          quantity: item.quantity,
          barcode: item.product.barcode,
        );

        await _productServices.addProduct(newProduct);
      }
    }
  }

  @override
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices() async {
    return await _firestore.getCollection(
      path: ApiPaths.purchaseInvoices(),
      builder: (data, documentId) => PurchaseInvoiceModel.fromMap({
        ...data,
        'id': documentId,
      }),
      sort: (a, b) => b.createdAt.compareTo(a.createdAt), // الأحدث أولاً
    );
  }

  @override
  Future<PurchaseInvoiceModel> getPurchaseInvoiceById(String invoiceId) async {
    return await _firestore.getDocument(
      path: ApiPaths.purchaseInvoice(invoiceId),
      builder: (data, documentId) => PurchaseInvoiceModel.fromMap({
        ...data,
        'id': documentId,
      }),
    );
  }
}