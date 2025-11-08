import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/sales/cubit.dart';
import 'package:management_stock/cubits/sales/states.dart';
import 'package:management_stock/models/sales/sales_invoice_item.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';
import 'package:management_stock/screens/sales/widgets/customer_and_payment_section.dart';
import 'package:management_stock/screens/sales/widgets/deffered_payment_widget.dart';
import 'package:management_stock/screens/sales/widgets/invoice_date_field.dart';
import 'package:management_stock/screens/sales/widgets/product_table_widget.dart';
import 'package:management_stock/screens/sales/widgets/sales_print.dart';
import 'package:management_stock/screens/sales/widgets/total_section_widget.dart';


class SalesInvoiceScreen extends StatefulWidget {
  final SalesInvoiceModel invoice;

  const SalesInvoiceScreen({super.key, required this.invoice});

  @override
  State<SalesInvoiceScreen> createState() => SalesInvoiceScreenState();
}

class SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  final TextEditingController paidNowController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  final List<String> paymentMethods = const ['كاش', 'آجل'];
  SalesInvoiceModel? _savedInvoice; // 🔥 احتفظ بالفاتورة المحفوظة

  @override
  void initState() {
    super.initState();
    widget.invoice.invoiceDate ??= DateTime.now();
  }

  @override
  void dispose() {
    paidNowController.dispose();
    interestRateController.dispose();
    discountController.dispose();
    super.dispose();
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
      widget.invoice.items.add(
        SalesInvoiceItem(product: productCubit.products.first),
      );
    });
  }

  Future<void> _saveInvoice() async {
    if (widget.invoice.customerId == null) {
      _showError("يرجى اختيار عميل");
      return;
    }
    if (widget.invoice.items.isEmpty) {
      _showError("يرجى إضافة منتج واحد على الأقل");
      return;
    }
    if (widget.invoice.paymentType == null) {
      _showError("يرجى اختيار نوع الدفع");
      return;
    }

    widget.invoice.paidNow = double.tryParse(paidNowController.text) ?? 0;
    widget.invoice.interestRate = double.tryParse(interestRateController.text) ?? 0;

    _savedInvoice = widget.invoice; // 🔥 احفظ الفاتورة قبل الإرسال
    await context.read<SalesInvoiceCubit>().createInvoice(widget.invoice);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showPrintDialog() {
    if (_savedInvoice == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text(
          'تم حفظ الفاتورة بنجاح ✅',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل تريد طباعة الفاتورة الآن؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('لا، شكراً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SalesInvoicePrintWidget(invoice: _savedInvoice!),
                ),
              ).then((_) => Navigator.pop(context));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('نعم، اطبع'),
          ),
        ],
      ),
    );
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
          context.read<ProductCubit>().fetchProducts();
          _showPrintDialog(); // 🔥 اسأل عن الطباعة
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

            final products = context.read<ProductCubit>().products;

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
                        CustomerAndPaymentSection(
                          invoice: widget.invoice,
                          paymentMethods: paymentMethods,
                          onCustomerSelected: (id, name) {
                            setState(() {
                              widget.invoice.customerId = id;
                              widget.invoice.customerName = name;
                            });
                          },
                          onPaymentTypeSelected: (type) =>
                              setState(() => widget.invoice.paymentType = type),
                        ),
                        const SizedBox(height: 16),
                        InvoiceDateField(
                          date: widget.invoice.invoiceDate!,
                          onPick: (picked) =>
                              setState(() => widget.invoice.invoiceDate = picked),
                        ),
                        const SizedBox(height: 24),
                        ProductsTableWidget(
                          invoice: widget.invoice,
                          products: products,
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
                          totalBeforeDiscount: widget.invoice.totalBeforeDiscount,
                          totalAfterDiscount: widget.invoice.totalAfterDiscount,
                          discountController: discountController,
                          onDiscountChanged: (d) =>
                              setState(() => widget.invoice.discount = d),
                        ),
                        if (widget.invoice.paymentType == 'آجل') ...[
                          const SizedBox(height: 16),
                          DeferredPaymentWidget(
                            baseTotalAfterDiscount: widget.invoice.totalAfterDiscount,
                            paidNowController: paidNowController,
                            interestRateController: interestRateController,
                            paidNow: widget.invoice.paidNow,
                            interestRate: widget.invoice.interestRate,
                            onPaidNowChanged: (v) =>
                                setState(() => widget.invoice.paidNow = v),
                            onInterestRateChanged: (v) =>
                                setState(() => widget.invoice.interestRate = v),
                          ),
                        ],
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