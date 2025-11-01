import 'package:flutter/material.dart';
import 'package:management_stock/models/suppliers.dart';

class SupplierDeleteDialog extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onConfirm;

  const SupplierDeleteDialog({
    super.key,
    required this.supplier,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المورد "${supplier.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
