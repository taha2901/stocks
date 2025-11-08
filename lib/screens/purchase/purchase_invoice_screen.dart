import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/purchase/cubit.dart';
import 'package:management_stock/cubits/purchase/states.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/purchase/purchase_invoice_item.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_header_widget.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_print.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_product_table.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_total_section.dart';

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  String? selectedSupplier;
  String? selectedSupplierId;
  DateTime? invoiceDate;
  PurchaseInvoiceModel? _savedInvoice;

  final TextEditingController discountController = TextEditingController();
  double discount = 0;

  List<PurchaseInvoiceItem> invoiceItems = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
    context.read<SupplierCubit>().fetchSuppliers();
  }

  void _addProduct(ProductModel product) {
    setState(() {
      final existingIndex = invoiceItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex != -1) {
        invoiceItems[existingIndex].quantity++;
      } else {
        invoiceItems.add(PurchaseInvoiceItem(product: product));
      }
    });
  }

  double get totalBeforeDiscount =>
      invoiceItems.fold(0, (sum, item) => sum + item.subtotal);

  double get totalAfterDiscount => totalBeforeDiscount - discount;

  void _saveInvoice() {
    if (selectedSupplier == null || selectedSupplierId == null) {
      _showError("يرجى اختيار المورد");
      return;
    }

    if (invoiceDate == null) {
      _showError("يرجى اختيار تاريخ الفاتورة");
      return;
    }

    if (invoiceItems.isEmpty) {
      _showError("يرجى إضافة منتجات للفاتورة");
      return;
    }

    final invoice = PurchaseInvoiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supplierId: selectedSupplierId!,
      supplierName: selectedSupplier!,
      invoiceDate: invoiceDate!,
      totalBeforeDiscount: totalBeforeDiscount,
      discount: discount,
      items: invoiceItems,
      createdAt: DateTime.now(),
    );

    context.read<PurchaseInvoiceCubit>().createInvoice(invoice);

    // 🔥 احتفظ بالفاتورة لإظهارها بعد الحفظ
    _savedInvoice = invoice;
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
              Navigator.pop(ctx); // أغلق الدياlog
              Navigator.pop(context); // ارجع للصفحة السابقة
            },
            child: const Text('لا، شكراً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // أغلق الـ dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PurchaseInvoicePrintWidget(invoice: _savedInvoice!),
                ),
              ).then((_) => Navigator.pop(context)); // بعد الطباعة ارجع
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('نعم، اطبع'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<PurchaseInvoiceCubit, PurchaseInvoiceState>(
        listener: (context, state) {
          if (state is PurchaseInvoiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ProductCubit>().fetchProducts();

            // 🔥 اسأل المستخدم: هل يريد الطباعة؟
            _showPrintDialog();
          } else if (state is PurchaseInvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        builder: (context, state) {
          final isLoading = state is PurchaseInvoiceLoading;

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
                      PurchaseHeaderWidget(
                        selectedSupplier: selectedSupplier,
                        selectedSupplierId: selectedSupplierId,
                        invoiceDate: invoiceDate,
                        onSupplierChanged: (value) {
                          setState(() => selectedSupplier = value);
                        },
                        onSupplierIdChanged: (value) {
                          setState(() => selectedSupplierId = value);
                        },
                        onDateChanged: (value) =>
                            setState(() => invoiceDate = value),
                      ),
                      const SizedBox(height: 24),
                      PurchaseProductsTable(
                        invoiceItems: invoiceItems,
                        onAddProduct: () => _showAddProductDialog(context),
                        onRemove: (index) =>
                            setState(() => invoiceItems.removeAt(index)),
                        onQuantityChanged: (index, newQty) => setState(
                          () => invoiceItems[index].quantity = newQty,
                        ),
                        onBuyPriceChanged: (index, newPrice) => setState(
                          () => invoiceItems[index].buyPrice = newPrice,
                        ),
                        onSellPriceChanged: (index, newPrice) => setState(
                          () => invoiceItems[index].sellPrice = newPrice,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PurchaseTotalsSection(
                        discountController: discountController,
                        totalBeforeDiscount: totalBeforeDiscount,
                        totalAfterDiscount: totalAfterDiscount,
                        onDiscountChanged: (val) => setState(
                          () => discount = double.tryParse(val) ?? 0,
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
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                          ),
                          CustomButton(
                            text: isLoading ? "جاري الحفظ..." : "حفظ",
                            icon: isLoading ? null : Icons.save,
                            onPressed: isLoading ? null : _saveInvoice,
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
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final products = context.read<ProductCubit>().products;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2F48),
          title: const Text("اختر منتج", style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      "لا توجد منتجات",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        // leading: ClipRRect(
                        //   borderRadius: BorderRadius.circular(8),
                        //   child: Image.network(
                        //     product.image,
                        //     width: 50,
                        //     height: 50,
                        //     fit: BoxFit.cover,
                        //     errorBuilder: (context, error, stackTrace) {
                        //       return Container(
                        //         width: 50,
                        //         height: 50,
                        //         color: Colors.grey[700],
                        //         child: const Icon(
                        //           Icons.image_not_supported,
                        //           color: Colors.white54,
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        title: Text(
                          product.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "سعر الشراء: ${product.purchasePrice} ج.م",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          "الكمية: ${product.quantity}",
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                        onTap: () {
                          _addProduct(product);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    discountController.dispose();
    super.dispose();
  }
}