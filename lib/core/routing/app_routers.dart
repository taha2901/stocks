import 'package:flutter/material.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/models/customer.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';
import 'package:management_stock/screens/customers/add_new_customer.dart';
import 'package:management_stock/screens/customers/customers_screen.dart';
import 'package:management_stock/screens/customers/edit_customer_screen.dart';
import 'package:management_stock/screens/deffered/deffered_payments.dart';
import 'package:management_stock/screens/home/dashboard_screen.dart';
import 'package:management_stock/screens/login/login_screen.dart';
import 'package:management_stock/screens/login/register.dart';
import 'package:management_stock/screens/products/add_product_page.dart';
import 'package:management_stock/screens/products/products_screen.dart';
import 'package:management_stock/screens/purchase/purchase_invoice_screen.dart';
import 'package:management_stock/screens/quick_sale/quick_sales_screen.dart';
import 'package:management_stock/screens/report/report_screen.dart';
import 'package:management_stock/screens/sales/sales_invoice_screen.dart';
import 'package:management_stock/screens/suppliers/suppliers_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routers.loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case Routers.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case Routers.homeRoute:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case Routers.addCustomerRoute:
        return MaterialPageRoute(
          builder: (_) => const AddCustomerScreen(),
          settings: settings,
        );
      case Routers.editCustomerRoute:
        final customer = settings.arguments as Customer;
        return MaterialPageRoute(
          builder: (_) => EditCustomerScreen(customer: customer),
        );

      case Routers.productRoute:
        return MaterialPageRoute(
          builder: (_) => const ProductsScreen(),
          settings: settings,
        );
      case Routers.addProductRoute:
        return MaterialPageRoute(
          builder: (_) => const AddProductScreen(),
          settings: settings,
        );
      case Routers.customersRoute:
        return MaterialPageRoute(
          builder: (_) => const CustomersScreen(),
          settings: settings,
        );
      case Routers.suppliersRoute:
        return MaterialPageRoute(
          builder: (_) => const SuppliersPage(),
          settings: settings,
        );
      case Routers.purchaseInvoiceRoute:
        return MaterialPageRoute(
          builder: (_) => const PurchaseInvoiceScreen(),
          settings: settings,
        );
      case Routers.salesInvoiceRoute:
        final invoice =
            settings.arguments as SalesInvoiceModel? ?? SalesInvoiceModel();
        return MaterialPageRoute(
          builder: (_) => SalesInvoiceScreen(invoice: invoice),
          settings: settings,
        );
      case Routers.quickSaleRoute:
        return MaterialPageRoute(
          builder: (_) => const QuickSaleScreen(),
          settings: settings,
        );
      case Routers.deferredAccountsRoute:
        return MaterialPageRoute(
          builder: (_) => const DeferredAccountsScreen(),
          settings: settings,
        );
      case Routers.reportRoute:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error Page')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
