import 'package:flutter/material.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesInvoicePrintWidget extends StatelessWidget {
  final SalesInvoiceModel invoice;

  const SalesInvoicePrintWidget({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طباعة فاتورة بيع 🖨️'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _handlePrint(),
          ),
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
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الفاتورة
          Center(
            child: Column(
              children: [
                const Text(
                  'فاتورة بيع',
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

          // معلومات العميل والتاريخ ونوع الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('العميل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(invoice.customerName ?? 'غير محدد', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('التاريخ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '${invoice.invoiceDate?.day}/${invoice.invoiceDate?.month}/${invoice.invoiceDate?.year}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('نوع الدفع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    invoice.paymentType ?? 'غير محدد',
                    style: TextStyle(
                      fontSize: 16,
                      color: invoice.paymentType == 'آجل' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // جدول المنتجات
          _buildItemsTable(),
          const SizedBox(height: 24),

          // الإجماليات
          _buildTotalSection(),

          // إذا كان الدفع آجل، اعرض تفاصيل الدفع
          if (invoice.paymentType == 'آجل') ...[
            const SizedBox(height: 16),
            _buildDeferredPaymentSection(),
          ],

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // التوقيعات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('_________________'),
                  const SizedBox(height: 4),
                  const Text('توقيع العميل', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('_________________'),
                  const SizedBox(height: 4),
                  const Text('توقيع البائع', style: TextStyle(fontSize: 12)),
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
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _tableHeaderCell('اسم المنتج'),
            _tableHeaderCell('الكمية'),
            _tableHeaderCell('سعر الوحدة'),
            _tableHeaderCell('الإجمالي'),
          ],
        ),
        ...invoice.items.map((item) {
          return TableRow(
            children: [
              _tableCell(item.product.name),
              _tableCell('${item.quantity}'),
              _tableCell('${item.sellPrice.toStringAsFixed(2)} ج.م'),
              _tableCell('${item.subtotal.toStringAsFixed(2)} ج.م'),
            ],
          );
        }),
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
      child: Column(
        children: [
          _summaryRow('الإجمالي قبل الخصم:', '${invoice.totalBeforeDiscount.toStringAsFixed(2)} ج.م'),
          if (invoice.discount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow('الخصم:', '${invoice.discount.toStringAsFixed(2)} ج.م', color: Colors.red),
          ],
          const Divider(height: 20),
          _summaryRow(
            'الإجمالي بعد الخصم:',
            '${invoice.totalAfterDiscount.toStringAsFixed(2)} ج.م',
            isBold: true,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDeferredPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 تفاصيل الدفع الآجل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 12),
          _summaryRow('نسبة الفائدة:', '${invoice.interestRate.toStringAsFixed(2)}%'),
          const SizedBox(height: 8),
          _summaryRow('الإجمالي بعد الفائدة:', '${invoice.totalAfterInterest.toStringAsFixed(2)} ج.م', isBold: true),
          const Divider(height: 20),
          _summaryRow('المدفوع الآن:', '${invoice.paidNow.toStringAsFixed(2)} ج.م', color: Colors.green),
          const SizedBox(height: 8),
          _summaryRow(
            'المتبقي:',
            '${invoice.remaining.toStringAsFixed(2)} ج.م',
            isBold: true,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    pw.Text('فاتورة بيع', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('رقم الفاتورة: ${invoice.id}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // معلومات العميل والتاريخ ونوع الدفع
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('العميل:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.customerName ?? 'غير محدد'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('التاريخ:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${invoice.invoiceDate?.day}/${invoice.invoiceDate?.month}/${invoice.invoiceDate?.year}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('نوع الدفع:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.paymentType ?? 'غير محدد'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // جدول المنتجات
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _pdfTableCell('اسم المنتج', bold: true),
                      _pdfTableCell('الكمية', bold: true),
                      _pdfTableCell('سعر الوحدة', bold: true),
                      _pdfTableCell('الإجمالي', bold: true),
                    ],
                  ),
                  ...invoice.items.map((item) {
                    return pw.TableRow(
                      children: [
                        _pdfTableCell(item.product.name),
                        _pdfTableCell('${item.quantity}'),
                        _pdfTableCell('${item.sellPrice.toStringAsFixed(2)} ج.م'),
                        _pdfTableCell('${item.subtotal.toStringAsFixed(2)} ج.م'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 24),

              // الإجماليات
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _pdfSummaryRow('الإجمالي قبل الخصم:', '${invoice.totalBeforeDiscount.toStringAsFixed(2)} ج.م'),
                    if (invoice.discount > 0) ...[
                      pw.SizedBox(height: 8),
                      _pdfSummaryRow('الخصم:', '${invoice.discount.toStringAsFixed(2)} ج.م'),
                    ],
                    pw.Divider(),
                    _pdfSummaryRow('الإجمالي بعد الخصم:', '${invoice.totalAfterDiscount.toStringAsFixed(2)} ج.م', bold: true),
                  ],
                ),
              ),

              // تفاصيل الدفع الآجل
              if (invoice.paymentType == 'آجل') ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('تفاصيل الدفع الآجل', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      pw.SizedBox(height: 12),
                      _pdfSummaryRow('نسبة الفائدة:', '${invoice.interestRate.toStringAsFixed(2)}%'),
                      pw.SizedBox(height: 8),
                      _pdfSummaryRow('الإجمالي بعد الفائدة:', '${invoice.totalAfterInterest.toStringAsFixed(2)} ج.م', bold: true),
                      pw.Divider(),
                      _pdfSummaryRow('المدفوع الآن:', '${invoice.paidNow.toStringAsFixed(2)} ج.م'),
                      pw.SizedBox(height: 8),
                      _pdfSummaryRow('المتبقي:', '${invoice.remaining.toStringAsFixed(2)} ج.م', bold: true),
                    ],
                  ),
                ),
              ],
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
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  pw.Widget _pdfSummaryRow(String label, String value, {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }
}
