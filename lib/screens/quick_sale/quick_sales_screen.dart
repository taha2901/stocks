import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/quick_sales/cubit.dart';
import 'package:management_stock/cubits/quick_sales/states.dart';
import 'package:management_stock/models/pos/pos_sales_model.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/pos/pos_cart_model.dart';
import 'package:management_stock/screens/quick_sale/empty_state.dart';
import 'package:management_stock/screens/quick_sale/inventory_print.dart';
import 'package:management_stock/screens/quick_sale/pos_action_buttons.dart';
import 'package:management_stock/screens/quick_sale/pos_bardcode_input.dart';
import 'package:management_stock/screens/quick_sale/pos_cart_table.dart';
import 'package:management_stock/screens/quick_sale/pos_cart_total.dart';
import 'package:management_stock/screens/quick_sale/pos_print.dart';
import 'package:management_stock/screens/quick_sale/sales_history_items.dart';
import 'package:management_stock/screens/quick_sale/sales_history_print.dart';
import 'package:management_stock/screens/report/widgets/inventory_table.dart';

class QuickSaleScreen extends StatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen> {
  final TextEditingController barcodeController = TextEditingController();
  int selectedTab = 0; // 0 = POS, 1 = Inventory, 2 = Sales History
  List<POSCartItem> cart = [];
    POSSaleModel? _savedSale;

  late final ProductCubit productCubit;
  late final POSSaleCubit posSaleCubit;

  @override
  void initState() {
    super.initState();
    productCubit = context.read<ProductCubit>();
    posSaleCubit = context.read<POSSaleCubit>();
  }
  void _completeSale() {
    if (cart.isEmpty) return;
    final sale = POSSaleModel(items: List.from(cart));
    _savedSale = sale; // 🔥 احفظ الفاتورة
    context.read<POSSaleCubit>().createSale(sale);
  }

  void _showPrintDialog() {
    if (_savedSale == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text('تم البيع بنجاح ✅', style: TextStyle(color: Colors.white)),
        content: const Text('هل تريد طباعة الفاتورة الآن؟', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لا، شكراً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => POSSalePrintWidget(sale: _savedSale!),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('نعم، اطبع'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<POSSaleCubit, POSSaleState>(
      listener: (context, state) {
        if (state is POSSaleSuccess) {
          setState(() => cart.clear());
          _showMessage(state.message, Colors.green);
          _showPrintDialog(); // 🔥 اسأل عن الطباعة
        } else if (state is POSSaleError) {
          _showMessage(state.error, Colors.red);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E2030),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("POS - نقطة البيع", style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      automaticallyImplyLeading: false,
    );
  }

  // ✅ Tab Bar
  Widget _buildTabBar() {
  return Container(
    color: const Color(0xFF2C2F48),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر طباعة حسب التاب المختار
        if (selectedTab == 1 || selectedTab == 2)
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: selectedTab == 1 ? _printInventory : _printSalesHistory,
          ),
        const Spacer(),
        _buildTabButton("سجل المبيعات 📋", 2),
        const SizedBox(width: 12),
        _buildTabButton("المخزون", 1),
        const SizedBox(width: 12),
        _buildTabButton("نقطة البيع", 0),
      ],
    ),
  );
}

void _printInventory() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => InventoryPrintWidget(products: productCubit.products),
    ),
  );
}

void _printSalesHistory() {
  final sales = (posSaleCubit.state is POSSaleLoaded)
      ? (posSaleCubit.state as POSSaleLoaded).sales
      : <POSSaleModel>[];

  if (sales.isEmpty) {
    _showMessage("لا توجد مبيعات للطباعة", Colors.orange);
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SalesHistoryPrintWidget(sales: sales),
    ),
  );
}

  Widget _buildTabButton(String label, int index) {
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

  // ✅ Tab Content
  Widget _buildTabContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return _wrappedContent(
          isDesktop: isDesktop,
          child: selectedTab == 0
              ? _buildPOSTab()
              : selectedTab == 1
                  ? InventoryTable(isDesktop: isDesktop, products: productCubit.products)
                  : _buildSalesHistoryTab(isDesktop: isDesktop),
        );
      },
    );
  }

  Widget _wrappedContent({required bool isDesktop, required Widget child}) {
    return SingleChildScrollView(
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
  }

  // ✅ POS Tab
  Widget _buildPOSTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        POSBarcodeInput(
          controller: barcodeController,
          onAdd: () => _addProductToCart(barcodeController.text),
        ),
        const SizedBox(height: 20),
        cart.isEmpty
            ? const EmptyState(
                icon: Icons.shopping_cart_outlined,
                message: "لم يتم إضافة أي منتجات بعد.",
              )
            : POSCartTable(
                cart: cart,
                onQuantityChanged: () => setState(() {}),
                onRemove: (item) => setState(() => cart.remove(item)),
              ),
        const SizedBox(height: 20),
        if (cart.isNotEmpty) POSCartTotal(total: _calculateTotal()),
        const SizedBox(height: 20),
        POSActionButtons(
          hasCart: cart.isNotEmpty,
          onBack: () => Navigator.pop(context),
          onCheckout: _completeSale,
        ),
      ],
    );
  }

  // ✅ Sales History Tab
  Widget _buildSalesHistoryTab({bool isDesktop = false}) {
    return BlocBuilder<POSSaleCubit, POSSaleState>(
      builder: (context, state) {
        if (state is POSSaleLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is POSSaleLoaded) {
          final sales = state.sales;
          if (sales.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long,
              message: "لم يتم تسجيل أي مبيعات بعد.",
            );
          }
          return Column(
            children: sales
                .map((sale) => SalesHistoryItem(sale: sale, isDesktop: isDesktop))
                .toList(),
          );
        }
        return const Center(child: Text("لا توجد مبيعات"));
      },
    );
  }

  // ✅ Helper Methods
  double _calculateTotal() => cart.fold(0, (sum, item) => sum + item.total);

  void _addProductToCart(String barcode) {
    if (barcode.isEmpty) {
      _showMessage("الرجاء إدخال باركود المنتج", Colors.orange);
      return;
    }

    final product = productCubit.products.firstWhere(
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

    if (product.id == '0') {
      _showMessage("المنتج غير موجود ❌", Colors.red);
      return;
    }

    if (product.quantity <= 0) {
      _showMessage("❌ المنتج غير متوفر في المخزون", Colors.red);
      return;
    }

    setState(() {
      final existingIndex = cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex == -1) {
        cart.add(POSCartItem(product: product));
        _showMessage("تم إضافة ${product.name} ✅", Colors.green);
      } else {
        if (cart[existingIndex].quantity >= product.quantity) {
          _showMessage("❌ الكمية المتاحة فقط: ${product.quantity}", Colors.orange);
          return;
        }
        cart[existingIndex].quantity++;
        _showMessage("تم تحديث الكمية ✅", Colors.green);
      }
    });

    barcodeController.clear();
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
