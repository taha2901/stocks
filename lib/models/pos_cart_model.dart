import 'package:management_stock/models/product.dart';

class POSCartItem {
  final ProductModel product;
  int quantity;
  final double price;

  POSCartItem({
    required this.product,
    this.quantity = 1,
    double? price,
  }) : price = price ?? product.sellPrice;

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
