import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/customer.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/sales_invoice_item.dart';
import 'package:management_stock/models/sales_invoice_model.dart';
import 'package:management_stock/screens/sales/widgets/deffered_payment_widget.dart';
import 'package:management_stock/screens/sales/widgets/product_table_widget.dart';
import 'package:management_stock/screens/sales/widgets/total_section_widget.dart';

class SalesInvoiceScreen extends StatefulWidget {
  const SalesInvoiceScreen({super.key});

  @override
  State<SalesInvoiceScreen> createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  SalesInvoiceModel invoice = SalesInvoiceModel();

  // متغيرات الدفع الآجل
  final TextEditingController paidNowController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  double paidNow = 0;
  double interestRate = 0;

  final List<String> paymentMethods = ['كاش', 'آجل'];

  // 🔹 إضافة منتج جديد للفاتورة
  void _addProduct() {
    setState(() {
      invoice.items.add(SalesInvoiceItem(product: dummyProducts.first));
    });
  }

  double get totalAfterInterest =>
      invoice.totalAfterDiscount +
      (invoice.totalAfterDiscount * interestRate / 100);

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2C2F48),
        elevation: 4,
        title: Text(
          "فاتورة بيع جديدة 🧾",
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  CustomInputField(
                    label: "العميل",
                    hint: "اختر العميل",
                    items: dummyCustomers.map((c) => c.name).toList(),
                    selectedValue: invoice.supplier,
                    onItemSelected: (value) =>
                        setState(() => invoice.supplier = value),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
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
                    prefixIcon: const Icon(
                      Icons.payment,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // تاريخ الفاتورة
                  CustomInputField(
                    label: "تاريخ الفاتورة",
                    hint: "اختر التاريخ",
                    readOnly: true,
                    controller: TextEditingController(
                      text: invoice.invoiceDate == null
                          ? ''
                          : "${invoice.invoiceDate!.day}/${invoice.invoiceDate!.month}/${invoice.invoiceDate!.year}",
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: invoice.invoiceDate ?? now,
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

                  // قسم الدفع الآجل
                  if (invoice.paymentType == 'آجل')
                    DeferredPaymentWidget(
                      invoice: invoice,
                      paidNowController: paidNowController,
                      interestRateController: interestRateController,
                      paidNow: paidNow,
                      interestRate: interestRate,
                      onPaidNowChanged: (v) => setState(() => paidNow = v),
                      onInterestRateChanged: (v) =>
                          setState(() => interestRate = v),
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
                        onPressed: () {},
                        icon: Icons.save,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
