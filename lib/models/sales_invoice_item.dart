  import 'package:management_stock/models/product.dart';

  class SalesInvoiceItem {
    ProductModel product;
    int quantity;
    double buyPrice;
    double sellPrice;

    SalesInvoiceItem({
      required this.product,
      this.quantity = 1,
      double? buyPrice,
      double? sellPrice,
    })  : buyPrice = buyPrice ?? product.purchasePrice,
          sellPrice = sellPrice ?? product.sellPrice;

    double get subtotal => buyPrice * quantity;

    Map<String, dynamic> toMap() {
      return {
        'productId': product.id,
        'productName': product.name,
        'quantity': quantity,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'subtotal': subtotal,
      };
    }
  }

