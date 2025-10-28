import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/customer.dart';
import 'package:management_stock/core/widgets/custom_button.dart';

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
              // أزرار الأكشن
              Row(
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
              ),
              const SizedBox(height: 16),

              // شريط البحث والفلترة
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم أو الهاتف...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFF2C2F48),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      final cities = context.read<CustomerCubit>().getAvailableCities();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2F48),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCity,
                          hint: const Text(
                            'تصفية بالمدينة',
                            style: TextStyle(color: Colors.white70),
                          ),
                          dropdownColor: const Color(0xFF2C2F48),
                          icon: const Icon(Icons.filter_list, color: Colors.white70),
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'الكل',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ...cities.map((city) => DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(
                                    city,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                            if (value == null) {
                              context.read<CustomerCubit>().clearFilters();
                            } else {
                              context.read<CustomerCubit>().filterByCity(value);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // الإحصائيات
              BlocBuilder<CustomerCubit, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoaded) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2F48),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'إجمالي العملاء',
                            state.customers.length.toString(),
                            Icons.people,
                          ),
                          _buildStatItem(
                            'نتائج البحث',
                            state.filteredCustomers.length.toString(),
                            Icons.search,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
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
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                        ),
                      );
                    }

                    if (state is CustomerError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<CustomerCubit>().fetchCustomers();
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is CustomerLoaded) {
                      final customers = state.filteredCustomers;

                      if (customers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                color: Colors.grey[600],
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا يوجد عملاء',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = _columnsForWidth(constraints.maxWidth);
                          if (cols == 1) {
                            return _buildListView(customers);
                          } else {
                            return _buildGridView(customers, cols);
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListView(List<Customer> customers) {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return Card(
          elevation: 3,
          color: const Color(0xFF2C2F48),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Colors.blueAccent,
              ),
            ),
            title: Text(
              c.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      c.phone,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        c.address,
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (c.type.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c.type,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: const Color(0xFF2C2F48),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                      SizedBox(width: 8),
                      Text('تعديل', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.pushNamed(
                        context, 
                        Routers.editCustomerRoute,
                        arguments: c,
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () {
                    _showDeleteDialog(c);
                  },
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Customer> customers, int cols) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return Card(
          color: const Color(0xFF2C2F48),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  radius: 24,
                  child: const Icon(
                    Icons.person,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            c.phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF2C2F48),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                          SizedBox(width: 8),
                          Text('تعديل', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      onTap: () {
                        // TODO: Navigate to edit screen
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      onTap: () {
                        _showDeleteDialog(c);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
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