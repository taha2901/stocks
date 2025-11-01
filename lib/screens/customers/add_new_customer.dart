import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/customer.dart';
import 'package:management_stock/screens/customers/widgets/customer_form_field.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? selectedType;
  final List<String> customerTypes = ["قطاعي", "جملة", "آخر"];

  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void saveCustomer() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final customerId = DateTime.now().millisecondsSinceEpoch.toString();

      final customer = Customer(
        id: customerId,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        notes: noteController.text.trim(),
        type: selectedType ?? "آخر",
        creditLimit: null,
      );

      context.read<CustomerCubit>().addCustomer(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة عميل", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is CustomerAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ تم إضافة العميل بنجاح"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is CustomerOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // ✅ استخدام الويدجت المستخرج
                      CustomerFormFields(
                        nameController: nameController,
                        phoneController: phoneController,
                        addressController: addressController,
                        noteController: noteController,
                        selectedType: selectedType,
                        customerTypes: customerTypes,
                        onTypeSelected: (val) => setState(() => selectedType = val),
                      ),
                      
                      const SizedBox(height: 30),

                      // الأزرار
                      Row(
                        children: [
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                : CustomButton(
                                    text: "حفظ العميل",
                                    icon: Icons.save,
                                    onPressed: saveCustomer,
                                    backgroundColor: Colors.blueAccent,
                                    textColor: Colors.white,
                                    elevation: 3,
                                    fullWidth: true,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: "رجوع",
                              icon: Icons.arrow_back,
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              isOutlined: true,
                              borderColor: Colors.grey,
                              textColor: Colors.grey[300],
                              fullWidth: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
