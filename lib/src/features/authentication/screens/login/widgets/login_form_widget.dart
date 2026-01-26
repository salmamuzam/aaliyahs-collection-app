import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/forget_password/forget_password_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/two_factor/two_factor_screen.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Refactored Login Form

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: aaliyahFormHeight - 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE5EDEF) : null),
                    labelText: aaliyahLoginLabel,
                    hintText: aaliyahLoginLabel,
                    border: const OutlineInputBorder(),
                    focusedBorder: Theme.of(context).brightness == Brightness.dark
                        ? const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5EDEF), width: 2.0))
                        : null,
                  ),
                  controller: _emailController,
                ),
                const SizedBox(height: aaliyahFormHeight),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password_outlined, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE5EDEF) : null),
                    labelText: aaliyahPassword,
                    hintText: aaliyahPassword,
                    border: const OutlineInputBorder(),
                    focusedBorder: Theme.of(context).brightness == Brightness.dark
                        ? const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5EDEF), width: 2.0))
                        : null,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE5EDEF) : null,
                      ),
                    ),
                  ),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: aaliyahFormHeight - 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFE5EDEF)
                          : aaliyahPrimaryColor,
                    ),
                    child: Text(aaliyahForgetPassword),
                  ),
                ),
                const SizedBox(height: aaliyahFormHeight - 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (authProvider.isLoading) return;
                      
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          style: ToastificationStyle.fillColored,
                          title: const Text(aaliyahEmptyFieldTitle),
                          description: const Text(aaliyahEmptyFieldSubTitle),
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                        return;
                      }

                      final result = await authProvider.login(
                        _emailController.text,
                        _passwordController.text,
                      );

                      if (!context.mounted) return;

                      if (result['status'] == 'success') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BottomNavBar(),
                          ),
                        );
                      } else if (result['status'] == '2fa_required') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TwoFactorScreen(
                              login: _emailController.text,
                              password: _passwordController.text,
                            ),
                          ),
                        );
                      } else {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          style: ToastificationStyle.fillColored,
                          title: const Text(aaliyahInvalidCredTitle),
                          description: const Text(aaliyahInvalidCredSubTitle),
                          autoCloseDuration: const Duration(seconds: 4),
                        );
                      }
                    },
                    child: authProvider.isLoading
                        ? LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white,
                            size: 30,
                          )
                        : Text(
                            aaliyahLogin.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
