import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/cubits/suppliers/states.dart';

class PurchaseHeaderWidget extends StatelessWidget {
  final String? selectedSupplier;
  final String? selectedSupplierId;
  final String? paymentType;
  final DateTime? invoiceDate;
  final ValueChanged<String?> onSupplierChanged;
  final ValueChanged<String?> onSupplierIdChanged;
  final ValueChanged<String?> onPaymentChanged;
  final ValueChanged<DateTime?> onDateChanged;

  const PurchaseHeaderWidget({
    super.key,
    required this.selectedSupplier,
    required this.selectedSupplierId,
    required this.paymentType,
    required this.invoiceDate,
    required this.onSupplierChanged,
    required this.onSupplierIdChanged,
    required this.onPaymentChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    // final paymentMethods = ['كاش', 'آجل'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // المورد - من Firebase
        BlocBuilder<SupplierCubit, SupplierState>(
          builder: (context, state) {
            // لو الموردين لسه بيتحملوا
            if (state is SupplierLoading) {
              return const CustomInputField(
                label: "المورد",
                hint: "جاري التحميل...",
                readOnly: true,
                prefixIcon: Icon(Icons.person, color: Colors.white70),
              );
            }

            // لو حصل خطأ
            if (state is SupplierError) {
              return CustomInputField(
                label: "المورد",
                hint: "خطأ في تحميل الموردين",
                readOnly: true,
                prefixIcon: const Icon(Icons.error, color: Colors.red),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () {
                    context.read<SupplierCubit>().fetchSuppliers();
                  },
                ),
              );
            }

            // لو الموردين اتحملوا بنجاح
            if (state is SupplierLoaded) {
              final suppliers = state.suppliers;

              if (suppliers.isEmpty) {
                return CustomInputField(
                  label: "المورد",
                  hint: "لا توجد موردين - أضف مورد أولاً",
                  readOnly: true,
                  prefixIcon: const Icon(Icons.info, color: Colors.orange),
                );
              }

              return CustomInputField(
                label: "المورد",
                hint: "اختر المورد",
                items: suppliers.map((s) => s.name).toList(),
                selectedValue: selectedSupplier,
                onItemSelected: (supplierName) {
                  if (supplierName != null) {
                    // البحث عن المورد المختار عشان نجيب الـ ID
                    final supplier = suppliers.firstWhere(
                      (s) => s.name == supplierName,
                    );

                    // تحديث الاسم والـ ID
                    onSupplierChanged(supplier.name);
                    onSupplierIdChanged(supplier.id);
                  }
                },
                prefixIcon: const Icon(Icons.person, color: Colors.white70),
              );
            }

            // حالة افتراضية
            return const CustomInputField(
              label: "المورد",
              hint: "اختر المورد",
              readOnly: true,
              prefixIcon: Icon(Icons.person, color: Colors.white70),
            );
          },
        ),

        const SizedBox(height: 16),

        // تاريخ الفاتورة
        CustomInputField(
          label: "تاريخ الفاتورة",
          hint: "اختر التاريخ",
          readOnly: true,
          controller: TextEditingController(
            text: invoiceDate == null
                ? ''
                : "${invoiceDate!.day}/${invoiceDate!.month}/${invoiceDate!.year}",
          ),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: invoiceDate ?? now,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Colors.blueAccent,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            onDateChanged(picked);
          },
        ),
      ],
    );
  }
}
