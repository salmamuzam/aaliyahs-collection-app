import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';

import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/forget_password/forget_password_screen.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/two_factor/two_factor_screen.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/form/auth_text_field.dart';
import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';
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
  final FocusNode _passwordFocusNode = FocusNode();
  final BiometricService _biometricService = BiometricService();
  
  bool _isBioAvailable = false;
  bool _rememberMe = false;
  
  // Error state tracking
  bool _emailHasError = false;
  bool _passwordHasError = false;

  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [BOOT]: LOGIN FORM INITIALIZED'); // Verification log
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
    _passwordFocusNode.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailHasError = false;
      _passwordHasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AccessibilityController>(
      builder: (context, access, _) {
        final bool reduceMotion = access.reduceMotion;
        
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
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  hasError: _emailHasError,
                ),
                SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
                
                ValueListenableBuilder<bool>(
                  valueListenable: _obscurePasswordNotifier,
                  builder: (context, obscure, child) {
                    return AuthTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: aaliyahPassword,
                      prefixIcon: Icons.lock_rounded,
                      obscureText: obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      hasError: _passwordHasError,
                      suffixIcon: IconButton(
                        onPressed: () => _obscurePasswordNotifier.value = !obscure,
                        tooltip: obscure ? 'Show password' : 'Hide password',
                        icon: Icon(
                          obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: isDarkMode ? const Color(0xFFE5EDEF) : null,
                        ),
                      ),
                    );
                  },
                ),
                
                _buildRememberMeAndForgetPassword(context, isDarkMode),
                SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
                _buildLoginButton(),
                if (_isBioAvailable) ...[ 
                  const SizedBox(height: 15),
                  _buildBiometricButton(),
                ],
              ].animate(
                interval: reduceMotion ? 0.ms : AMotion.durationShort2, // 100ms staggered
              ).fadeIn(
                duration: AMotion.durationEnterEmphasized,
                curve: AMotion.easingEmphasizedDecelerate,
              ).slideY(
                begin: 0.1, 
                end: 0,
                duration: AMotion.durationEnterEmphasized,
                curve: AMotion.easingEmphasizedDecelerate,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleBiometricLogin(),
        icon: const Icon(Icons.fingerprint_rounded),
        label: const Text('Login with Fingerprint'),
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
          'Biometric Not Set Up',
          'Please set up fingerprint or face recognition in your device settings first.',
        );
        return;
      }

      // SECOND: Check if we have saved credentials
      debugPrint('🔐 [UI]: Checking secure storage for saved credentials...');
      final savedEmail = await authController.getBioEmail();
      final savedPassword = await authController.getBioPassword();
      
      debugPrint('🔐 [UI]: Email from storage: ${savedEmail != null ? 'Found' : 'Not found'}');

      if (savedEmail == null || savedPassword == null || savedEmail.isEmpty || savedPassword.isEmpty) {
        debugPrint('🔐 [UI]: No credentials saved yet - user needs to login with email/password first');
        _showErrorToast(
          'Setup Required', 
          'Please login in once to enable fingerprint!',
        );
        return;
      }

      // THIRD: Authenticate with biometrics
      debugPrint('🔐 [UI]: Credentials found. Requesting biometric authentication...');
      final isAuthenticated = await _biometricService.authenticate();
      
      if (isAuthenticated) {
        debugPrint('🔐 [UI]: ✅ Biometric authentication successful! Logging in with saved credentials...');
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _handleLogin();
      } else {
        debugPrint('🔐 [UI]: ❌ Biometric authentication failed or cancelled');
        _showErrorToast(
          'Authentication Failed',
          'Biometric authentication was not successful. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('🔐 [UI] ERROR: $e');
      _showErrorToast('Biometric Error', 'An error occurred: $e');
    }
  }

  Widget _buildRememberMeAndForgetPassword(BuildContext context, bool isDarkMode) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: 'Remember me',
                  selected: _rememberMe,
                  button: true,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value ?? false),
                  ),
                ),
                Text(
                  aaliyahRememberMe,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
          ),
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor,
          ),
          child: const Text(
            aaliyahForgetPassword,
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return FilledButton(
            onPressed: () => _handleLogin(),
            child: authController.isLoading
                ? ExpressiveCircularProgressIndicator(
                    strokeWidth: 3, 
                    size: 24,
                    isWavy: true, 
                    showTrack: false,
                    color: colorScheme.onPrimary,
                    semanticLabel: 'Logging into your account',
                  )
                : Text(aaliyahLogin.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }
      ),
    );
  }

  Future<void> _handleLogin() async {
    final authController = context.read<AuthController>();
    if (authController.isLoading) return;
    
    // Clear previous errors
    _clearErrors();
    
    // Check for empty fields
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _emailHasError = _emailController.text.isEmpty;
        _passwordHasError = _passwordController.text.isEmpty;
      });
      _showErrorToast(aaliyahEmptyFieldTitle, aaliyahEmptyFieldSubTitle);
      return;
    }

    final result = await authController.login(_emailController.text, _passwordController.text);
    if (!mounted) return;

    if (result['status'] == 'success') {
      // NOTE: Biometric storage now handled automatically inside AuthRepository.login()
      debugPrint('🔐 [UI]: Login success. Repo should have saved bio credentials.');
      
      _showSuccessToast(aaliyahLoginSuccessTitle, aaliyahLoginSuccessSubTitle);
      
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
      // Highlight fields in red for incorrect credentials
      setState(() {
        _emailHasError = true;
        _passwordHasError = true;
      });
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

  void _showSuccessToast(String title, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
