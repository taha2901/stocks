import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/sales/sales_invoice_item.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';
class ProductRowWidget extends StatefulWidget {
  final SalesInvoiceItem item;
  final int index;
  final bool isMobile;
  final SalesInvoiceModel invoice;
  final VoidCallback onChanged;
  final List<ProductModel> products; // مرر قائمة المنتجات بدل dummy

  const ProductRowWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isMobile,
    required this.invoice,
    required this.onChanged,
    required this.products,
  });

  @override
  State<ProductRowWidget> createState() => _ProductRowWidgetState();
}

class _ProductRowWidgetState extends State<ProductRowWidget> {
  late final TextEditingController buyCtrl;
  late final TextEditingController sellCtrl;

  @override
  void initState() {
    super.initState();
    buyCtrl = TextEditingController(text: widget.item.buyPrice.toString());
    sellCtrl = TextEditingController(text: widget.item.sellPrice.toString());
  }

  @override
  void didUpdateWidget(covariant ProductRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.buyPrice != widget.item.buyPrice) {
      buyCtrl.text = widget.item.buyPrice.toString();
    }
    if (oldWidget.item.sellPrice != widget.item.sellPrice) {
      sellCtrl.text = widget.item.sellPrice.toString();
    }
  }

  @override
  void dispose() {
    buyCtrl.dispose();
    sellCtrl.dispose();
    super.dispose();
  }

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
          CustomInputField(
            hint: "اختر المنتج",
            items: widget.products.map((p) => p.name).toList(),
            selectedValue: widget.item.product.name,
            onItemSelected: (selectedName) {
              if (selectedName == null) return;
              final p = widget.products.firstWhere((x) => x.name == selectedName);
              setState(() {
                widget.invoice.items[widget.index].product = p;
              });
              widget.onChanged();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _QtyCounter(
                quantity: qty,
                onDec: () {
                  if (widget.invoice.items[widget.index].quantity > 1) {
                    setState(() => widget.invoice.items[widget.index].quantity--);
                    widget.onChanged();
                  }
                },
                onInc: () {
                  setState(() => widget.invoice.items[widget.index].quantity++);
                  widget.onChanged();
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomInputField(
                  hint: "سعر الشراء",
                  controller: buyCtrl,
                  isNumber: true,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0;
                    widget.invoice.items[widget.index].buyPrice = price;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomInputField(
                  hint: "سعر البيع",
                  controller: sellCtrl,
                  isNumber: true,
                  onChanged: (val) {
                    final price = double.tryParse(val) ?? 0;
                    widget.invoice.items[widget.index].sellPrice = price;
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
          Text("الإجمالي: ${subtotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _QtyCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _QtyCounter({required this.quantity, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E3050),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.remove, color: Colors.white70, size: 15), onPressed: onDec),
          Text(quantity.toString(), style: const TextStyle(color: Colors.white)),
          IconButton(icon: const Icon(Icons.add, color: Colors.white70, size: 15), onPressed: onInc),
        ],
      ),
    );
  }
}
