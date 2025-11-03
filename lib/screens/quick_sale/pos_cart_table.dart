import 'package:flutter/material.dart';
import 'package:management_stock/models/pos/pos_cart_model.dart';

class POSCartTable extends StatelessWidget {
  final List<POSCartItem> cart;
  final VoidCallback onQuantityChanged;
  final Function(POSCartItem) onRemove;

  const POSCartTable({
    super.key,
    required this.cart,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.white24),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
      },
      children: [
        _buildHeaderRow(),
        ...cart.map(_buildItemRow),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFF353855)),
      children: [
        _TableCell("المنتج", TextAlign.right),
        _TableCell("الكمية", TextAlign.center),
        _TableCell("سعر الوحدة", TextAlign.center),
        _TableCell("الإجمالي", TextAlign.center),
        _TableCell("حذف", TextAlign.center),
      ],
    );
  }

  TableRow _buildItemRow(POSCartItem item) {
    return TableRow(
      children: [
        _TableCell(item.product.name, TextAlign.right),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 20),
                onPressed: () {
                  if (item.quantity > 1) {
                    item.quantity--;
                    onQuantityChanged();
                  }
                },
              ),
              Text("${item.quantity}", style: const TextStyle(color: Colors.white70)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 20),
                onPressed: () {
                  item.quantity++;
                  onQuantityChanged();
                },
              ),
            ],
          ),
        ),
        _TableCell(item.price.toStringAsFixed(2), TextAlign.center),
        _TableCell(item.total.toStringAsFixed(2), TextAlign.center),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => onRemove(item),
          ),
        ),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  const _TableCell(this.text, this.textAlign);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: const TextStyle(color: Colors.white70), textAlign: textAlign),
    );
  }
}
