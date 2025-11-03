import 'package:flutter/material.dart';
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
        title: const Text('طباعة المخزون 🖨️'),
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
            child: _buildInventoryContent(),
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

  Widget _buildInventoryContent() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: const Text('تقرير المخزون', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87))),
          const SizedBox(height: 8),
          Center(child: Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(fontSize: 14, color: Colors.grey))),
          const SizedBox(height: 24),
          _buildInventoryTable(),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
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
            _tableHeaderCell('الباركود'),
            _tableHeaderCell('الكمية'),
            _tableHeaderCell('سعر البيع'),
          ],
        ),
        ...products.map((product) {
          return TableRow(
            children: [
              _tableCell(product.name),
              _tableCell(product.barcode),
              _tableCell('${product.quantity}'),
              _tableCell('${product.sellPrice.toStringAsFixed(2)} ج.م'),
            ],
          );
        }),
      ],
    );
  }

  Widget _tableHeaderCell(String text) => Padding(padding: const EdgeInsets.all(12), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)));
  Widget _tableCell(String text) => Padding(padding: const EdgeInsets.all(12), child: Text(text, textAlign: TextAlign.center));

  Future<void> _handlePrint() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: await PdfGoogleFonts.cairoRegular(), bold: await PdfGoogleFonts.cairoBold()),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('تقرير المخزون', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
              pw.SizedBox(height: 24),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _pdfTableCell('المنتج', bold: true),
                      _pdfTableCell('الباركود', bold: true),
                      _pdfTableCell('الكمية', bold: true),
                      _pdfTableCell('سعر البيع', bold: true),
                    ],
                  ),
                  ...products.map((product) {
                    return pw.TableRow(
                      children: [
                        _pdfTableCell(product.name),
                        _pdfTableCell(product.barcode),
                        _pdfTableCell('${product.quantity}'),
                        _pdfTableCell('${product.sellPrice.toStringAsFixed(2)} ج.م'),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfTableCell(String text, {bool bold = false}) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(text, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)));
}
