import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/routing/app_routers.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/services/auth_service.dart';
import 'package:management_stock/core/services/Customer_services.dart';
import 'package:management_stock/core/services/deffered_account_services.dart';
import 'package:management_stock/core/services/pos_sales_services.dart';
import 'package:management_stock/core/services/product_service.dart';
import 'package:management_stock/core/services/purchase_invoice_service.dart';
import 'package:management_stock/core/services/report_Services.dart';
import 'package:management_stock/core/services/sales_invoice_services.dart';
import 'package:management_stock/core/services/supplier_services.dart';
import 'package:management_stock/cubits/auth/cubit.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/deffered/cubit.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/purchase/cubit.dart';
import 'package:management_stock/cubits/quick_sales/cubit.dart';
import 'package:management_stock/cubits/report/cubit.dart';
import 'package:management_stock/cubits/sales/cubit.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(AuthServicesImpl())..checkAuthState(),
        ),
        BlocProvider(
          create: (_) => ProductCubit(ProductServicesImpl())..fetchProducts(),
        ),
        BlocProvider(
          create: (_) => PurchaseInvoiceCubit(PurchaseInvoiceServicesImpl()),
        ),
        BlocProvider(
          create: (_) =>
              SupplierCubit(SupplierServicesImpl())..fetchSuppliers(),
        ),
        BlocProvider(
          create: (_) => CustomerCubit(CustomerServicesImpl())
            ..fetchCustomers()
            ..listenToCustomers(),
        ),
        BlocProvider(
          create: (_) => SalesInvoiceCubit(SalesInvoiceServicesImpl()),
        ),
        BlocProvider(
          create: (_) => POSSaleCubit(POSSaleServicesImpl())..fetchSales(),
        ),
        BlocProvider(
          create: (_) => DeferredAccountCubit(DeferredAccountServicesImpl()),
        ),
        BlocProvider(create: (context) => ReportsCubit(ReportsServicesImpl())),
      ],
      child: MyApp(appRouter: AppRouter()),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Management Stock',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1E2030),
        appBarTheme: const AppBarTheme(color: Color(0xFF2C2F48)),
      ),
      initialRoute: Routers.loginRoute,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
