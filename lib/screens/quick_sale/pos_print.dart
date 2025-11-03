import 'package:flutter/material.dart';
import 'package:management_stock/models/pos/pos_sales_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class POSSalePrintWidget extends StatelessWidget {
  final POSSaleModel sale;

  const POSSalePrintWidget({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طباعة فاتورة POS 🖨️'),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: () => _handlePrint()),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildInvoiceContent(),
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

  Widget _buildInvoiceContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('فاتورة بيع سريع', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year} - ${sale.saleDate.hour}:${sale.saleDate.minute}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildItemsTable(),
          const SizedBox(height: 16),
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
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
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('${sale.total.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(padding: const EdgeInsets.all(12), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  Widget _tableCell(String text) {
    return Padding(padding: const EdgeInsets.all(12), child: Text(text, textAlign: TextAlign.center));
  }

  Future<void> _handlePrint() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: await PdfGoogleFonts.cairoRegular(), bold: await PdfGoogleFonts.cairoBold()),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('فاتورة بيع سريع', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}'),
              pw.SizedBox(height: 24),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الإجمالي:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${sale.total.toStringAsFixed(2)} ج.م', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfTableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }
}
