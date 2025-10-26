import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:management_stock/core/routing/app_routers.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1E2030),
        appBarTheme: const AppBarTheme(color:  Color(0xFF2C2F48)),
      ),
      initialRoute: Routers.loginRoute,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
