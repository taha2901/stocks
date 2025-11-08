import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/models/product.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InventoryPrintWidget extends StatelessWidget {
  final List<ProductModel> products;

  const InventoryPrintWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text('طباعة المخزون 🖨️'),
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
          label: const Text('طباعة المخزون'),
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

    pdf.addPage(
      pw.Page(
        // ✅ حجم ورق الفاتورة (80mm)
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
              // ✅ العنوان
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
              pw.Center(
                child: pw.Text(
                  DateFormat('yyyy/MM/dd').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ الإحصائيات
              _pdfRow('إجمالي المنتجات:', '${products.length}'),
              _pdfRow(
                'قيمة المخزون:',
                currencyFormat.format(
                  products.fold(0.0, (sum, p) => sum + (p.sellPrice * p.quantity)),
                ),
              ),
              _pdfRow(
                'قاربت على النفاد:',
                '${products.where((p) => p.quantity <= 5).length}',
              ),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ تفاصيل المنتجات
              pw.Text(
                'تفاصيل المنتجات:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              
              ...products.map((product) {
                final isLowStock = product.quantity <= 5;
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
                      // اسم المنتج
                      pw.Text(
                        product.name,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      
                      // الباركود والكمية
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'باركود: ${product.barcode}',
                            style: const pw.TextStyle(fontSize: 7),
                          ),
                          pw.Text(
                            'الكمية: ${product.quantity}${isLowStock ? ' ⚠️' : ''}',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: isLowStock 
                                  ? pw.FontWeight.bold 
                                  : pw.FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1),
                      
                      // السعر
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'سعر البيع:',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            currencyFormat.format(product.sellPrice),
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Divider(height: 0.5),
                    ],
                  ),
                );
              }),
              
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
