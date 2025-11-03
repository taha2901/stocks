import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ProfitReportPrintWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;

  const ProfitReportPrintWidget({
    super.key,
    required this.data,
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text('طباعة تقرير الأرباح 🖨️'),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: () => _handlePrint()),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
    
    final totalRevenue = (data['totalRevenue'] ?? 0).toDouble();
    final totalCost = (data['totalCost'] ?? 0).toDouble();
    final grossProfit = (data['grossProfit'] ?? 0).toDouble();
    final profitMargin = (data['profitMargin'] ?? 0).toDouble();
    
    // 🔥 البيانات بتيجي List<MapEntry> - key: اسم المنتج, value: الربح
    final topProfitData = data['topProfitProducts'];
    final topProfitProducts = (topProfitData is List) ? topProfitData.cast<MapEntry>() : <MapEntry>[];

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
                const Text('تقرير الأرباح 💰', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('الفترة: $period', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                if (startDate != null && endDate != null)
                  Text(
                    '${DateFormat('yyyy/MM/dd').format(startDate!)} - ${DateFormat('yyyy/MM/dd').format(endDate!)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildStatRow('إجمالي الإيرادات', currencyFormat.format(totalRevenue), Colors.green),
          const Divider(),
          _buildStatRow('إجمالي التكاليف', currencyFormat.format(totalCost), Colors.red),
          const Divider(thickness: 2),
          _buildStatRow('صافي الربح', currencyFormat.format(grossProfit), Colors.blue),
          const Divider(),
          _buildStatRow('هامش الربح', '${(profitMargin * 100).toStringAsFixed(1)}%', Colors.orange),
          const SizedBox(height: 32),
          const Text('أعلى المنتجات ربحاً:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          _buildTopProfitProductsTable(topProfitProducts, currencyFormat),
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

  Widget _buildTopProfitProductsTable(List<MapEntry> products, NumberFormat currencyFormat) {
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
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _tableHeaderCell('المنتج'),
            _tableHeaderCell('الربح'),
          ],
        ),
        ...products.take(10).map((product) {
          final productName = product.key?.toString() ?? 'غير محدد';
          final profit = (product.value ?? 0).toDouble();
          
          return TableRow(
            children: [
              _tableCell(productName),
              _tableCell(currencyFormat.format(profit)),
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
    
    final totalRevenue = (data['totalRevenue'] ?? 0).toDouble();
    final totalCost = (data['totalCost'] ?? 0).toDouble();
    final grossProfit = (data['grossProfit'] ?? 0).toDouble();
    final profitMargin = (data['profitMargin'] ?? 0).toDouble();
    
    final topProfitData = data['topProfitProducts'];
    final topProfitProducts = (topProfitData is List) ? topProfitData.cast<MapEntry>() : <MapEntry>[];

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
                    pw.Text('تقرير الأرباح', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('الفترة: $period'),
                    if (startDate != null && endDate != null)
                      pw.Text('${DateFormat('yyyy/MM/dd').format(startDate!)} - ${DateFormat('yyyy/MM/dd').format(endDate!)}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              _pdfStatRow('إجمالي الإيرادات', currencyFormat.format(totalRevenue)),
              pw.Divider(),
              _pdfStatRow('إجمالي التكاليف', currencyFormat.format(totalCost)),
              pw.Divider(thickness: 2),
              _pdfStatRow('صافي الربح', currencyFormat.format(grossProfit)),
              pw.Divider(),
              _pdfStatRow('هامش الربح', '${(profitMargin * 100).toStringAsFixed(1)}%'),
              pw.SizedBox(height: 24),
              pw.Text('أعلى المنتجات ربحاً:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 16),
              if (topProfitProducts.isNotEmpty)
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _pdfTableCell('المنتج', bold: true),
                        _pdfTableCell('الربح', bold: true),
                      ],
                    ),
                    ...topProfitProducts.take(10).map((product) {
                      final productName = product.key?.toString() ?? 'غير محدد';
                      final profit = (product.value ?? 0).toDouble();
                      
                      return pw.TableRow(
                        children: [
                          _pdfTableCell(productName),
                          _pdfTableCell(currencyFormat.format(profit)),
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
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
    ),
  );
}
