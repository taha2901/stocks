import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PaymentReceiptPrintWidget extends StatelessWidget {
  final String customerName;
  final DateTime invoiceDate;
  final double totalAmount;
  final double previousPaid;
  final double currentPayment;
  final double newRemaining;
  final String? notes;

  const PaymentReceiptPrintWidget({
    super.key,
    required this.customerName,
    required this.invoiceDate,
    required this.totalAmount,
    required this.previousPaid,
    required this.currentPayment,
    required this.newRemaining,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيصال دفعة 🖨️'),
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildReceiptContent(),
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

  Widget _buildReceiptContent() {
    final now = DateTime.now();
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
          Center(
            child: Column(
              children: [
                const Text(
                  'إيصال دفعة آجل',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoRow('العميل:', customerName),
          const Divider(),
          _buildInfoRow(
            'تاريخ الفاتورة:',
            '${invoiceDate.day}/${invoiceDate.month}/${invoiceDate.year}',
          ),
          const Divider(),
          _buildInfoRow(
            'إجمالي الفاتورة:',
            '${totalAmount.toStringAsFixed(2)} جنيه',
          ),
          const Divider(),
          _buildInfoRow(
            'المدفوع سابقاً:',
            '${previousPaid.toStringAsFixed(2)} جنيه',
            valueColor: Colors.green,
          ),
          const Divider(),
          _buildInfoRow(
            'الدفعة الحالية:',
            '${currentPayment.toStringAsFixed(2)} جنيه',
            valueColor: Colors.blue,
          ),
          const Divider(thickness: 2),
          _buildInfoRow(
            'المتبقي:',
            '${newRemaining.toStringAsFixed(2)} جنيه',
            valueColor: newRemaining > 0 ? Colors.red : Colors.green,
            isBold: true,
          ),
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'ملاحظات:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notes!,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
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
                  const Text('توقيع المحاسب', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePrint() async {
    final pdf = pw.Document();
    final now = DateTime.now();

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
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'إيصال دفعة آجل',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              _pdfInfoRow('العميل:', customerName),
              pw.Divider(),
              _pdfInfoRow('تاريخ الفاتورة:', '${invoiceDate.day}/${invoiceDate.month}/${invoiceDate.year}'),
              pw.Divider(),
              _pdfInfoRow('إجمالي الفاتورة:', '${totalAmount.toStringAsFixed(2)} جنيه'),
              pw.Divider(),
              _pdfInfoRow('المدفوع سابقاً:', '${previousPaid.toStringAsFixed(2)} جنيه'),
              pw.Divider(),
              _pdfInfoRow('الدفعة الحالية:', '${currentPayment.toStringAsFixed(2)} جنيه'),
              pw.Divider(thickness: 2),
              _pdfInfoRow('المتبقي:', '${newRemaining.toStringAsFixed(2)} جنيه', bold: true),
              if (notes != null && notes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.Text('ملاحظات:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(notes!),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfInfoRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(value, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
