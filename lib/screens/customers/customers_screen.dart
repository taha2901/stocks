import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/customer.dart';
import 'package:management_stock/screens/customers/widgets/add_and_return_buttons.dart';
import 'package:management_stock/screens/customers/widgets/customer_empty_widget.dart';
import 'package:management_stock/screens/customers/widgets/customer_error_widget.dart';
import 'package:management_stock/screens/customers/widgets/customer_grid_view.dart';
import 'package:management_stock/screens/customers/widgets/customer_list_view.dart';
import 'package:management_stock/screens/customers/widgets/customer_loading_widget.dart';
import 'package:management_stock/screens/customers/widgets/search_filter_bar.dart';

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

  int _columnsForWidth(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<CustomerCubit>().fetchCustomers();
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AddAndReturnBusttons(),
              const SizedBox(height: 16),
              SearchAndFilterBar(
                searchController: _searchController,
                onCitySelected: (value) {
                  setState(() {
                    _selectedCity = value == 'الكل' ? null : value;
                  });
                  if (_selectedCity == null) {
                    context.read<CustomerCubit>().clearFilters();
                  } else {
                    context.read<CustomerCubit>().filterByCity(_selectedCity!);
                  }
                },
              ),
              const SizedBox(height: 16),
              // قائمة العملاء
              Expanded(
                child: BlocConsumer<CustomerCubit, CustomerState>(
                  listener: (context, state) {
                    if (state is CustomerOperationError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is CustomerDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف العميل بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CustomerLoading) {
                      return const CustomerLoadingWidget();
                    }

                    if (state is CustomerError) {
                      return CustomerErrorWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<CustomerCubit>().fetchCustomers();
                        },
                      );
                    }

                    if (state is CustomerLoaded) {
                      final customers = state.filteredCustomers;

                      if (customers.isEmpty) {
                        return const CustomerEmptyWidget();
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = _columnsForWidth(constraints.maxWidth);
                          if (cols == 1) {
                            return CustomerListView(
                              customers: customers,
                              onEdit: (customer) {
                                Future.delayed(Duration.zero, () {
                                  Navigator.pushNamed(
                                    context,
                                    Routers.editCustomerRoute,
                                    arguments: customer,
                                  );
                                });
                              },
                              onDelete: (customer) =>
                                  _showDeleteDialog(customer),
                            );
                          } else {
                            return CustomerGridView(
                              customers: customers,
                              crossAxisCount: cols,
                              onEdit: (customer) {
                                Future.delayed(Duration.zero, () {
                                  Navigator.pushNamed(
                                    context,
                                    Routers.editCustomerRoute,
                                    arguments: customer,
                                  );
                                });
                              },
                              onDelete: (customer) =>
                                  _showDeleteDialog(customer),
                            );
                          }
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

  void _showDeleteDialog(Customer customer) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF2C2F48),
            title: const Text(
              'تأكيد الحذف',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'هل أنت متأكد من حذف العميل "${customer.name}"؟',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<CustomerCubit>().deleteCustomer(customer.id);
                  Navigator.pop(context);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
