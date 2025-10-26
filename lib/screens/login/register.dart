import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/auth/cubit.dart';
import 'package:management_stock/cubits/auth/states.dart';
import 'package:management_stock/screens/home/dashboard_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

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
                  ),
                ],
              ),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        size: Responsive.fontSize(context, 60),
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.fontSize(context, 22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ✅ البريد الإلكتروني
                      CustomInputField(
                        label: "البريد الإلكتروني",
                        hint: "أدخل البريد الإلكتروني",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon:
                            const Icon(Icons.email_outlined, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      // ✅ كلمة المرور
                      CustomInputField(
                        label: "كلمة المرور",
                        hint: "أدخل كلمة المرور",
                        controller: passwordController,
                        isPassword: true,
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      // ✅ تأكيد كلمة المرور
                      CustomInputField(
                        label: "تأكيد كلمة المرور",
                        hint: "أعد إدخال كلمة المرور",
                        controller: confirmPasswordController,
                        isPassword: true,
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),

                      CustomButton(
                        text: isLoading ? "جارٍ التسجيل..." : "إنشاء حساب",
                        icon: Icons.person_add,
                        backgroundColor: Colors.blueAccent,
                        textColor: Colors.white,
                        fullWidth: true,
                        onPressed: isLoading
                            ? null
                            : () {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();
                                final confirmPassword =
                                    confirmPasswordController.text.trim();

                                if (email.isEmpty ||
                                    password.isEmpty ||
                                    confirmPassword.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("من فضلك أكمل كل الحقول")),
                                  );
                                  return;
                                }

                                if (password != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("كلمتا المرور غير متطابقتين")),
                                  );
                                  return;
                                }

                                context
                                    .read<AuthCubit>()
                                    .register(email, password);
                              },
                      ),
                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // يرجع لشاشة تسجيل الدخول
                        },
                        child: const Text(
                          "لديك حساب بالفعل؟ تسجيل الدخول",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
