import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';

import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/login_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:pinput/pinput.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

class TwoFactorScreen extends StatefulWidget {
  final String login;
  final String password;

  const TwoFactorScreen({super.key, required this.login, required this.password});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final TextEditingController _pinController = TextEditingController();
  
  // Error state tracking
  bool _hasError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_hasError) {
      setState(() => _hasError = false);
    }
  }

  Future<void> _verifyCode(AuthController authController) async {
    if (authController.isLoading) return;
    
    // Clear previous error
    _clearError();
    
    final String code = _pinController.text;
    
    // Check for empty or incomplete code
    if (code.isEmpty || code.length < 6) {
      setState(() => _hasError = true);
      _showErrorToast(aaliyah2FAEmptyTitle, aaliyah2FAEmptySubTitle);
      return;
    }

    final result = await authController.verifyTwoFactor(
      login: widget.login,
      password: widget.password,
      code: code,
    );

    if (!mounted) return;

    if (result['status'] == 'success') {
      _showSuccessToast(aaliyah2FASuccessTitle, aaliyah2FASuccessSubTitle);
      
      // Navigate after showing success message
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavigationMenu()),
        (route) => false,
      );
    } else {
      // Highlight field in red for incorrect code
      setState(() => _hasError = true);
      _showErrorToast(aaliyah2FAInvalidTitle, aaliyah2FAInvalidSubTitle);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return SafeArea(
          child: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, sizingInformation) {
                return Stack(
                  children: [
                    // Content
                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: sizingInformation.screenSize.height - 
                                    MediaQuery.of(context).padding.top - 
                                    MediaQuery.of(context).padding.bottom - 
                                    MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Padding(
                          padding: DeviceUtils.getPadding(all: 20),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                const SizedBox(height: 180),
                                
                                // Group 01: Header
                                Column(
                                  children: [
                                    Text(
                                      aaliyah2FATitle,
                                      style: (Theme.of(context).extension<AaliyahTypography>()?.editorialLarge ?? 
                                              Theme.of(context).textTheme.headlineLarge)?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      aaliyah2FASubTitle,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 35),
                                
                                // Group 02: Verification Form
                                Column(
                                  children: [
                                    Pinput(
                                      length: 6,
                                      controller: _pinController,
                                      defaultPinTheme: PinTheme(
                                        width: 56,
                                        height: 56,
                                        textStyle: TextStyle(
                                          fontSize: 22,
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _hasError 
                                                ? Theme.of(context).colorScheme.error 
                                                : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                                            width: _hasError ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                        ),
                                      ),
                                      focusedPinTheme: PinTheme(
                                        width: 56,
                                        height: 56,
                                        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _hasError ? Theme.of(context).colorScheme.error : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE5EDEF) : const Color(0xFF0F172A)),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onChanged: (_) => _clearError(),
                                      onCompleted: (pin) => _verifyCode(authController),
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: () => _verifyCode(authController),
                                        child: authController.isLoading
                                            ? const ExpressiveCircularProgressIndicator(
                                                strokeWidth: 3, 
                                                size: 24,
                                                isWavy: true, 
                                                showTrack: false,
                                                color: Colors.white,
                                                semanticLabel: 'Verifying security code',
                                              )
                                            : const Text(aaliyahVerify, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Back Button
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        ),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
