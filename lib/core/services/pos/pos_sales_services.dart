import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/core/services/products/product_service.dart';
import 'package:management_stock/models/pos/pos_sales_model.dart';
import 'package:management_stock/models/product.dart';

abstract class POSSaleServices {
  Future<void> createPOSSale(POSSaleModel sale);
  Future<List<POSSaleModel>> getPOSSales();
}

class POSSaleServicesImpl implements POSSaleServices {
  final _firestore = FirestoreServices.instance;
  final _productServices = ProductServicesImpl();

  @override
  Future<void> createPOSSale(POSSaleModel sale) async {
    // 1️⃣ التحقق من الكميات
    for (var item in sale.items) {
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

    // 2️⃣ حفظ البيع
    await _firestore.setData(
      path: ApiPaths.posSale(sale.id),
      data: sale.toMap(),
    );

    // 3️⃣ خصم الكميات
    for (var item in sale.items) {
      final existingProduct = await _firestore.getDocument<ProductModel>(
        path: ApiPaths.product(item.product.id),
        builder: (data, docId) => ProductModel.fromMap({...data, 'id': docId}),
      );

      final updatedProduct = ProductModel(
        id: existingProduct.id,
        name: existingProduct.name,
        category: existingProduct.category,
        purchasePrice: existingProduct.purchasePrice,
        sellPrice: existingProduct.sellPrice,
        pointPrice: existingProduct.pointPrice,
        quantity: existingProduct.quantity - item.quantity, // 🔥 خصم
        barcode: existingProduct.barcode,
      );

      await _productServices.updateProduct(updatedProduct);
    }
  }

  @override
  Future<List<POSSaleModel>> getPOSSales() async {
    return await _firestore.getCollection(
      path: ApiPaths.posSales(),
      builder: (data, documentId) => POSSaleModel.fromMap({
        ...data,
        'id': documentId,
      }),
      sort: (a, b) => b.saleDate.compareTo(a.saleDate),
    );
  }
}