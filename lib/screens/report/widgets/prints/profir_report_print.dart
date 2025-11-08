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
    
    final totalRevenue = (data['totalRevenue'] ?? 0).toDouble();
    final totalCost = (data['totalCost'] ?? 0).toDouble();
    final grossProfit = (data['grossProfit'] ?? 0).toDouble();
    final profitMargin = (data['profitMargin'] ?? 0).toDouble();
    
    final topProfitData = data['topProfitProducts'];
    final topProfitProducts = (topProfitData is List) 
        ? topProfitData.cast<MapEntry>() 
        : <MapEntry>[];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
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
              pw.Center(
                child: pw.Text(
                  'تقرير الأرباح',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
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
              
              _pdfRow('الإيرادات:', currencyFormat.format(totalRevenue)),
              _pdfRow('التكاليف:', currencyFormat.format(totalCost)),
              pw.Divider(thickness: 1.5),
              _pdfRow('صافي الربح:', currencyFormat.format(grossProfit)),
              _pdfRow('هامش الربح:', '${profitMargin.toStringAsFixed(1)}%'),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              pw.Text(
                'أعلى المنتجات ربحاً:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              
              if (topProfitProducts.isNotEmpty)
                ...topProfitProducts.take(5).map((product) {
                  final name = product.key?.toString() ?? 'غير محدد';
                  final profit = (product.value ?? 0).toDouble();
                  
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            name,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          currencyFormat.format(profit),
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
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
