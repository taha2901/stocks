import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/sales_invoice_item.dart';
import 'package:management_stock/models/sales_invoice_model.dart';

class ProductsTableWidget extends StatefulWidget {
  final SalesInvoiceModel invoice;
  final VoidCallback onChanged;

  const ProductsTableWidget({
    super.key,
    required this.invoice,
    required this.onChanged,
  });

  @override
  State<ProductsTableWidget> createState() => _ProductsTableWidgetState();
}

class _ProductsTableWidgetState extends State<ProductsTableWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Column(
          children: widget.invoice.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ProductRowWidget(
              item: item,
              index: index,
              invoice: widget.invoice,
              isMobile: isMobile,
              onChanged: widget.onChanged,
            );
          }).toList(),
        );
      },
    );
  }
}

class ProductRowWidget extends StatefulWidget {
  final SalesInvoiceItem item;
  final int index;
  final bool isMobile;
  final SalesInvoiceModel invoice;
  final VoidCallback onChanged;

  const ProductRowWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isMobile,
    required this.invoice,
    required this.onChanged,
  });

  @override
  State<ProductRowWidget> createState() => _ProductRowWidgetState();
}

class _ProductRowWidgetState extends State<ProductRowWidget> {
  @override
  Widget build(BuildContext context) {
    final qty = widget.item.quantity;
    final subtotal = widget.item.subtotal;

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
          // Dropdown للمنتج
          CustomInputField(
            hint: "اختر المنتج",
            items: dummyProducts.map((p) => p.name).toList(),
            selectedValue: widget.item.product.name,
            onItemSelected: (selectedName) {
              if (selectedName != null) {
                final selectedProduct = dummyProducts.firstWhere(
                  (p) => p.name == selectedName,
                );
                setState(() => widget.invoice.items[widget.index].product = selectedProduct);
                widget.onChanged();
              }
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // counter للكمية
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3050),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white70, size: 15),
                      onPressed: () {
                        setState(() {
                          if (widget.invoice.items[widget.index].quantity > 1) {
                            widget.invoice.items[widget.index].quantity--;
                          }
                        });
                        widget.onChanged();
                      },
                    ),
                    Text(qty.toString(), style: const TextStyle(color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white70, size: 15),
                      onPressed: () {
                        setState(() => widget.invoice.items[widget.index].quantity++);
                        widget.onChanged();
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
                  controller: TextEditingController(text: widget.item.buyPrice.toString()),
                  isNumber: true,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0;
                    setState(() => widget.invoice.items[widget.index].buyPrice = price);
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              // سعر البيع
              Expanded(
                child: CustomInputField(
                  hint: "سعر البيع",
                  controller: TextEditingController(text: widget.item.sellPrice.toString()),
                  isNumber: true,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0;
                    setState(() => widget.invoice.items[widget.index].sellPrice = price);
                    widget.onChanged();
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => widget.invoice.items.removeAt(widget.index));
                  widget.onChanged();
                },
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "الإجمالي: ${subtotal.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
