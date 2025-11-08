import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/models/purchase/purchase_invoice_item.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PurchaseInvoicePrintWidget extends StatelessWidget {
  final PurchaseInvoiceModel invoice;

  const PurchaseInvoicePrintWidget({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text('طباعة فاتورة شراء 🖨️'),
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
          label: const Text('طباعة الفاتورة'),
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
                  'فاتورة شراء',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'رقم: ${invoice.id.substring(invoice.id.length - 6)}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ معلومات المورد والتاريخ
              _pdfRow('المورد:', invoice.supplierName),
              _pdfRow(
                'التاريخ:',
                DateFormat('yyyy/MM/dd').format(invoice.invoiceDate),
              ),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ المنتجات
              pw.Text(
                'المنتجات:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              
              ...invoice.items.map((item) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // اسم المنتج
                      pw.Text(
                        item.product.name,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      
                      // الكمية والسعر
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.quantity} × ${currencyFormat.format(item.buyPrice)}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            currencyFormat.format(item.subtotal),
                            style: pw.TextStyle(
                              fontSize: 9,
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
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ الإجمالي قبل الخصم
              if (invoice.discount > 0) ...[
                _pdfRow(
                  'المجموع:',
                  currencyFormat.format(invoice.totalBeforeDiscount),
                ),
                _pdfRow(
                  'الخصم:',
                  '- ${currencyFormat.format(invoice.discount)}',
                ),
                pw.Divider(thickness: 1.5),
              ],
              
              // ✅ الإجمالي النهائي
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      currencyFormat.format(invoice.totalAfterDiscount),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'الإجمالي:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),
              
              // ✅ التوقيعات
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        '__________',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'المشتري',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        '__________',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'المورد',
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ],
                  ),
                ],
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
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9),
              overflow: pw.TextOverflow.clip,
            ),
          ),
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
