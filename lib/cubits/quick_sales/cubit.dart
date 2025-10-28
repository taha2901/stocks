import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/pos_sales_services.dart';
import 'package:management_stock/cubits/quick_sales/states.dart';
import 'package:management_stock/models/pos_sales_model.dart';

class POSSaleCubit extends Cubit<POSSaleState> {
  final POSSaleServices _services;

  POSSaleCubit(this._services) : super(POSSaleInitial());

  List<POSSaleModel> _sales = [];
  List<POSSaleModel> get sales => _sales;

  Future<void> createSale(POSSaleModel sale) async {
    emit(POSSaleLoading());
    try {
      await _services.createPOSSale(sale);
      emit(POSSaleSuccess("✅ تم إتمام البيع وخصم الكميات"));
      await fetchSales();
    } catch (e) {
      emit(POSSaleError(e.toString()));
    }
  }

  Future<void> fetchSales() async {
    emit(POSSaleLoading());
    try {
      final sales = await _services.getPOSSales();
      _sales = sales;
      emit(POSSaleLoaded(sales));
    } catch (e) {
      emit(POSSaleError("❌ فشل في تحميل المبيعات: $e"));
    }
  }
}