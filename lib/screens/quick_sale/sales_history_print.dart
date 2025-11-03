import 'package:flutter/material.dart';
import 'package:management_stock/models/pos/pos_sales_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesHistoryPrintWidget extends StatelessWidget {
  final List<POSSaleModel> sales;

  const SalesHistoryPrintWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طباعة سجل المبيعات 🖨️'),
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
            child: _buildSalesContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handlePrint(),
        label: const Text('طباعة'),
        icon: const Icon(Icons.print),
      ),
    );
  }

  Widget _buildSalesContent() {
    final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.total);

    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: const Text('سجل المبيعات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87))),
          const SizedBox(height: 8),
          Center(child: Text('إجمالي المبيعات: ${totalRevenue.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold))),
          const SizedBox(height: 24),
          ...sales.map((sale) => _buildSaleCard(sale)),
        ],
      ),
    );
  }

  Widget _buildSaleCard(POSSaleModel sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي: ${sale.total.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  _tableHeaderCell('المنتج'),
                  _tableHeaderCell('الكمية'),
                  _tableHeaderCell('السعر'),
                  _tableHeaderCell('الإجمالي'),
                ],
              ),
              ...sale.items.map((item) {
                return TableRow(
                  children: [
                    _tableCell(item.product.name),
                    _tableCell('${item.quantity}'),
                    _tableCell('${item.price.toStringAsFixed(2)} ج.م'),
                    _tableCell('${item.total.toStringAsFixed(2)} ج.م'),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text) => Padding(padding: const EdgeInsets.all(8), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)));
  Widget _tableCell(String text) => Padding(padding: const EdgeInsets.all(8), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)));

  Future<void> _handlePrint() async {
    final pdf = pw.Document();
    final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.total);

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: await PdfGoogleFonts.cairoRegular(), bold: await PdfGoogleFonts.cairoBold()),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('سجل المبيعات', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('إجمالي المبيعات: ${totalRevenue.toStringAsFixed(2)} ج.م', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              ...sales.map((sale) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('الإجمالي: ${sale.total.toStringAsFixed(2)} ج.م', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}'),
                          ],
                        ),
                      ),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                            children: [
                              _pdfTableCell('المنتج', bold: true),
                              _pdfTableCell('الكمية', bold: true),
                              _pdfTableCell('السعر', bold: true),
                              _pdfTableCell('الإجمالي', bold: true),
                            ],
                          ),
                          ...sale.items.map((item) {
                            return pw.TableRow(
                              children: [
                                _pdfTableCell(item.product.name),
                                _pdfTableCell('${item.quantity}'),
                                _pdfTableCell('${item.price.toStringAsFixed(2)} ج.م'),
                                _pdfTableCell('${item.total.toStringAsFixed(2)} ج.م'),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfTableCell(String text, {bool bold = false}) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10)));
}
