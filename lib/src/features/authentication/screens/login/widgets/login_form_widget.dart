import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/forget_password/forget_password_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/two_factor/two_factor_screen.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snackify/snackify.dart';
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
                    prefixIcon: Icon(Icons.person_outline),
                    labelText: aaliyahLoginLabel,
                    hintText: aaliyahLoginLabel,
                    border: OutlineInputBorder(),
                  ),
                  controller: _emailController,
                ),
                const SizedBox(height: aaliyahFormHeight),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password_outlined),
                    labelText: aaliyahPassword,
                    hintText: aaliyahPassword,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.remove_red_eye_sharp
                            : Icons.visibility_off_outlined,
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
                    style: TextButton.styleFrom(foregroundColor: aaliyahPrimaryColor),
                    child: Text(aaliyahForgetPassword),
                  ),
                ),
                const SizedBox(height: aaliyahFormHeight - 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                              Snackify.show(
                                context: context,
                                type: SnackType.error,
                                title: const Text("Error"),
                                subtitle: const Text("Please enter your login details"),
                              );
                              return;
                            }

                            final result = await authProvider.login(
                              _emailController.text,
                              _passwordController.text,
                            );

                            if (!mounted) return;

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
                              Snackify.show(
                                context: context,
                                type: SnackType.error,
                                title: const Text("Login Failed"),
                                subtitle: Text(result['message'] ?? "Invalid credentials"),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
