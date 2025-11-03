import 'package:flutter/material.dart';
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
        title: const Text('طباعة فاتورة شراء 🖨️'),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: _handlePrint),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildInvoiceContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handlePrint,
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
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الفاتورة
          Center(
            child: Column(
              children: [
                const Text(
                  'فاتورة شراء',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'رقم الفاتورة: ${invoice.id}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // معلومات المورد والتاريخ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المورد:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.supplierName,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التاريخ:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // جدول البيانات
          _buildItemsTable(),
          const SizedBox(height: 24),

          // الإجمالي
          _buildTotalSection(),
          const SizedBox(height: 24),

          // الملاحظات
          // if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
          //   const Divider(),
          //   const SizedBox(height: 16),
          //   Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text(
          //         'ملاحظات:',
          //         style: TextStyle(fontWeight: FontWeight.bold),
          //       ),
          //       const SizedBox(height: 8),
          //       Text(invoice.notes!),
          //     ],
          //   ),
          // ],
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // توقيع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('_________________'),
                  const SizedBox(height: 4),
                  const Text('توقيع المورد', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('_________________'),
                  const SizedBox(height: 4),
                  const Text('توقيع المشتري', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
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
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _tableHeaderCell('اسم المنتج'),
            _tableHeaderCell('الكمية'),
            _tableHeaderCell('سعر الوحدة'),
            _tableHeaderCell('الإجمالي'),
          ],
        ),
        // Items
        ...invoice.items.map((item) {
          return TableRow(
            children: [
              _tableCell(item.product.name),
              _tableCell('${item.quantity}'),
              _tableCell(
                '${item.buyPrice.toStringAsFixed(2)} ج.م',
              ), // سعر الشراء
              _tableCell('${item.subtotal.toStringAsFixed(2)} ج.م'), // الإجمالي
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'إجمالي الفاتورة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${invoice.totalAfterDiscount.toStringAsFixed(2)} ج.م',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, textAlign: TextAlign.center),
    );
  }

  Future<void> _handlePrint() async {
    final pdf = pw.Document();

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
              // رأس الفاتورة
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'فاتورة شراء',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('رقم الفاتورة: ${invoice.id}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // معلومات المورد والتاريخ
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'المورد:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(invoice.supplierName),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'التاريخ:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // جدول المنتجات
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _pdfTableCell('اسم المنتج', bold: true),
                      _pdfTableCell('الكمية', bold: true),
                      _pdfTableCell('سعر الوحدة', bold: true),
                      _pdfTableCell('الإجمالي', bold: true),
                    ],
                  ),
                  // Items
                  ...invoice.items.map((item) {
                    return pw.TableRow(
                      children: [
                        _pdfTableCell(item.product.name),
                        _pdfTableCell('${item.quantity}'),
                        _pdfTableCell(
                          '${item.buyPrice.toStringAsFixed(2)} ج.م',
                        ),
                        _pdfTableCell(
                          '${item.subtotal.toStringAsFixed(2)} ج.م',
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 24),

              // الإجمالي
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'إجمالي الفاتورة:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${invoice.totalAfterDiscount.toStringAsFixed(2)} ج.م',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
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

  pw.Widget _pdfTableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  BuildContext get context => throw UnimplementedError();
}
