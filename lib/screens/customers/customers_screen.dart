import 'package:flutter/material.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/models/customer.dart';
import 'package:management_stock/core/widgets/custom_button.dart'; 

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> customers = dummyCustomers;

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CustomButton(
                  text: "إضافة عميل جديد",
                  icon: Icons.person_add,
                  onPressed: () {
                    Navigator.pushNamed(context, Routers.addCustomerRoute);
                  },
                  backgroundColor: const Color(0xFF2C2F48),
                  textColor: Colors.white,
                ),
                const SizedBox(width: 10),
                CustomButton(
                  text: "العودة لقائمة التحكم",
                  icon: Icons.arrow_back,
                  isOutlined: true,
                  borderColor: Colors.grey,
                  textColor: Colors.grey[300],
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 🔹 قائمة العملاء
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cols = _columnsForWidth(constraints.maxWidth);
                  if (cols == 1) {
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
                            leading: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              '📞 ${c.phone}\n🏠 ${c.address}\n📝 ${c.notes}',
                              style: const TextStyle(
                                height: 1.4,
                                color: Colors.white,
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '📞 ${c.phone}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '🏠 ${c.address}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}