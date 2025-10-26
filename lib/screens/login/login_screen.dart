import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/auth/cubit.dart';
import 'package:management_stock/cubits/auth/states.dart';
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

                      CustomInputField(
                        label: "البريد الإلكتروني",
                        hint: "أدخل البريد الإلكتروني",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      CustomInputField(
                        label: "كلمة المرور",
                        hint: "أدخل كلمة المرور",
                        controller: passwordController,
                        isPassword: true,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),

                      CustomButton(
                        text: isLoading ? "جاري تسجيل الدخول..." : "تسجيل الدخول",
                        icon: Icons.login,
                        backgroundColor: Colors.blueAccent,
                        textColor: Colors.white,
                        fullWidth: true,
                        onPressed: isLoading
                            ? null
                            : () {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("من فضلك أدخل البريد وكلمة المرور")),
                                  );
                                  return;
                                }

                                context.read<AuthCubit>().login(email, password);
                              },
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
