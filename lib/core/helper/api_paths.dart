class ApiPaths {
  static String users(String userId) => 'users/$userId';
  static String user() => 'users/';
  static String categories() => 'categories/';
  static String products() => 'products/';
  static String product(String productId) => 'products/$productId';
  static String suppliers() => 'suppliers/';
  static String supplier(String supplierId) => 'suppliers/$supplierId';

  static String purchaseInvoices() => 'purchaseInvoices/';
  static String purchaseInvoice(String invoiceId) =>
      'purchaseInvoices/$invoiceId';
  static String customers() => 'customers/';
  static String customer(String customerId) => 'customers/$customerId';

  static String salesInvoices() => 'salesInvoices/';
  static String salesInvoice(String invoiceId) => 'salesInvoices/$invoiceId';

  static String posSales() => 'posSales/';
  static String posSale(String saleId) => 'posSales/$saleId';

  static String deferredAccounts() => 'deferredAccounts/';
  static String deferredAccount(String customerId) => 'deferredAccounts/$customerId';
  static String payments() => 'payments/';
  static String payment(String paymentId) => 'payments/$paymentId';
}
