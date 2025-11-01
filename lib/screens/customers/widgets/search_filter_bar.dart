import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/Customers/states.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String?) onCitySelected;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomInputField(
            controller: searchController,
            hint: 'ابحث بالاسم أو الهاتف...',
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white70,
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      searchController.clear();
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              final cities = context
                  .read<CustomerCubit>()
                  .getAvailableCities();
              return CustomInputField(
                items: ['الكل', ...cities],
                label: 'المدينة',
                showBottomSheet: false,
                onItemSelected: onCitySelected,
              );
            },
          ),
        ),
      ],
    );
  }
}
