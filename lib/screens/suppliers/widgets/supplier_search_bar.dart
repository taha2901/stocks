import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/cubits/suppliers/states.dart';

class SupplierSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SupplierSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupplierCubit, SupplierState>(
      builder: (context, state) {
        return CustomInputField(
          controller: controller,
          label: "بحث باسم المورد",
          hint: "اكتب اسم المورد للبحث...",
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          onChanged: onSearch,
        );
      },
    );
  }
}
