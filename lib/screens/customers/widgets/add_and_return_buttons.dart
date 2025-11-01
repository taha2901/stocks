
import 'package:flutter/material.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/widgets/custom_button.dart';

class AddAndReturnBusttons extends StatelessWidget {
  const AddAndReturnBusttons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "إضافة عميل جديد",
            icon: Icons.person_add,
            onPressed: () {
              Navigator.pushNamed(context, Routers.addCustomerRoute);
            },
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        CustomButton(
          text: "العودة",
          icon: Icons.arrow_back,
          isOutlined: true,
          borderColor: Colors.grey,
          textColor: Colors.grey[300],
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}




// Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: CustomInputField(
//                       controller: _searchController,
//                       hint: 'ابحث بالاسم أو الهاتف...',
//                       prefixIcon: const Icon(
//                         Icons.search,
//                         color: Colors.white70,
//                       ),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(
//                                 Icons.clear,
//                                 color: Colors.white70,
//                               ),
//                               onPressed: () {
//                                 _searchController.clear();
//                               },
//                             )
//                           : null,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   BlocBuilder<CustomerCubit, CustomerState>(
//                     builder: (context, state) {
//                       final cities = context
//                           .read<CustomerCubit>()
//                           .getAvailableCities();
//                       return Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: CustomInputField(
//                           items: [
//                             ?null,
//                             ...cities,
//                           ], // تضمن قيمة "الكل" مع null، حسب تعريفك
//                           selectedValue: _selectedCity,
//                           label: 'تصفية بالمدينة',
//                           showBottomSheet:
//                               false, // استخدم true إذا تريد عرض القائمة كبوب-شيت
//                           onItemSelected: (value) {
//                             setState(() {
//                               _selectedCity = value;
//                             });
//                             if (value == null) {
//                               context.read<CustomerCubit>().clearFilters();
//                             } else {
//                               context.read<CustomerCubit>().filterByCity(value);
//                             }
//                           },
//                           suffixIcon: const Icon(
//                             Icons.filter_list,
//                             color: Colors.white70,
//                           ),
//                           keyboardType: TextInputType.text,
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),