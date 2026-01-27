import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/providers/auth_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/forget_password/forget_password_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/two_factor/two_factor_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/auth_text_field.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Optimization: Use ValueNotifier to avoid full widget rebuild on visibility toggle
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
            _buildLoginButton(authProvider),
          ],
        ),
      ),
    );
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

  Widget _buildLoginButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleLogin(authProvider),
        child: authProvider.isLoading
            ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 30)
            : Text(aaliyahLogin.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (authProvider.isLoading) return;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorToast(aaliyahEmptyFieldTitle, aaliyahEmptyFieldSubTitle);
      return;
    }

    final result = await authProvider.login(_emailController.text, _passwordController.text);
    if (!mounted) return;

    if (result['status'] == 'success') {
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
