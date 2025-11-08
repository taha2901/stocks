import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesReportPrintWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;

  const SalesReportPrintWidget({
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
        title: const Text('طباعة تقرير المبيعات 🖨️'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _handlePrint(),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _handlePrint(),
          icon: const Icon(Icons.print),
          label: const Text('طباعة التقرير'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrint() async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);
    
    final totalSales = (data['totalSales'] ?? 0).toDouble();
    final totalTransactions = (data['totalTransactions'] ?? 0).toInt();
    final averageOrderValue = (data['averageOrderValue'] ?? 0).toDouble();
    
    final topProductsData = data['topProducts'];
    final topProducts = (topProductsData is List) 
        ? topProductsData.cast<MapEntry>() 
        : <MapEntry>[];
    
    final revenueData = data['productRevenue'];
    final revenue = (revenueData is Map) ? revenueData : {};

    pdf.addPage(
      pw.Page(
        // ✅ حجم ورق الفاتورة (80mm عرض)
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm, // العرض
          double.infinity, // الطول حسب المحتوى
          marginAll: 5 * PdfPageFormat.mm,
        ),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.cairoRegular(),
          bold: await PdfGoogleFonts.cairoBold(),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ✅ عنوان التقرير
              pw.Center(
                child: pw.Text(
                  'تقرير المبيعات',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ الفترة
              pw.Center(
                child: pw.Text(
                  'الفترة: $period',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              if (startDate != null && endDate != null)
                pw.Center(
                  child: pw.Text(
                    '${DateFormat('yyyy/MM/dd').format(startDate!)} - ${DateFormat('yyyy/MM/dd').format(endDate!)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ الإحصائيات
              _pdfRow('المبيعات:', currencyFormat.format(totalSales)),
              _pdfRow('الفواتير:', '$totalTransactions'),
              _pdfRow('متوسط الفاتورة:', currencyFormat.format(averageOrderValue)),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ أعلى المنتجات
              pw.Text(
                'أعلى المنتجات مبيعاً:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              
              if (topProducts.isNotEmpty)
                ...topProducts.take(5).map((product) {
                  final name = product.key?.toString() ?? 'غير محدد';
                  final quantity = (product.value ?? 0).toInt();
                  final productRevenue = (revenue[name] ?? 0).toDouble();
                  
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          name,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'الكمية: $quantity',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              currencyFormat.format(productRevenue),
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Divider(height: 0.5),
                      ],
                    ),
                  );
                })
              else
                pw.Center(
                  child: pw.Text(
                    'لا توجد منتجات',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 2),
              
              // ✅ التاريخ والوقت
              pw.Center(
                child: pw.Text(
                  DateFormat('yyyy/MM/dd - hh:mm a').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
