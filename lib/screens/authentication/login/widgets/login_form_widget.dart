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

  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 [BOOT]: LOGIN FORM INITIALIZED"); // Verification log
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
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
            
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePasswordNotifier,
              builder: (context, obscure, child) {
                return AuthTextField(
                  controller: _passwordController,
                  label: aaliyahPassword,
                  prefixIcon: Icons.password_outlined,
                  obscureText: obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
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
        icon: const Icon(Icons.fingerprint, color: Colors.white),
        label: const Text("LOGIN WITH BIOMETRICS", style: TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 1.5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final authController = context.read<AuthController>();
      
      // FIRST: Check if biometrics are enrolled on device
      final isEnrolled = await _biometricService.isBiometricEnrolled();
      if (!isEnrolled) {
        _showErrorToast(
          "Biometric Not Set Up",
          "Please set up fingerprint or face recognition in your device settings first.",
        );
        return;
      }

      // SECOND: Check if we have saved credentials
      debugPrint("🔐 [UI]: Checking secure storage for saved credentials...");
      final savedEmail = await authController.getBioEmail();
      final savedPassword = await authController.getBioPassword();
      
      debugPrint("🔐 [UI]: Email from storage: ${savedEmail != null ? 'Found' : 'Not found'}");

      if (savedEmail == null || savedPassword == null || savedEmail.isEmpty || savedPassword.isEmpty) {
        debugPrint("🔐 [UI]: No credentials saved yet - user needs to login with email/password first");
        _showErrorToast(
          "Setup Required", 
          "Please login with email and password first to enable biometric login.",
        );
        return;
      }

      // THIRD: Authenticate with biometrics
      debugPrint("🔐 [UI]: Credentials found. Requesting biometric authentication...");
      final isAuthenticated = await _biometricService.authenticate();
      
      if (isAuthenticated) {
        debugPrint("🔐 [UI]: ✅ Biometric authentication successful! Logging in with saved credentials...");
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _handleLogin();
      } else {
        debugPrint("🔐 [UI]: ❌ Biometric authentication failed or cancelled");
        _showErrorToast(
          "Authentication Failed",
          "Biometric authentication was not successful. Please try again.",
        );
      }
    } catch (e) {
      debugPrint("🔐 [UI] ERROR: $e");
      _showErrorToast("Biometric Error", "An error occurred: $e");
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
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
      // NOTE: Biometric storage now handled automatically inside AuthRepository.login()
      debugPrint("🔐 [UI]: Login success. Repo should have saved bio credentials.");
      
      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: const Text("Login Successful"),
        description: const Text("Biometrics enabled for next time."),
        autoCloseDuration: const Duration(seconds: 2),
      );
      
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
