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
    
    final totalProducts = (data['totalProducts'] ?? 0).toInt();
    final totalInventoryValue = (data['totalInventoryValue'] ?? 0).toDouble();
    final lowStockProducts = (data['lowStockProducts'] ?? 0).toInt();
    
    final productsData = data['products'];
    final products = (productsData is List) ? productsData : <dynamic>[];

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
                  'تقرير المخزون',
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
                  DateFormat('yyyy/MM/dd').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              _pdfRow('المنتجات:', '$totalProducts'),
              _pdfRow('قيمة المخزون:', currencyFormat.format(totalInventoryValue)),
              _pdfRow('قارب على النفاد:', '$lowStockProducts'),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              pw.Text(
                'تفاصيل المنتجات:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              
              if (products.isNotEmpty)
                ...products.map((product) {
                  final name = product is Map 
                      ? (product['name']?.toString() ?? 'غير محدد')
                      : (product.name ?? 'غير محدد');
                  
                  final quantity = product is Map
                      ? (product['quantity'] ?? 0).toInt()
                      : (product.quantity ?? 0);
                  
                  final sellPrice = product is Map
                      ? (product['sellPrice'] ?? 0).toDouble()
                      : (product.sellPrice ?? 0.0);
                  
                  final value = quantity * sellPrice;
                  final isLowStock = quantity <= 5;
                  
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 3),
                    decoration: isLowStock 
                        ? const pw.BoxDecoration(
                            color: PdfColors.red50,
                          )
                        : null,
                    padding: const pw.EdgeInsets.all(2),
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
                              'الكمية: $quantity${isLowStock ? ' ⚠️' : ''}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              currencyFormat.format(value),
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
