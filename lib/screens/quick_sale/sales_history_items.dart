import 'package:flutter/material.dart';
import 'package:management_stock/models/pos/pos_sales_model.dart';

class SalesHistoryItem extends StatelessWidget {
  final POSSaleModel sale;
  final bool isDesktop;

  const SalesHistoryItem({
    super.key,
    required this.sale,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: isDesktop ? 800 : 400),
              child: _buildItemsTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF353855),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "الإجمالي: ${sale.total.toStringAsFixed(2)} ج.م",
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
          Text(
            "${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Table(
      border: TableBorder.all(color: Colors.white24),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFF42455E)),
          children: [
            _TableHeader("المنتج"),
            _TableHeader("الكمية"),
            _TableHeader("السعر"),
            _TableHeader("الإجمالي"),
          ],
        ),
        ...sale.items.map(_buildItemRow),
      ],
    );
  }

  TableRow _buildItemRow(item) {
    return TableRow(
      children: [
        _TableData(item.product.name),
        _TableData("${item.quantity}"),
        _TableData("${item.price.toStringAsFixed(2)}"),
        _TableData("${item.total.toStringAsFixed(2)}"),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }
}

class _TableData extends StatelessWidget {
  final String text;
  const _TableData(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
    );
  }
}
