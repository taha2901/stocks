import 'package:management_stock/models/pos/pos_sales_model.dart';

abstract class POSSaleState {}

class POSSaleInitial extends POSSaleState {}
class POSSaleLoading extends POSSaleState {}
class POSSaleSuccess extends POSSaleState {
  final String message;
  POSSaleSuccess(this.message);
}
class POSSaleLoaded extends POSSaleState {
  final List<POSSaleModel> sales;
  POSSaleLoaded(this.sales);
}
class POSSaleError extends POSSaleState {
  final String error;
  POSSaleError(this.error);
}
