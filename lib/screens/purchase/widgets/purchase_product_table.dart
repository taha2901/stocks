import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/models/purchase/purchase_invoice_item.dart';

class PurchaseProductsTable extends StatelessWidget {
  final List<PurchaseInvoiceItem> invoiceItems;
  final VoidCallback onAddProduct;
  final void Function(int index) onRemove;
  final void Function(int index, int newQty) onQuantityChanged;
  final void Function(int index, double newBuyPrice) onBuyPriceChanged;
  final void Function(int index, double newSellPrice) onSellPriceChanged;

  const PurchaseProductsTable({
    super.key,
    required this.invoiceItems,
    required this.onAddProduct,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onBuyPriceChanged,
    required this.onSellPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // المنتجات
        Column(
          children: invoiceItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF353855),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // counter
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E3050),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  color: Colors.white70, size: 15),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  onQuantityChanged(index, item.quantity - 1);
                                }
                              },
                            ),
                            Text(
                              item.quantity.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Colors.white70, size: 15),
                              onPressed: () {
                                onQuantityChanged(index, item.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // سعر الشراء
                      Expanded(
                        child: CustomInputField(
                          hint: "سعر الشراء",
                          controller: TextEditingController(
                            text: item.buyPrice.toString(),
                          ),
                          isNumber: true,
                          onChanged: (val) {
                            final price = double.tryParse(val) ?? 0;
                            onBuyPriceChanged(index, price);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // سعر البيع
                      Expanded(
                        child: CustomInputField(
                          hint: "سعر البيع",
                          controller: TextEditingController(
                            text: item.sellPrice.toString(),
                          ),
                          isNumber: true,
                          onChanged: (val) {
                            final price = double.tryParse(val) ?? 0;
                            onSellPriceChanged(index, price);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      Text(
                        "الإجمالي: ${item.subtotal.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => onRemove(index),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerLeft,
          child: CustomButton(
            text: "إضافة منتج",
            icon: Icons.add,
            onPressed: onAddProduct,
          ),
        ),
      ],
    );
  }
}
