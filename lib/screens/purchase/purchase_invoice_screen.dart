import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/purchase_invoice_item.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_deffered_payment_section.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_product_table.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_total_section.dart';

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  String? selectedSupplier;
  String? paymentType;
  DateTime? invoiceDate;
  final TextEditingController discountController = TextEditingController();
  double discount = 0;

  // متغيرات الدفع الآجل
  final TextEditingController paidNowController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  double paidNow = 0;
  double interestRate = 0;
  double remaining = 0;

  List<PurchaseInvoiceItem> invoiceItems = [];

  final List<String> paymentMethods = ['كاش', 'آجل'];

  void _addProduct(ProductModel product) {
    setState(() {
      invoiceItems.add(PurchaseInvoiceItem(product: product));
    });
  }

  double get totalBeforeDiscount =>
      invoiceItems.fold(0, (sum, item) => sum + item.subtotal);

  double get totalAfterDiscount => totalBeforeDiscount - discount;

  double get totalAfterInterest =>
      totalAfterDiscount + (totalAfterDiscount * interestRate / 100);

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        elevation: 4,
        automaticallyImplyLeading: false,
        title: Text(
          "فاتورة شراء جديدة 🧾",
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
                  // اختيار المورد
                  CustomInputField(
                    label: "المورد",
                    hint: "اختر المورد",
                    items: dummySuppliers.map((s) => s.name).toList(),
                    selectedValue: selectedSupplier,
                    onItemSelected: (value) =>
                        setState(() => selectedSupplier = value),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  ),

                  const SizedBox(height: 16),

                  // نوع الدفع
                  CustomInputField(
                    label: "نوع الدفع",
                    hint: "اختر نوع الدفع",
                    items: paymentMethods,
                    selectedValue: paymentType,
                    onItemSelected: (value) =>
                        setState(() => paymentType = value),
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
                      text: invoiceDate == null
                          ? ''
                          : "${invoiceDate!.day}/${invoiceDate!.month}/${invoiceDate!.year}",
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: invoiceDate ?? now,
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
                      if (picked != null) setState(() => invoiceDate = picked);
                    },
                  ),

                  const SizedBox(height: 24),

                  PurchaseProductsTable(
                    invoiceItems: invoiceItems,
                    onAddProduct: () => _showAddProductDialog(context),
                    onRemove: (index) =>
                        setState(() => invoiceItems.removeAt(index)),
                    onQuantityChanged: (index, newQty) =>
                        setState(() => invoiceItems[index].quantity = newQty),
                    onBuyPriceChanged: (index, newPrice) =>
                        setState(() => invoiceItems[index].buyPrice = newPrice),
                    onSellPriceChanged: (index, newPrice) => setState(
                      () => invoiceItems[index].sellPrice = newPrice,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 24),
                  PurchaseTotalsSection(
                    discountController: discountController,
                    totalBeforeDiscount: totalBeforeDiscount,
                    totalAfterDiscount: totalAfterDiscount,
                    onDiscountChanged: (val) =>
                        setState(() => discount = double.tryParse(val) ?? 0),
                  ),

                  // قسم الدفع الآجل
                  if (paymentType == 'آجل')
                    PurchaseDeferredPaymentSection(
                      paidNowController: paidNowController,
                      interestRateController: interestRateController,
                      totalAfterInterest: totalAfterInterest,
                      paidNow: paidNow,
                      onPaidNowChanged: (val) =>
                          setState(() => paidNow = double.tryParse(val) ?? 0),
                      onInterestChanged: (val) => setState(
                        () => interestRate = double.tryParse(val) ?? 0,
                      ),
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
                        icon: Icons.save,
                        onPressed: () {},
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

  // 🔹 Dialog لإضافة منتج
  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("اختر منتج"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: dummyProducts.map((product) {
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text("سعر الشراء: ${product.purchasePrice}"),
                  onTap: () {
                    _addProduct(product);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
