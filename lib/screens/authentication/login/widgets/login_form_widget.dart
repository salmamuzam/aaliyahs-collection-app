import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/util/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/forget_password/forget_password_screen.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/two_factor/two_factor_screen.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/login/widgets/auth_text_field.dart';
import 'package:aaliyahs_collection_estore/screens/navigation/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/data/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  bool _isBioAvailable = false;

  // Optimization: Use ValueNotifier to avoid full widget rebuild on visibility toggle
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    if (mounted) setState(() => _isBioAvailable = available);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: TUIConstants.relativeHeight(context, 0.02)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthTextField(
              controller: _emailController,
              label: aaliyahLoginLabel,
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next, // Logical Tab Order (Top -> Bottom)
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(), // Move focus to password on Enter
            ),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
            
            // Optimization: ValueListenableBuilder for granular UI updates
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePasswordNotifier,
              builder: (context, obscure, child) {
                return AuthTextField(
                  controller: _passwordController,
                  label: aaliyahPassword,
                  prefixIcon: Icons.password_outlined,
                  obscureText: obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(), // Enter key triggers submission (Standard behavior)
                  suffixIcon: IconButton(
                    onPressed: () => _obscurePasswordNotifier.value = !obscure,
                    icon: Icon(
                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: isDarkMode ? const Color(0xFFE5EDEF) : null,
                    ),
                  ),
                );
              },
            ),
            
            _buildForgetPasswordButton(context, isDarkMode),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
            _buildLoginButton(),
            if (_isBioAvailable) ...[
              const SizedBox(height: 15),
              _buildBiometricButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleBiometricLogin(),
        icon: const Icon(Icons.fingerprint),
        label: const Text("LOGIN WITH BIOMETRICS"),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: aaliyahPrimaryColor),
          foregroundColor: aaliyahPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _handleBiometricLogin() async {
    // final authController = context.read<AuthController>(); // Unused
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');

    if (savedEmail == null || savedPassword == null) {
      _showErrorToast("Setup Required", "Please login with your password first to enable biometrics.");
      return;
    }

    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      _handleLogin();
    }
  }

  Widget _buildForgetPasswordButton(BuildContext context, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
        ),
        style: TextButton.styleFrom(
          foregroundColor: isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor,
        ),
        child: Text(aaliyahForgetPassword),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return ElevatedButton(
            onPressed: () => _handleLogin(),
            child: authController.isLoading
                ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 30)
                : Text(aaliyahLogin.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          );
        }
      ),
    );
  }

  Future<void> _handleLogin() async {
    final authController = context.read<AuthController>();
    if (authController.isLoading) return;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorToast(aaliyahEmptyFieldTitle, aaliyahEmptyFieldSubTitle);
      return;
    }

    final result = await authController.login(_emailController.text, _passwordController.text);
    if (!mounted) return;

    if (result['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', _emailController.text);
      await prefs.setString('saved_password', _passwordController.text);
      
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationMenu()));
    } else if (result['status'] == '2fa_required') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TwoFactorScreen(login: _emailController.text, password: _passwordController.text),
        ),
      );
    } else {
      _showErrorToast(aaliyahInvalidCredTitle, aaliyahInvalidCredSubTitle);
    }
  }

  void _showErrorToast(String title, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
}
