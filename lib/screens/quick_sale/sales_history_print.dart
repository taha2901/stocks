import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/models/pos/pos_sales_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesHistoryPrintWidget extends StatelessWidget {
  final List<POSSaleModel> sales;

  const SalesHistoryPrintWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    // ✅ طبع مباشرة عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePrint(context);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text('طباعة سجل المبيعات 🖨️'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _handlePrint(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);
      final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.total);

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
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ✅ العنوان
                pw.Center(
                  child: pw.Text(
                    'سجل المبيعات',
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
                _pdfRow('عدد المبيعات:', '${sales.length}'),
                _pdfRow('الإجمالي:', currencyFormat.format(totalRevenue)),
                
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 4),
                
                // ✅ تفاصيل المبيعات
                ...sales.map((sale) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // التاريخ والإجمالي
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              DateFormat('yyyy/MM/dd - hh:mm a').format(sale.saleDate),
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              currencyFormat.format(sale.total),
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        
                        // المنتجات
                        ...sale.items.map((item) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 8, top: 1),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    '${item.product.name} (${item.quantity})',
                                    style: const pw.TextStyle(fontSize: 7),
                                    overflow: pw.TextOverflow.clip,
                                  ),
                                ),
                                pw.Text(
                                  currencyFormat.format(item.total),
                                  style: const pw.TextStyle(fontSize: 7),
                                ),
                              ],
                            ),
                          );
                        }),
                        
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
      
      // ✅ بعد الطباعة، ارجع للصفحة السابقة
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
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
