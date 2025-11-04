import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';
import 'package:management_stock/screens/sales/widgets/sales_print.dart';

class SalesInvoiceDetailsDialog extends StatelessWidget {
  final SalesInvoiceModel invoice;

  const SalesInvoiceDetailsDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);

    return Dialog(
      backgroundColor: const Color(0xFF2C2F48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SalesInvoicePrintWidget(invoice: invoice),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('طباعة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'تفاصيل فاتورة البيع 🧾',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رقم الفاتورة: ${invoice.id.substring(0, 8)}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),

            // معلومات الفاتورة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF353855),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('العميل:', invoice.customerName ?? 'غير محدد'),
                  const SizedBox(height: 8),
                  _buildInfoRow('التاريخ:', DateFormat('yyyy/MM/dd - HH:mm').format(invoice.invoiceDate!)),
                  const SizedBox(height: 8),
                  _buildInfoRow('نوع الدفع:', invoice.paymentType ?? 'كاش'),
                  if (invoice.paymentType == 'آجل') ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('نسبة الفائدة:', '${(invoice.interestRate * 100).toStringAsFixed(0)}%'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // المنتجات
            const Text(
              'المنتجات:',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF353855),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: invoice.items.length,
                  itemBuilder: (context, index) {
                    final item = invoice.items[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: EdgeInsets.only(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        top: index == 0 ? 12 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2F48),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currencyFormat.format(item.subtotal),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} × ${currencyFormat.format(item.sellPrice)}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Text(
                              item.product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // الإجمالي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF353855),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTotalRow('الإجمالي قبل الخصم:', currencyFormat.format(invoice.totalBeforeDiscount)),
                  if (invoice.discount > 0) ...[
                    const SizedBox(height: 8),
                    _buildTotalRow('الخصم:', currencyFormat.format(invoice.discount), valueColor: Colors.orange),
                  ],
                  const SizedBox(height: 8),
                  _buildTotalRow('الإجمالي بعد الخصم:', currencyFormat.format(invoice.totalAfterDiscount)),
                  if (invoice.paymentType == 'آجل' && invoice.interestRate > 0) ...[
                    const SizedBox(height: 8),
                    _buildTotalRow('الفائدة:', currencyFormat.format(invoice.totalAfterDiscount * invoice.interestRate), valueColor: Colors.red),
                    const SizedBox(height: 8),
                    _buildTotalRow('الإجمالي بعد الفائدة:', currencyFormat.format(invoice.totalAfterInterest)),
                  ],
                  if (invoice.paymentType == 'آجل') ...[
                    const Divider(color: Colors.white24, height: 24),
                    _buildTotalRow('المدفوع:', currencyFormat.format(invoice.paidNow), valueColor: Colors.blue),
                    const SizedBox(height: 8),
                    _buildTotalRow(
                      'المتبقي:',
                      currencyFormat.format(invoice.remaining),
                      valueColor: invoice.remaining > 0 ? Colors.red : Colors.green,
                      isBold: true,
                    ),
                  ] else ...[
                    const Divider(color: Colors.white24, height: 24),
                    _buildTotalRow(
                      'الإجمالي النهائي:',
                      currencyFormat.format(invoice.totalAfterDiscount),
                      valueColor: Colors.green,
                      isBold: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white70,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
