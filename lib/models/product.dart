class ProductModel {
  final String id; // ممكن نستخدمه لاحقًا مع Firebase
  final String name;
  final String category;
  final String image;
  final double purchasePrice;
  final double sellPrice;
  final double pointPrice;
  final int quantity;
  final String barcode;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.purchasePrice,
    required this.sellPrice,
    required this.pointPrice,
    required this.quantity,
    required this.barcode,
  });

  // ✅ fromJson
  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      sellPrice: (json['sellPrice'] ?? 0).toDouble(),
      pointPrice: (json['pointPrice'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      barcode: json['barcode'] ?? '',
    );
  }

  // ✅ toJson
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image': image,
      'purchasePrice': purchasePrice,
      'sellPrice': sellPrice,
      'pointPrice': pointPrice,
      'quantity': quantity,
      'barcode': barcode,
    };
  }
}


final List<ProductModel> dummyProducts = [
  ProductModel(
    id: '1',
    name: 'لاب توب Dell',
    category: 'إلكترونيات',
    image: 'https://cdn-icons-png.flaticon.com/512/3081/3081559.png',
    purchasePrice: 15000,
    sellPrice: 18500,
    pointPrice: 18300,
    quantity: 10,
    barcode: '123456',
  ),
  ProductModel(
    id: '2',
    name: 'هاتف Samsung',
    category: 'إلكترونيات',
    image: 'https://cdn-icons-png.flaticon.com/512/2702/2702602.png',
    purchasePrice: 8000,
    sellPrice: 9500,
    pointPrice: 9400,
    quantity: 20,
    barcode: '789012',
  ),
  ProductModel(
    id: '3',
    name: 'ماوس لاسلكي',
    category: 'إكسسوارات',
    image: 'https://cdn-icons-png.flaticon.com/512/2331/2331942.png',
    purchasePrice: 150,
    sellPrice: 250,
    pointPrice: 240,
    quantity: 45,
    barcode: '987654',
  ),
  ProductModel(
    id: '4',
    name: 'كيبورد ميكانيكال',
    category: 'إكسسوارات',
    image: 'https://cdn-icons-png.flaticon.com/512/1041/1041916.png',
    purchasePrice: 500,
    sellPrice: 750,
    pointPrice: 700,
    quantity: 30,
    barcode: '456789',
  ),
];
