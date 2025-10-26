import 'package:management_stock/models/pos_cart_model.dart';

class SaleRecord {
  String id;
  DateTime dateTime;
  List<POSCartItem> items;

  SaleRecord({
    required this.id,
    required this.dateTime,
    required this.items,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': "${dateTime.year}-${dateTime.month}-${dateTime.day}",
      'time': "${dateTime.hour}:${dateTime.minute}",
      'total': total,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}


//dummy
 