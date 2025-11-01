import 'package:flutter/material.dart';

class SupplierEmptyWidget extends StatelessWidget {
  final bool hasSearch;

  const SupplierEmptyWidget({
    super.key,
    this.hasSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'لا توجد نتائج للبحث' : 'لا توجد موردين حالياً',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
