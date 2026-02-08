import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';

import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/routes/app_routes.dart';
import 'package:aaliyahs_collection_estore/common/widgets/form/auth_text_field.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNameRow(),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            AuthTextField(
              controller: _usernameController,
              label: aaliyahUsername,
              prefixIcon: Icons.alternate_email_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your username!';
                return null;
              },
            ),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            AuthTextField(
              controller: _emailController,
              label: aaliyahEmail,
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email!';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) return aaliyahInvalidEmailSubTitle;
                return null;
              },
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
    return Column(
      children: [
        AuthTextField(
          controller: _firstNameController,
          label: aaliyahFirstName,
          prefixIcon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your first name!';
            if (value.length < 3) return aaliyahNameTooShortSubTitle;
            return null;
          },
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: _lastNameController,
          label: aaliyahLastName,
          prefixIcon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your last name!';
            if (value.length < 3) return aaliyahNameTooShortSubTitle;
            return null;
          },
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
          prefixIcon: Icons.lock_rounded,
          obscureText: obscure,
          suffixIcon: IconButton(
            onPressed: () => _obscurePasswordNotifier.value = !obscure,
            icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your password!';
            if (value.length < 8) return aaliyahPasswordTooShortSubTitle;
            if (!value.contains(RegExp(r'[0-9]'))) return aaliyahPasswordNoNumberSubTitle;
            if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return aaliyahPasswordNoSpecialSubTitle;
            return null;
          },
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
          prefixIcon: Icons.lock_rounded,
          obscureText: obscure,
          suffixIcon: IconButton(
            onPressed: () => _obscureConfirmPasswordNotifier.value = !obscure,
            icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
          ),
          validator: (value) {
            if (value != _passwordController.text) return aaliyahPasswordMismatchSubTitle2;
            return null;
          },
        );
      }
    );
  }


  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _handleSignUp();
            },
            child: authController.isLoading
                ? ExpressiveCircularProgressIndicator(
                    strokeWidth: 3, 
                    size: 24,
                    isWavy: true, 
                    showTrack: false,
                    color: Theme.of(context).colorScheme.onPrimary,
                    semanticLabel: 'Creating your new account',
                  )
                : const Text(aaliyahSignup, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          );
        }
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final authController = context.read<AuthController>();
    if (authController.isLoading) return;

    if (!_formKey.currentState!.validate()) {
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
      
      // Navigate to login page after successful registration
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
