import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snackify/snackify.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Refactored Sign Up Form

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: aaliyahFormHeight - 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text(aaliyahFirstName),
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                  controller: _firstNameController,
                ),
                const SizedBox(height: aaliyahFormHeight - 20),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text(aaliyahLastName),
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                  controller: _lastNameController,
                ),
                const SizedBox(height: aaliyahFormHeight - 20),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text(aaliyahUsername),
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                    border: OutlineInputBorder(),
                  ),
                  controller: _usernameController,
                ),
                const SizedBox(height: aaliyahFormHeight - 20),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text(aaliyahEmail),
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  controller: _emailController,
                ),
                const SizedBox(height: aaliyahFormHeight - 20),
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text(aaliyahPassword),
                    prefixIcon: const Icon(Icons.password_outlined),
                    border: const OutlineInputBorder(),
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
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text(aaliyahConfirmPassword),
                    prefixIcon: const Icon(Icons.password_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.remove_red_eye_sharp
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                ),
                const SizedBox(height: aaliyahFormHeight - 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (_firstNameController.text.isEmpty ||
                                _lastNameController.text.isEmpty ||
                                _usernameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              Snackify.show(
                                context: context,
                                type: SnackType.error,
                                title: const Text("Form Error"),
                                subtitle: const Text("Please fill all fields"),
                              );
                              return;
                            }

                            if (_passwordController.text != _confirmPasswordController.text) {
                              Snackify.show(
                                context: context,
                                type: SnackType.error,
                                title: const Text("Password Mismatch"),
                                subtitle: const Text("Passwords do not match"),
                              );
                              return;
                            }

                            final response = await authProvider.register(
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              username: _usernameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              passwordConfirmation: _confirmPasswordController.text,
                            );

                            if (!mounted) return;

                            if (response.statusCode == 201) {
                              Snackify.show(
                                context: context,
                                type: SnackType.success,
                                title: const Text("Success"),
                                subtitle: const Text("Account created successfully!"),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            } else {
                              Snackify.show(
                                context: context,
                                type: SnackType.error,
                                title: const Text("Registration Error"),
                                subtitle: const Text("Registration failed. Try again."),
                              );
                            }
                          },
                    child: authProvider.isLoading
                        ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 30)
                        : Text(aaliyahSignup.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
