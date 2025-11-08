import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/products/product_service.dart';
import 'package:management_stock/cubits/products/states.dart';
import 'package:management_stock/models/product.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductServices _productServices;

  ProductCubit(this._productServices) : super(ProductInitial());

  List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await _productServices.getProducts();
      _products = products;
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError("❌ فشل تحميل المنتجات: $e"));
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _productServices.addProduct(product);
      _products.add(product);
      emit(ProductLoaded(List.from(_products)));
    } catch (e) {
      emit(ProductError("❌ فشل في إضافة المنتج: $e"));
    }
  }

  Future<void> updateProduct(ProductModel updated) async {
    try {
      await _productServices.updateProduct(updated);
      final index = _products.indexWhere((p) => p.id == updated.id);
      if (index != -1) _products[index] = updated;
      emit(ProductLoaded(List.from(_products)));
    } catch (e) {
      emit(ProductError("❌ فشل في تعديل المنتج: $e"));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productServices.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      emit(ProductLoaded(List.from(_products)));
    } catch (e) {
      emit(ProductError("❌ فشل في حذف المنتج: $e"));
    }
  }
}