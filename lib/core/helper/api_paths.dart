class ApiPaths {
  static String users(String userId) => 'users/$userId';
  static String user() => 'users/';
  static String categories() => 'categories/';
  static String products() => 'products/';
  static String product(String productId) => 'products/$productId';
  static String cartItem(String userId, String cartItemId) =>
      'users/$userId/cart/$cartItemId';

  static String cartItems(String userId) => 'users/$userId/cart/';

  static String favouriteProduct(String userId, String productId) =>
      'users/$userId/favourites/$productId';

  static String favouriteProducts(String userId) => 'users/$userId/favourites';
  static String orders() => 'orders';
  static String order(String orderId) => 'orders/$orderId';

  static String announcments() => 'announcments/';
  static String userOrders(String userId) => 'users/$userId/orders';

  static String paymentCard(String userId, String paymentId) =>
      'users/$userId/paymentCards/$paymentId';
  static String paymentCards(String userId) => 'users/$userId/paymentCards/';
}
