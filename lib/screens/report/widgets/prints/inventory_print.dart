import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InventoryReportPrintWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String period;

  const InventoryReportPrintWidget({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text('طباعة تقرير المخزون 🖨️'),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: () => _handlePrint()),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildReportContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handlePrint(),
        label: const Text('طباعة'),
        icon: const Icon(Icons.print),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildReportContent() {
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);
    
    final totalProducts = (data['totalProducts'] ?? 0).toInt();
    final totalInventoryValue = (data['totalInventoryValue'] ?? 0).toDouble();
    final lowStockProducts = (data['lowStockProducts'] ?? 0).toInt();
    
    // 🔥 المنتجات بتيجي على شكل List (مش MapEntry هنا)
    final productsData = data['products'];
    final products = (productsData is List) ? productsData : <dynamic>[];
    
    final categoryData = data['categoryBreakdown'];
    final categoryBreakdown = (categoryData is List) ? categoryData : <dynamic>[];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('تقرير المخزون 📦', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildStatRow('إجمالي المنتجات', '$totalProducts', Colors.blue),
          const Divider(),
          _buildStatRow('قيمة المخزون', currencyFormat.format(totalInventoryValue), Colors.green),
          const Divider(),
          _buildStatRow('منتجات قاربت على النفاد', '$lowStockProducts', Colors.red),
          
          if (categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text('التصنيفات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            _buildCategoryTable(categoryBreakdown, currencyFormat),
          ],
          
          const SizedBox(height: 32),
          const Text('تفاصيل المنتجات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          _buildProductsTable(products, currencyFormat),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCategoryTable(List categories, NumberFormat currencyFormat) {
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _tableHeaderCell('التصنيف'),
            _tableHeaderCell('الكمية'),
            _tableHeaderCell('القيمة'),
          ],
        ),
        ...categories.map((cat) {
          // 🔥 هنا بيستخدم objects عادي
          final category = cat['category']?.toString() ?? 'غير محدد';
          final quantity = (cat['quantity'] ?? 0).toInt();
          final value = (cat['value'] ?? 0).toDouble();
          
          return TableRow(
            children: [
              _tableCell(category),
              _tableCell('$quantity'),
              _tableCell(currencyFormat.format(value)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProductsTable(List products, NumberFormat currencyFormat) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('لا توجد منتجات', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _tableHeaderCell('المنتج'),
            _tableHeaderCell('التصنيف'),
            _tableHeaderCell('الكمية'),
            _tableHeaderCell('القيمة'),
          ],
        ),
        ...products.map((product) {
          // 🔥 في حالة المخزون: قد يكون ProductModel أو Map
          final name = product is Map 
              ? (product['name']?.toString() ?? 'غير محدد')
              : (product.name ?? 'غير محدد');
          
          final category = product is Map
              ? (product['category']?.toString() ?? '-')
              : (product.category ?? '-');
          
          final quantity = product is Map
              ? (product['quantity'] ?? 0).toInt()
              : (product.quantity ?? 0);
          
          final sellPrice = product is Map
              ? (product['sellPrice'] ?? 0).toDouble()
              : (product.sellPrice ?? 0.0);
          
          final value = quantity * sellPrice;
          
          return TableRow(
            decoration: BoxDecoration(
              color: quantity <= 5 ? Colors.red[50] : null,
            ),
            children: [
              _tableCell(name),
              _tableCell(category),
              _tableCell('$quantity ${quantity <= 5 ? '⚠️' : ''}'),
              _tableCell(currencyFormat.format(value)),
            ],
          );
        }),
      ],
    );
  }

  Widget _tableHeaderCell(String text) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );
  
  Widget _tableCell(String text) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
  );

  Future<void> _handlePrint() async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);
    
    final totalProducts = (data['totalProducts'] ?? 0).toInt();
    final totalInventoryValue = (data['totalInventoryValue'] ?? 0).toDouble();
    final lowStockProducts = (data['lowStockProducts'] ?? 0).toInt();
    
    final productsData = data['products'];
    final products = (productsData is List) ? productsData : <dynamic>[];
    
    final categoryData = data['categoryBreakdown'];
    final categoryBreakdown = (categoryData is List) ? categoryData : <dynamic>[];

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.cairoRegular(),
          bold: await PdfGoogleFonts.cairoBold(),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('تقرير المخزون', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              _pdfStatRow('إجمالي المنتجات', '$totalProducts'),
              pw.Divider(),
              _pdfStatRow('قيمة المخزون', currencyFormat.format(totalInventoryValue)),
              pw.Divider(),
              _pdfStatRow('منتجات قاربت على النفاد', '$lowStockProducts'),
              pw.SizedBox(height: 24),
              
              if (categoryBreakdown.isNotEmpty) ...[
                pw.Text('التصنيفات:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _pdfTableCell('التصنيف', bold: true),
                        _pdfTableCell('الكمية', bold: true),
                        _pdfTableCell('القيمة', bold: true),
                      ],
                    ),
                    ...categoryBreakdown.map((cat) {
                      final category = cat['category']?.toString() ?? 'غير محدد';
                      final quantity = (cat['quantity'] ?? 0).toInt();
                      final value = (cat['value'] ?? 0).toDouble();
                      
                      return pw.TableRow(
                        children: [
                          _pdfTableCell(category),
                          _pdfTableCell('$quantity'),
                          _pdfTableCell(currencyFormat.format(value)),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 24),
              ],
              
              pw.Text('تفاصيل المنتجات:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 12),
              if (products.isNotEmpty)
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _pdfTableCell('المنتج', bold: true),
                        _pdfTableCell('التصنيف', bold: true),
                        _pdfTableCell('الكمية', bold: true),
                        _pdfTableCell('القيمة', bold: true),
                      ],
                    ),
                    ...products.map((product) {
                      final name = product is Map 
                          ? (product['name']?.toString() ?? 'غير محدد')
                          : (product.name ?? 'غير محدد');
                      
                      final category = product is Map
                          ? (product['category']?.toString() ?? '-')
                          : (product.category ?? '-');
                      
                      final quantity = product is Map
                          ? (product['quantity'] ?? 0).toInt()
                          : (product.quantity ?? 0);
                      
                      final sellPrice = product is Map
                          ? (product['sellPrice'] ?? 0).toDouble()
                          : (product.sellPrice ?? 0.0);
                      
                      final value = quantity * sellPrice;
                      
                      return pw.TableRow(
                        children: [
                          _pdfTableCell(name),
                          _pdfTableCell(category),
                          _pdfTableCell('$quantity'),
                          _pdfTableCell(currencyFormat.format(value)),
                        ],
                      );
                    }),
                  ],
                )
              else
                pw.Center(child: pw.Text('لا توجد منتجات')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _pdfTableCell(String text, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10),
    ),
  );
}
