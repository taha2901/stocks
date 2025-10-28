import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/models/pos_sales_model.dart';
import 'package:management_stock/models/sales_invoice_model.dart';
import 'package:management_stock/models/product.dart';

abstract class ReportsServices {
  Future<Map<String, dynamic>> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Map<String, dynamic>> getInventoryReport();
  
  Future<Map<String, dynamic>> getProfitReport({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class ReportsServicesImpl implements ReportsServices {
  final _firestore = FirestoreServices.instance;

  @override
  Future<Map<String, dynamic>> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // جلب مبيعات POS (البيع السريع)
      final posSales = await _firestore.getCollection<POSSaleModel>(
        path: ApiPaths.posSales(),
        builder: (data, documentId) => POSSaleModel.fromMap({
          ...data,
          'id': documentId,
        }),
      );

      // جلب فواتير البيع بالجملة
      final salesInvoices = await _firestore.getCollection<SalesInvoiceModel>(
        path: ApiPaths.salesInvoices(),
        builder: (data, documentId) => SalesInvoiceModel.fromMap({
          ...data,
          'id': documentId,
        }),
      );

      // تصفية حسب التاريخ
      final filteredPosSales = _filterByDate(posSales, startDate, endDate);
      final filteredInvoices = _filterByDateInvoice(salesInvoices, startDate, endDate);

      // حساب الإحصائيات
      double totalPosSales = filteredPosSales.fold(0, (sum, sale) => sum + sale.total);
      double totalWholesaleSales = filteredInvoices.fold(
        0,
        (sum, invoice) => sum + invoice.totalAfterDiscount,
      );

      int totalPosTransactions = filteredPosSales.length;
      int totalWholesaleTransactions = filteredInvoices.length;

      // أكثر المنتجات مبيعاً
      Map<String, int> productSalesCount = {};
      Map<String, double> productRevenue = {};

      for (var sale in filteredPosSales) {
        for (var item in sale.items) {
          productSalesCount[item.product.name] = 
              (productSalesCount[item.product.name] ?? 0) + item.quantity;
          productRevenue[item.product.name] = 
              (productRevenue[item.product.name] ?? 0) + item.total;
        }
      }

      for (var invoice in filteredInvoices) {
        for (var item in invoice.items) {
          productSalesCount[item.product.name] = 
              (productSalesCount[item.product.name] ?? 0) + item.quantity;
          productRevenue[item.product.name] = 
              (productRevenue[item.product.name] ?? 0) + item.subtotal;
        }
      }

      // ترتيب المنتجات حسب المبيعات
      var sortedProducts = productSalesCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // مبيعات يومية للرسم البياني
      Map<String, double> dailySales = _calculateDailySales(
        filteredPosSales,
        filteredInvoices,
      );

      return {
        'totalSales': totalPosSales + totalWholesaleSales,
        'totalPosSales': totalPosSales,
        'totalWholesaleSales': totalWholesaleSales,
        'totalTransactions': totalPosTransactions + totalWholesaleTransactions,
        'totalPosTransactions': totalPosTransactions,
        'totalWholesaleTransactions': totalWholesaleTransactions,
        'topProducts': sortedProducts.take(10).toList(),
        'productRevenue': productRevenue,
        'dailySales': dailySales,
        'averageOrderValue': (totalPosSales + totalWholesaleSales) / 
            (totalPosTransactions + totalWholesaleTransactions),
      };
    } catch (e) {
      throw Exception('فشل في جلب تقرير المبيعات: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryReport() async {
    try {
      final products = await _firestore.getCollection<ProductModel>(
        path: ApiPaths.products(),
        builder: (data, documentId) => ProductModel.fromMap({
          ...data,
          'id': documentId,
        }),
      );

      int totalProducts = products.length;
      int lowStockProducts = products.where((p) => p.quantity < 10).length;
      int outOfStockProducts = products.where((p) => p.quantity == 0).length;

      double totalInventoryValue = products.fold(
        0,
        (sum, product) => sum + (product.purchasePrice * product.quantity),
      );

      double expectedRevenue = products.fold(
        0,
        (sum, product) => sum + (product.sellPrice * product.quantity),
      );

      // تصنيف المنتجات حسب الفئة
      Map<String, int> categoryCount = {};
      Map<String, double> categoryValue = {};

      for (var product in products) {
        categoryCount[product.category] = 
            (categoryCount[product.category] ?? 0) + 1;
        categoryValue[product.category] = 
            (categoryValue[product.category] ?? 0) + 
            (product.purchasePrice * product.quantity);
      }

      return {
        'totalProducts': totalProducts,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
        'totalInventoryValue': totalInventoryValue,
        'expectedRevenue': expectedRevenue,
        'categoryCount': categoryCount,
        'categoryValue': categoryValue,
        'products': products,
      };
    } catch (e) {
      throw Exception('فشل في جلب تقرير المخزون: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProfitReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // جلب المبيعات
      final posSales = await _firestore.getCollection<POSSaleModel>(
        path: ApiPaths.posSales(),
        builder: (data, documentId) => POSSaleModel.fromMap({
          ...data,
          'id': documentId,
        }),
      );

      final salesInvoices = await _firestore.getCollection<SalesInvoiceModel>(
        path: ApiPaths.salesInvoices(),
        builder: (data, documentId) => SalesInvoiceModel.fromMap({
          ...data,
          'id': documentId,
        }),
      );

      // تصفية حسب التاريخ
      final filteredPosSales = _filterByDate(posSales, startDate, endDate);
      final filteredInvoices = _filterByDateInvoice(salesInvoices, startDate, endDate);

      // حساب الإيرادات
      double totalRevenue = 0;
      double totalCost = 0;

      // من POS Sales
      for (var sale in filteredPosSales) {
        for (var item in sale.items) {
          totalRevenue += item.total;
          totalCost += item.product.purchasePrice * item.quantity;
        }
      }

      // من Sales Invoices
      for (var invoice in filteredInvoices) {
        for (var item in invoice.items) {
          totalRevenue += item.subtotal;
          totalCost += item.buyPrice * item.quantity;
        }
        // خصم الخصومات
        totalRevenue -= invoice.discount;
      }

      double grossProfit = totalRevenue - totalCost;
      double profitMargin = totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0;

      // أرباح يومية
      Map<String, double> dailyProfit = _calculateDailyProfit(
        filteredPosSales,
        filteredInvoices,
      );

      // أكثر المنتجات ربحاً
      Map<String, double> productProfit = {};

      for (var sale in filteredPosSales) {
        for (var item in sale.items) {
          double profit = (item.price - item.product.purchasePrice) * item.quantity;
          productProfit[item.product.name] = 
              (productProfit[item.product.name] ?? 0) + profit;
        }
      }

      for (var invoice in filteredInvoices) {
        for (var item in invoice.items) {
          double profit = (item.sellPrice - item.buyPrice) * item.quantity;
          productProfit[item.product.name] = 
              (productProfit[item.product.name] ?? 0) + profit;
        }
      }

      var sortedProfitProducts = productProfit.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return {
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'grossProfit': grossProfit,
        'profitMargin': profitMargin,
        'dailyProfit': dailyProfit,
        'topProfitProducts': sortedProfitProducts.take(10).toList(),
      };
    } catch (e) {
      throw Exception('فشل في جلب تقرير الأرباح: $e');
    }
  }

  // دوال مساعدة
  List<POSSaleModel> _filterByDate(
    List<POSSaleModel> sales,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return sales;

    return sales.where((sale) {
      if (startDate != null && sale.saleDate.isBefore(startDate)) return false;
      if (endDate != null && sale.saleDate.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  List<SalesInvoiceModel> _filterByDateInvoice(
    List<SalesInvoiceModel> invoices,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return invoices;

    return invoices.where((invoice) {
      if (invoice.invoiceDate == null) return false;
      if (startDate != null && invoice.invoiceDate!.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && invoice.invoiceDate!.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  Map<String, double> _calculateDailySales(
    List<POSSaleModel> posSales,
    List<SalesInvoiceModel> invoices,
  ) {
    Map<String, double> dailySales = {};

    for (var sale in posSales) {
      String dateKey = '${sale.saleDate.year}-${sale.saleDate.month}-${sale.saleDate.day}';
      dailySales[dateKey] = (dailySales[dateKey] ?? 0) + sale.total;
    }

    for (var invoice in invoices) {
      if (invoice.invoiceDate != null) {
        String dateKey = '${invoice.invoiceDate!.year}-${invoice.invoiceDate!.month}-${invoice.invoiceDate!.day}';
        dailySales[dateKey] = (dailySales[dateKey] ?? 0) + invoice.totalAfterDiscount;
      }
    }

    return dailySales;
  }

  Map<String, double> _calculateDailyProfit(
    List<POSSaleModel> posSales,
    List<SalesInvoiceModel> invoices,
  ) {
    Map<String, double> dailyProfit = {};

    for (var sale in posSales) {
      String dateKey = '${sale.saleDate.year}-${sale.saleDate.month}-${sale.saleDate.day}';
      double profit = 0;
      for (var item in sale.items) {
        profit += (item.price - item.product.purchasePrice) * item.quantity;
      }
      dailyProfit[dateKey] = (dailyProfit[dateKey] ?? 0) + profit;
    }

    for (var invoice in invoices) {
      if (invoice.invoiceDate != null) {
        String dateKey = '${invoice.invoiceDate!.year}-${invoice.invoiceDate!.month}-${invoice.invoiceDate!.day}';
        double profit = 0;
        for (var item in invoice.items) {
          profit += (item.sellPrice - item.buyPrice) * item.quantity;
        }
        dailyProfit[dateKey] = (dailyProfit[dateKey] ?? 0) + profit - invoice.discount;
      }
    }

    return dailyProfit;
  }
}
