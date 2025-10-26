import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/pos_cart_model.dart';
import 'package:management_stock/models/sales_record.dart';

class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen> {
  final TextEditingController barcodeController = TextEditingController();
  int selectedTab = 0; // 0 = POS, 1 = Inventory, 2 = Sales History

  // 🔹 بيانات المنتجات والسلة وسجل المبيعات
  List<ProductModel> allProducts = dummyProducts;
  List<POSCartItem> cart = [];
  List<SaleRecord> salesHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "POS - نقطة البيع",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C2F48),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 🔹 Tabs
          Container(
            color: const Color(0xFF2C2F48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTab("سجل المبيعات 📋", 2),
                const SizedBox(width: 12),
                _buildTab("المخزون", 1),
                const SizedBox(width: 12),
                _buildTab("نقطة البيع", 0),
              ],
            ),
          ),
          // 🔹 محتوى التاب
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                Widget wrappedChild(Widget child) => SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1000 : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 16,
                          vertical: 16,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );

                if (selectedTab == 0) return wrappedChild(_buildPOSTab());
                if (selectedTab == 1) {
                  return wrappedChild(_buildInventoryTab(isDesktop: isDesktop));
                }
                return wrappedChild(
                  _buildSalesHistoryTab(isDesktop: isDesktop),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🧱 Tabs
  Widget _buildTab(String label, int index) {
    final isSelected = selectedTab == index;
    return CustomButton(
      text: label,
      textColor: isSelected ? Colors.white : Colors.white70,
      backgroundColor: isSelected ? Colors.blueAccent : Colors.transparent,
      fontSize: isSelected ? 16 : 14,
      borderColor: isSelected ? Colors.blueAccent : Colors.white30,
      onPressed: () => setState(() => selectedTab = index),
    );
  }

  // 🧱 نقطة البيع
  Widget _buildPOSTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // حقل الباركود باستخدام CustomInputField
        CustomInputField(
          controller: barcodeController,
          hint: "أدخل باركود المنتج 🔍",
          prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.white70),
          onChanged: (value) {
            // يمكن إضافة منطق البحث المباشر هنا
          },
          onTap: () {
            // التركيز على حقل الباركود
          },
        ),
        const SizedBox(height: 8),
        // زر البحث/الإضافة
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: "إضافة للسلة",
            icon: Icons.add_shopping_cart,
            onPressed: () {
              _addProductToCart(barcodeController.text);
              barcodeController.clear();
            },
          ),
        ),
        const SizedBox(height: 20),
        // عرض السلة أو رسالة فارغة
        cart.isEmpty
            ? Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF353855),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white38,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "لم يتم إضافة أي منتجات بعد.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            : _buildCartTable(),
        const SizedBox(height: 20),

        // عرض الإجمالي إذا كانت السلة غير فارغة
        if (cart.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF353855),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "الإجمالي الكلي:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_calculateTotal().toStringAsFixed(2)} ج.م",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // اختصارات لوحة المفاتيح
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF353855),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "اختصارات: F1 = تركيز على الباركود | F2 = حفظ الفاتورة | Delete = حذف كل المنتجات",
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 8),
              Icon(Icons.keyboard, color: Colors.white70, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "عودة",
                icon: Icons.arrow_forward,
                backgroundColor: Colors.blueAccent,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            if (cart.isNotEmpty)
              Expanded(
                child: CustomButton(
                  text: "إتمام البيع",
                  icon: Icons.check_circle,
                  backgroundColor: Colors.green,
                  fullWidth: true,
                  onPressed: _completeSale,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: "تسجيل خروج",
                icon: Icons.exit_to_app,
                backgroundColor: const Color(0xFFE57373),
                fullWidth: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم تسجيل الخروج 🚪"),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🧱 جدول السلة
  Widget _buildCartTable() {
    return Table(
      border: TableBorder.all(color: Colors.white24),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFF353855)),
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "المنتج",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "الكمية",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "سعر الوحدة",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "الإجمالي",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "حذف",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        ...cart.map(
          (item) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  item.product.name,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          if (item.quantity > 1) {
                            item.quantity--;
                          }
                        });
                      },
                    ),
                    Text(
                      "${item.quantity}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          item.quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "${item.total.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      cart.remove(item);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🧱 حساب الإجمالي
  double _calculateTotal() {
    return cart.fold(0, (sum, item) => sum + item.total);
  }

  // 🧱 إتمام عملية البيع
  void _completeSale() {
    if (cart.isEmpty) return;

    setState(() {
      salesHistory.add(
        SaleRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          dateTime: DateTime.now(),
          items: List.from(cart),
          // : _calculateTotal(),
        ),
      );
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم إتمام عملية البيع بنجاح! ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 🧱 إضافة المنتج للسلة
  void _addProductToCart(String barcode) {
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء إدخال باركود المنتج"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final product = allProducts.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => ProductModel(
        id: '0',
        name: 'غير موجود',
        category: '',
        image: '',
        purchasePrice: 0,
        sellPrice: 0,
        pointPrice: 0,
        quantity: 0,
        barcode: barcode,
      ),
    );

    if (product.id != '0') {
      setState(() {
        final existingIndex = cart.indexWhere(
          (item) => item.product.id == product.id,
        );

        if (existingIndex == -1) {
          cart.add(POSCartItem(product: product));
        } else {
          cart[existingIndex].quantity += 1;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم إضافة ${product.name} للسلة ✅"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("المنتج غير موجود ❌"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🧱 تاب المخزون
  Widget _buildInventoryTab({bool isDesktop = false}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: isDesktop ? 800 : 400),
        child: Table(
          border: TableBorder.all(color: Colors.white24),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(2),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFF353855)),
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "المنتج",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "الباركود",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "الكمية",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "سعر البيع",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            ...allProducts.map((product) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      product.name,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      product.barcode,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "${product.quantity}",
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "${product.sellPrice.toStringAsFixed(2)} ج.م",
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // 🧱 تاب سجل المبيعات
  Widget _buildSalesHistoryTab({bool isDesktop = false}) {
    if (salesHistory.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF353855),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, color: Colors.white38, size: 64),
              SizedBox(height: 16),
              Text(
                "لم يتم تسجيل أي مبيعات بعد.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: salesHistory.map((sale) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF353855),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "الإجمالي: ${sale.total.toStringAsFixed(2)} ج.م",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${sale.dateTime.day}/${sale.dateTime.month}/${sale.dateTime.year} - ${sale.dateTime.hour}:${sale.dateTime.minute}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: isDesktop ? 800 : 400),
                  child: Table(
                    border: TableBorder.all(color: Colors.white24),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFF42455E)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "المنتج",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "الكمية",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "سعر الوحدة",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "الإجمالي",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      ...sale.items.map<TableRow>((item) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.product.name,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${item.quantity}",
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.total.toStringAsFixed(2),
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
