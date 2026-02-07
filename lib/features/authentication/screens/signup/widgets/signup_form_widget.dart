import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';

import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/login_screen.dart';
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
  bool _agreedToTerms = false;

  // Error state tracking
  bool _firstNameHasError = false;
  bool _lastNameHasError = false;
  bool _usernameHasError = false;
  bool _emailHasError = false;
  bool _passwordHasError = false;
  bool _confirmPasswordHasError = false;

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

  void _clearErrors() {
    setState(() {
      _firstNameHasError = false;
      _lastNameHasError = false;
      _usernameHasError = false;
      _emailHasError = false;
      _passwordHasError = false;
      _confirmPasswordHasError = false;
    });
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
              hasError: _usernameHasError,
            ),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            AuthTextField(
              controller: _emailController,
              label: aaliyahEmail,
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              hasError: _emailHasError,
            ),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            _buildPasswordField(),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            _buildConfirmPasswordField(),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.015)),
            _buildTermsAndConditions(context),
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
          hasError: _firstNameHasError,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: _lastNameController,
          label: aaliyahLastName,
          prefixIcon: Icons.person_outline_rounded,
          hasError: _lastNameHasError,
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
          hasError: _passwordHasError,
          suffixIcon: IconButton(
            onPressed: () => _obscurePasswordNotifier.value = !obscure,
            icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
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
          prefixIcon: Icons.lock_rounded,
          obscureText: obscure,
          hasError: _confirmPasswordHasError,
          suffixIcon: IconButton(
            onPressed: () => _obscureConfirmPasswordNotifier.value = !obscure,
            icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
          ),
        );
      }
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Semantics(
              label: 'Agree to terms and conditions',
              selected: _agreedToTerms,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'I agree to the ', style: Theme.of(context).textTheme.bodyMedium),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: Theme.of(context).textTheme.bodyMedium?.apply(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return FilledButton(
            onPressed: () => _handleSignUp(),
            child: authController.isLoading
                ? ExpressiveCircularProgressIndicator(
                    strokeWidth: 3, 
                    size: 24,
                    isWavy: true, 
                    showTrack: false,
                    color: Theme.of(context).colorScheme.onPrimary,
                    semanticLabel: 'Creating your new account',
                  )
                : Text(aaliyahSignup.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final authController = context.read<AuthController>();
    if (authController.isLoading) return;

    // Clear previous errors
    _clearErrors();

    // Check for empty fields
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _firstNameHasError = _firstNameController.text.isEmpty;
        _lastNameHasError = _lastNameController.text.isEmpty;
        _usernameHasError = _usernameController.text.isEmpty;
        _emailHasError = _emailController.text.isEmpty;
        _passwordHasError = _passwordController.text.isEmpty;
        _confirmPasswordHasError = _confirmPasswordController.text.isEmpty;
      });
      _showToast(aaliyahSignUpEmptyTitle, aaliyahSignUpEmptySubTitle, ToastificationType.error);
      return;
    }

    // Check for password mismatch
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordHasError = true;
        _confirmPasswordHasError = true;
      });
      _showToast(aaliyahPasswordMismatchTitle, aaliyahPasswordMismatchSubTitle2, ToastificationType.error);
      return;
    }

    if (!_agreedToTerms) {
      _showToast('Terms & Conditions', 'Please agree to the terms and conditions to continue.', ToastificationType.warning);
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
