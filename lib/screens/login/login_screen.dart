import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/screens/home/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      body: Center(
        child: Padding(
          padding: padding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2F48),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: Responsive.fontSize(context, 60),
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ✅ حقل البريد الإلكتروني
                  CustomInputField(
                    label: "البريد الإلكتروني",
                    hint: "أدخل البريد الإلكتروني",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  // ✅ حقل كلمة المرور
                  CustomInputField(
                    label: "كلمة المرور",
                    hint: "أدخل كلمة المرور",
                    controller: passwordController,
                    isPassword: true,
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),

                  // ✅ زر تسجيل الدخول
                  CustomButton(
                    text: "تسجيل الدخول",
                    icon: Icons.login,
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
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
