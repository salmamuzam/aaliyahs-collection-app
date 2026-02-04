import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:aaliyahs_collection_estore/util/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/login/widgets/auth_text_field.dart';
import 'package:aaliyahs_collection_estore/controllers/auth_controller.dart';

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

  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPasswordNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePasswordNotifier.dispose();
    _obscureConfirmPasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: TUIConstants.relativeHeight(context, 0.02)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameRow(),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            AuthTextField(
              controller: _usernameController,
              label: aaliyahUsername,
              prefixIcon: Icons.alternate_email_rounded,
            ),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            AuthTextField(
              controller: _emailController,
              label: aaliyahEmail,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            _buildPasswordField(),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            _buildConfirmPasswordField(),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.03)),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Expanded(
          child: AuthTextField(
            controller: _firstNameController,
            label: aaliyahFirstName,
            prefixIcon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: AuthTextField(
            controller: _lastNameController,
            label: aaliyahLastName,
            prefixIcon: Icons.person_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePasswordNotifier,
      builder: (context, obscure, child) {
        return AuthTextField(
          controller: _passwordController,
          label: aaliyahPassword,
          prefixIcon: Icons.password_outlined,
          obscureText: obscure,
          suffixIcon: IconButton(
            onPressed: () => _obscurePasswordNotifier.value = !obscure,
            icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          ),
        );
      }
    );
  }

  Widget _buildConfirmPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscureConfirmPasswordNotifier,
      builder: (context, obscure, child) {
        return AuthTextField(
          controller: _confirmPasswordController,
          label: aaliyahConfirmPassword,
          prefixIcon: Icons.password_outlined,
          obscureText: obscure,
          suffixIcon: IconButton(
            onPressed: () => _obscureConfirmPasswordNotifier.value = !obscure,
            icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          ),
        );
      }
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return ElevatedButton(
            onPressed: () => _handleSignUp(),
            child: authController.isLoading
                ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 30)
                : Text(aaliyahSignup.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          );
        }
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final authController = context.read<AuthController>();
    if (authController.isLoading) return;

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showToast(aaliyahSignUpEmptyTitle, aaliyahSignUpEmptySubTitle, ToastificationType.error);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showToast(aaliyahPasswordMismatchTitle, aaliyahPasswordMismatchSubTitle, ToastificationType.error);
      return;
    }

    final result = await authController.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (result['status'] == 'success') {
      _showToast(aaliyahRegistrationSuccessTitle, aaliyahRegistrationSuccessSubTitle, ToastificationType.success);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      _showToast(aaliyahRegistrationFailedTitle, result['message'] ?? aaliyahRegistrationFailedSubTitle, ToastificationType.error);
    }
  }

  void _showToast(String title, String message, ToastificationType type) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
