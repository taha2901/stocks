import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/sales/cubit.dart';
import 'package:management_stock/cubits/sales/states.dart';
import 'package:management_stock/models/sales_invoice_item.dart';
import 'package:management_stock/models/sales_invoice_model.dart';
import 'package:management_stock/screens/sales/widgets/deffered_payment_widget.dart';
import 'package:management_stock/screens/sales/widgets/product_table_widget.dart';
import 'package:management_stock/screens/sales/widgets/total_section_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/Customers/cubit.dart';
import '../../cubits/Customers/states.dart';

class SalesInvoiceScreen extends StatefulWidget {
  const SalesInvoiceScreen({super.key});

  @override
  State<SalesInvoiceScreen> createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  SalesInvoiceModel invoice = SalesInvoiceModel();

  final TextEditingController paidNowController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  final List<String> paymentMethods = ['كاش', 'آجل'];

  @override
  void initState() {
    super.initState();
    invoice.invoiceDate = DateTime.now();
  }

  void _addProduct() {
    final productCubit = context.read<ProductCubit>();
    if (productCubit.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ لا توجد منتجات متاحة')),
      );
      return;
    }
    setState(() {
      invoice.items.add(SalesInvoiceItem(product: productCubit.products.first));
    });
  }

  void _saveInvoice() async {
    // التحقق من البيانات
    if (invoice.customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى اختيار عميل')),
      );
      return;
    }

    if (invoice.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى إضافة منتج واحد على الأقل')),
      );
      return;
    }

    if (invoice.paymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى اختيار نوع الدفع')),
      );
      return;
    }

    // حفظ معلومات الدفع الآجل
    invoice.paidNow = double.tryParse(paidNowController.text) ?? 0;
    invoice.interestRate = double.tryParse(interestRateController.text) ?? 0;

    // حفظ الفاتورة
    await context.read<SalesInvoiceCubit>().createInvoice(invoice);
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.all(MediaQuery.of(context).size.width * 0.04);

    return BlocListener<SalesInvoiceCubit, SalesInvoiceState>(
      listener: (context, state) {
        if (state is SalesInvoiceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is SalesInvoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E2030),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C2F48),
          elevation: 4,
          title: const Text(
            "فاتورة بيع جديدة 🧾",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SalesInvoiceCubit, SalesInvoiceState>(
          builder: (context, state) {
            if (state is SalesInvoiceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: padding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 950),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2F48),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اختيار العميل
                        BlocBuilder<CustomerCubit, CustomerState>(
                          builder: (context, customerState) {
                            if (customerState is CustomerLoaded) {
                              final customers = customerState.customers;
                              return CustomInputField(
                                label: "العميل",
                                hint: "اختر العميل",
                                items: customers.map((c) => c.name).toList(),
                                selectedValue: invoice.customerName,
                                onItemSelected: (value) {
                                  final customer = customers.firstWhere(
                                    (c) => c.name == value,
                                  );
                                  setState(() {
                                    invoice.customerId = customer.id;
                                    invoice.customerName = customer.name;
                                  });
                                },
                                prefixIcon: const Icon(Icons.person, color: Colors.white70),
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        ),

                        const SizedBox(height: 16),

                        // نوع الدفع
                        CustomInputField(
                          label: "نوع الدفع",
                          hint: "اختر نوع الدفع",
                          items: paymentMethods,
                          selectedValue: invoice.paymentType,
                          onItemSelected: (value) =>
                              setState(() => invoice.paymentType = value),
                          prefixIcon: const Icon(Icons.payment, color: Colors.white70),
                        ),

                        const SizedBox(height: 16),

                        // تاريخ الفاتورة
                        CustomInputField(
                          label: "تاريخ الفاتورة",
                          hint: "اختر التاريخ",
                          readOnly: true,
                          controller: TextEditingController(
                            text: "${invoice.invoiceDate!.day}/${invoice.invoiceDate!.month}/${invoice.invoiceDate!.year}",
                          ),
                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: invoice.invoiceDate!,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => invoice.invoiceDate = picked);
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        ProductsTableWidget(
                          invoice: invoice,
                          onChanged: () => setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomButton(
                            text: "إضافة منتج",
                            onPressed: _addProduct,
                            icon: Icons.add,
                          ),
                        ),

                        const SizedBox(height: 24),

                        TotalsSectionWidget(
                          invoice: invoice,
                          discountController: discountController,
                          onChanged: () => setState(() {}),
                        ),

                        if (invoice.paymentType == 'آجل')
                          DeferredPaymentWidget(
                            invoice: invoice,
                            paidNowController: paidNowController,
                            interestRateController: interestRateController,
                            paidNow: invoice.paidNow,
                            interestRate: invoice.interestRate,
                            onPaidNowChanged: (v) => setState(() => invoice.paidNow = v),
                            onInterestRateChanged: (v) => setState(() => invoice.interestRate = v),
                          ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: "اغلاق",
                              icon: Icons.close,
                              isOutlined: true,
                              onPressed: () => Navigator.pop(context),
                            ),
                            CustomButton(
                              text: "حفظ",
                              onPressed: _saveInvoice,
                              icon: Icons.save,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}