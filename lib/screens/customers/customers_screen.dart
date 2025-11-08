import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CustomerCubit>().searchCustomers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        title: const Text(
          'إدارة العملاء',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C2F48),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Add button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "إضافة عميل جديد",
                      icon: Icons.person_add,
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          Routers.addCustomerRoute,
                        );
                        // ✅ ما تحتاج تفيتش - الإضافة تحدثت محلياً
                      },
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    text: "العودة",
                    icon: Icons.arrow_back,
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search bar
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomInputField(
                      controller: _searchController,
                      hint: 'ابحث بالاسم أو الهاتف...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
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
                          onItemSelected: (city) {
                            setState(
                              () =>
                                  _selectedCity = city == 'الكل' ? null : city,
                            );
                            context.read<CustomerCubit>().filterByCity(
                              _selectedCity,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Customers list
              Expanded(
                child: BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) {
                    if (state is CustomerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CustomerError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    if (state is CustomerLoaded) {
                      final customers = state.filteredCustomers;

                      if (customers.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا توجد عملاء',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return _buildCustomerCard(context, customer);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return Card(
      color: const Color(0xFF2C2F48),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(customer.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${customer.phone} • ${customer.address}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(context, customer),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
        content: Text(
          'حذف ${customer.name}؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CustomerCubit>().deleteCustomer(customer.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
