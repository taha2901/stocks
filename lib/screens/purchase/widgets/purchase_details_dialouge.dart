import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/models/purchase/purchase_invoice_item.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_print.dart';

class PurchaseInvoiceDetailsDialog extends StatelessWidget {
  final PurchaseInvoiceModel invoice;

  const PurchaseInvoiceDetailsDialog({super.key, required this.invoice});

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
                            builder: (_) => PurchaseInvoicePrintWidget(invoice: invoice),
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
                      'تفاصيل فاتورة الشراء 📋',
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
                  _buildInfoRow('المورد:', invoice.supplierName),
                  const SizedBox(height: 8),
                  _buildInfoRow('التاريخ:', DateFormat('yyyy/MM/dd - HH:mm').format(invoice.invoiceDate)),
                  const SizedBox(height: 8),
                  _buildInfoRow('عدد المنتجات:', '${invoice.items.length}'),
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
                    final subtotal = item.quantity * item.buyPrice;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin:  EdgeInsets.only(bottom: 8, left: 12, right: 12, top: index == 0 ? 12 : 0),
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
                                currencyFormat.format(subtotal),
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} × ${currencyFormat.format(item.buyPrice)}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.product.category,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
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
                  const Divider(color: Colors.white24, height: 24),
                  _buildTotalRow(
                    'الإجمالي النهائي:',
                    currencyFormat.format(invoice.totalAfterDiscount),
                    valueColor: Colors.green,
                    isBold: true,
                  ),
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
