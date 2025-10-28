import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/models/product.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

abstract class ExportServices {
  Future<String> exportSalesReportToCSV(Map<String, dynamic> reportData);
  Future<String> exportInventoryReportToCSV(Map<String, dynamic> reportData);
  Future<String> exportProfitReportToCSV(Map<String, dynamic> reportData);
  
  Future<void> exportSalesReportToPDF(Map<String, dynamic> reportData, String period);
  Future<void> exportInventoryReportToPDF(Map<String, dynamic> reportData);
  Future<void> exportProfitReportToPDF(Map<String, dynamic> reportData, String period);
}

class ExportServicesImpl implements ExportServices {
  final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  // 📥 تصدير تقرير المبيعات إلى CSV
  @override
  Future<String> exportSalesReportToCSV(Map<String, dynamic> reportData) async {
    try {
      List<List<dynamic>> rows = [];

      rows.add(['تقرير المبيعات - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}']);
      rows.add([]);
      rows.add(['الإحصائية', 'القيمة']);
      rows.add(['إجمالي المبيعات', reportData['totalSales'] ?? 0]);
      rows.add(['مبيعات البيع السريع (POS)', reportData['totalPosSales'] ?? 0]);
      rows.add(['مبيعات البيع بالجملة', reportData['totalWholesaleSales'] ?? 0]);
      rows.add(['عدد الفواتير الكلي', reportData['totalTransactions'] ?? 0]);
      rows.add(['عدد فواتير POS', reportData['totalPosTransactions'] ?? 0]);
      rows.add(['عدد فواتير الجملة', reportData['totalWholesaleTransactions'] ?? 0]);
      rows.add(['متوسط قيمة الفاتورة', reportData['averageOrderValue'] ?? 0]);
      rows.add([]);

      rows.add(['أكثر المنتجات مبيعاً']);
      rows.add(['المنتج', 'الكمية المباعة', 'الإيرادات']);

      final topProducts = reportData['topProducts'] as List<dynamic>?;
      final productRevenue = reportData['productRevenue'] as Map<String, dynamic>?;

      if (topProducts != null) {
        for (var product in topProducts) {
          final productName = product.key;
          final quantity = product.value;
          final revenue = productRevenue?[productName] ?? 0;
          rows.add([productName, quantity, revenue]);
        }
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv, encoding: utf8);

      return path;
    } catch (e) {
      throw Exception('فشل في تصدير تقرير المبيعات إلى CSV: $e');
    }
  }

  @override
  Future<String> exportInventoryReportToCSV(Map<String, dynamic> reportData) async {
    try {
      List<List<dynamic>> rows = [];

      rows.add(['تقرير المخزون - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}']);
      rows.add([]);
      rows.add(['الإحصائية', 'القيمة']);
      rows.add(['إجمالي المنتجات', reportData['totalProducts'] ?? 0]);
      rows.add(['قيمة المخزون الكلية', reportData['totalInventoryValue'] ?? 0]);
      rows.add(['منتجات قاربت النفاذ', reportData['lowStockProducts'] ?? 0]);
      rows.add(['منتجات نفذت', reportData['outOfStockProducts'] ?? 0]);
      rows.add(['الإيرادات المتوقعة', reportData['expectedRevenue'] ?? 0]);
      rows.add([]);

      rows.add(['المخزون حسب الفئة']);
      rows.add(['الفئة', 'عدد المنتجات', 'القيمة']);

      final categoryCount = reportData['categoryCount'] as Map<String, dynamic>?;
      final categoryValue = reportData['categoryValue'] as Map<String, dynamic>?;

      if (categoryCount != null) {
        categoryCount.forEach((category, count) {
          final value = categoryValue?[category] ?? 0;
          rows.add([category, count, value]);
        });
      }

      rows.add([]);
      rows.add(['تفاصيل المخزون']);
      rows.add(['المنتج', 'الفئة', 'الكمية', 'سعر الشراء', 'سعر البيع', 'القيمة الكلية']);

      final products = reportData['products'] as List<dynamic>?;
      if (products != null) {
        for (var product in products) {
          final p = product as ProductModel;
          final totalValue = p.quantity * p.purchasePrice;
          rows.add([p.name, p.category, p.quantity, p.purchasePrice, p.sellPrice, totalValue]);
        }
      }

      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/inventory_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv, encoding: utf8);

      return path;
    } catch (e) {
      throw Exception('فشل في تصدير تقرير المخزون إلى CSV: $e');
    }
  }

  @override
  Future<String> exportProfitReportToCSV(Map<String, dynamic> reportData) async {
    try {
      List<List<dynamic>> rows = [];

      rows.add(['تقرير الأرباح - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}']);
      rows.add([]);
      rows.add(['الإحصائية', 'القيمة']);
      rows.add(['إجمالي الإيرادات', reportData['totalRevenue'] ?? 0]);
      rows.add(['إجمالي التكاليف', reportData['totalCost'] ?? 0]);
      rows.add(['صافي الربح', reportData['grossProfit'] ?? 0]);
      rows.add(['هامش الربح %', reportData['profitMargin'] ?? 0]);
      rows.add([]);

      rows.add(['أكثر المنتجات ربحاً']);
      rows.add(['المنتج', 'الربح']);

      final topProfitProducts = reportData['topProfitProducts'] as List<dynamic>?;
      if (topProfitProducts != null) {
        for (var product in topProfitProducts) {
          rows.add([product.key, product.value]);
        }
      }

      rows.add([]);
      rows.add(['الأرباح اليومية']);
      rows.add(['التاريخ', 'الربح']);

      final dailyProfit = reportData['dailyProfit'] as Map<String, dynamic>?;
      if (dailyProfit != null) {
        dailyProfit.forEach((date, profit) {
          rows.add([date, profit]);
        });
      }

      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/profit_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv, encoding: utf8);

      return path;
    } catch (e) {
      throw Exception('فشل في تصدير تقرير الأرباح إلى CSV: $e');
    }
  }

  // 📄 تصدير تقرير المبيعات إلى PDF
  @override
  Future<void> exportSalesReportToPDF(
    Map<String, dynamic> reportData,
    String period,
  ) async {
    try {
      final pdf = pw.Document();
      
      // ✅ تحميل الخط من Assets بدلاً من Google Fonts
      final arabicFont = await _loadArabicFont();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) => [
            _buildPDFHeader('تقرير المبيعات', 'الفترة: $period'),
            pw.SizedBox(height: 20),
            _buildStatsSection([
              {'label': 'إجمالي المبيعات', 'value': currencyFormat.format(reportData['totalSales'] ?? 0)},
              {'label': 'مبيعات البيع السريع (POS)', 'value': currencyFormat.format(reportData['totalPosSales'] ?? 0)},
              {'label': 'مبيعات البيع بالجملة', 'value': currencyFormat.format(reportData['totalWholesaleSales'] ?? 0)},
              {'label': 'عدد الفواتير', 'value': '${reportData['totalTransactions'] ?? 0}'},
              {'label': 'متوسط قيمة الفاتورة', 'value': currencyFormat.format(reportData['averageOrderValue'] ?? 0)},
            ]),
            pw.SizedBox(height: 30),
            _buildSectionTitle('أكثر المنتجات مبيعاً'),
            pw.SizedBox(height: 10),
            _buildTopProductsTable(reportData['topProducts'], reportData['productRevenue']),
            pw.SizedBox(height: 30),
            _buildPDFFooter(),
          ],
        ),
      );

      await _savePDF(pdf, 'sales_report');
    } catch (e) {
      throw Exception('فشل في تصدير تقرير المبيعات إلى PDF: $e');
    }
  }

  @override
  Future<void> exportInventoryReportToPDF(Map<String, dynamic> reportData) async {
    try {
      final pdf = pw.Document();
      final arabicFont = await _loadArabicFont();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) => [
            _buildPDFHeader('تقرير المخزون', 'تاريخ: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            _buildStatsSection([
              {'label': 'إجمالي المنتجات', 'value': '${reportData['totalProducts'] ?? 0}'},
              {'label': 'قيمة المخزون', 'value': currencyFormat.format(reportData['totalInventoryValue'] ?? 0)},
              {'label': 'الإيرادات المتوقعة', 'value': currencyFormat.format(reportData['expectedRevenue'] ?? 0)},
              {'label': 'منتجات قاربت النفاذ', 'value': '${reportData['lowStockProducts'] ?? 0}'},
              {'label': 'منتجات نفذت', 'value': '${reportData['outOfStockProducts'] ?? 0}'},
            ]),
            pw.SizedBox(height: 30),
            _buildSectionTitle('المخزون حسب الفئة'),
            pw.SizedBox(height: 10),
            _buildCategoryTable(reportData['categoryCount'], reportData['categoryValue']),
            pw.SizedBox(height: 30),
            _buildSectionTitle('تفاصيل المخزون'),
            pw.SizedBox(height: 10),
            _buildInventoryDetailsTable(reportData['products']),
            pw.SizedBox(height: 30),
            _buildPDFFooter(),
          ],
        ),
      );

      await _savePDF(pdf, 'inventory_report');
    } catch (e) {
      throw Exception('فشل في تصدير تقرير المخزون إلى PDF: $e');
    }
  }

  @override
  Future<void> exportProfitReportToPDF(
    Map<String, dynamic> reportData,
    String period,
  ) async {
    try {
      final pdf = pw.Document();
      final arabicFont = await _loadArabicFont();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) => [
            _buildPDFHeader('تقرير الأرباح', 'الفترة: $period'),
            pw.SizedBox(height: 20),
            _buildStatsSection([
              {'label': 'إجمالي الإيرادات', 'value': currencyFormat.format(reportData['totalRevenue'] ?? 0)},
              {'label': 'إجمالي التكاليف', 'value': currencyFormat.format(reportData['totalCost'] ?? 0)},
              {'label': 'صافي الربح', 'value': currencyFormat.format(reportData['grossProfit'] ?? 0)},
              {'label': 'هامش الربح', 'value': '${(reportData['profitMargin'] ?? 0).toStringAsFixed(2)}%'},
            ]),
            pw.SizedBox(height: 30),
            _buildSectionTitle('أكثر المنتجات ربحاً'),
            pw.SizedBox(height: 10),
            _buildProfitProductsTable(reportData['topProfitProducts']),
            pw.SizedBox(height: 30),
            _buildPDFFooter(),
          ],
        ),
      );

      await _savePDF(pdf, 'profit_report');
    } catch (e) {
      throw Exception('فشل في تصدير تقرير الأرباح إلى PDF: $e');
    }
  }

  // ==================== دوال مساعدة لـ PDF ====================

  // ✅ تحميل الخط من Assets
  Future<pw.Font> _loadArabicFont() async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  pw.Widget _buildPDFHeader(String title, String subtitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          pw.SizedBox(height: 5),
          pw.Text(subtitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.white)),
        ],
      ),
    );
  }

  pw.Widget _buildStatsSection(List<Map<String, String>> stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: stats.map((stat) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(stat['value']!, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.Text(stat['label']!, style: const pw.TextStyle(fontSize: 14)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _buildTopProductsTable(List<dynamic>? products, Map<String, dynamic>? revenue) {
    if (products == null || products.isEmpty) {
      return pw.Text('لا توجد بيانات');
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      cellAlignment: pw.Alignment.centerRight,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerHeight: 30,
      cellHeight: 35,
      cellPadding: const pw.EdgeInsets.all(8),
      headers: ['المنتج', 'الكمية', 'الإيرادات'],
      data: products.take(15).map((product) {
        final productName = product.key;
        final quantity = product.value;
        final productRevenue = revenue?[productName] ?? 0;
        return [productName, '$quantity', currencyFormat.format(productRevenue)];
      }).toList(),
    );
  }

  pw.Widget _buildCategoryTable(Map<String, dynamic>? categoryCount, Map<String, dynamic>? categoryValue) {
    if (categoryCount == null || categoryCount.isEmpty) {
      return pw.Text('لا توجد بيانات');
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      cellAlignment: pw.Alignment.centerRight,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerHeight: 30,
      cellHeight: 35,
      cellPadding: const pw.EdgeInsets.all(8),
      headers: ['الفئة', 'عدد المنتجات', 'القيمة'],
      data: categoryCount.entries.map((entry) {
        final category = entry.key;
        final count = entry.value;
        final value = categoryValue?[category] ?? 0;
        return [category, '$count', currencyFormat.format(value)];
      }).toList(),
    );
  }

  pw.Widget _buildInventoryDetailsTable(List<dynamic>? products) {
    if (products == null || products.isEmpty) {
      return pw.Text('لا توجد بيانات');
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      cellAlignment: pw.Alignment.centerRight,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerHeight: 30,
      cellHeight: 35,
      cellPadding: const pw.EdgeInsets.all(5),
      headers: ['المنتج', 'الكمية', 'سعر الشراء', 'سعر البيع', 'القيمة'],
      data: products.take(50).map((product) {
        final p = product as ProductModel;
        final totalValue = p.quantity * p.purchasePrice;
        return [
          p.name,
          '${p.quantity}',
          currencyFormat.format(p.purchasePrice),
          currencyFormat.format(p.sellPrice),
          currencyFormat.format(totalValue),
        ];
      }).toList(),
    );
  }

  pw.Widget _buildProfitProductsTable(List<dynamic>? products) {
    if (products == null || products.isEmpty) {
      return pw.Text('لا توجد بيانات');
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      cellAlignment: pw.Alignment.centerRight,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerHeight: 30,
      cellHeight: 35,
      cellPadding: const pw.EdgeInsets.all(8),
      headers: ['المنتج', 'الربح'],
      data: products.take(15).map((product) {
        return [product.key, currencyFormat.format(product.value)];
      }).toList(),
    );
  }

  pw.Widget _buildPDFFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('تم الإنشاء بواسطة نظام إدارة المخزون', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      ),
    );
  }

  Future<void> _savePDF(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }
}
