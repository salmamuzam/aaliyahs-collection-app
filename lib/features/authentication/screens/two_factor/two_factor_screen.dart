import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';

import 'package:aaliyahs_collection_estore/utils/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';
import 'package:pinput/pinput.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Pinput theme - Default state
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: isDarkMode ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: _hasError 
              ? colorScheme.error 
              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          width: _hasError ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
      ),
    );

    // Focused state
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: _hasError 
            ? colorScheme.error 
            : (isDarkMode ? const Color(0xFFE5EDEF) : const Color(0xFF0F172A)),
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(12),
    );

    // Submitted state
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        border: Border.all(
          color: _hasError 
              ? colorScheme.error 
              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          width: _hasError ? 2 : 1,
        ),
      ),
    );

    // Error state
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.error, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return SafeArea(
          child: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, sizingInformation) {
                return Stack(
                  children: [
                    // Subtle Top Background Design
                    Positioned(
                      top: DeviceUtils.getVerticalSize(-50),
                      left: DeviceUtils.getHorizontalSize(-50),
                      child: Container(
                        height: DeviceUtils.getVerticalSize(200),
                        width: DeviceUtils.getHorizontalSize(200),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? aaliyahLightColor.withValues(alpha: 0.05)
                              : aaliyahPrimaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: DeviceUtils.getVerticalSize(50),
                      right: DeviceUtils.getHorizontalSize(-30),
                      child: Container(
                        height: DeviceUtils.getVerticalSize(150),
                        width: DeviceUtils.getHorizontalSize(150),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? aaliyahLightColor.withValues(alpha: 0.05)
                              : aaliyahSecondaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Content
                    SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AaliyahSizes.defaultSpace),
                        child: Column(
                          children: [
                            const SizedBox(height: AaliyahSizes.appBarHeight), 
                            
                            // Header
                            Text(
                              aaliyah2FATitle,
                              style: Theme.of(context).textTheme.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              aaliyah2FASubTitle,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: AaliyahSizes.spaceBtwSections),
                            
                            // Verification Code Section
                            Text(
                              'Verification Code',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 15),
                            
                            Column(
                              children: [
                                Pinput(
                                  length: 6,
                                  controller: _pinController,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  submittedPinTheme: submittedPinTheme,
                                  errorPinTheme: errorPinTheme,
                                  onChanged: (_) => _clearError(), // Clear error when user types
                                  onCompleted: (pin) => _verifyCode(authController),
                                ),
                                const SizedBox(height: AaliyahSizes.spaceBtwSections),
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
                                        : Text(aaliyahVerify.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(height: AaliyahSizes.spaceBtwSections),
                                
                                // Recovery Code Link
                                TextButton(
                                  onPressed: () {
                                    // Placeholder for recovery logic
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.info,
                                      title: const Text('Coming Soon'),
                                      description: const Text('Recovery code login is not implemented yet.'),
                                      autoCloseDuration: const Duration(seconds: 3),
                                    );
                                  },
                                  child: const Text('Sign in with recovery code'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Back Button
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
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
