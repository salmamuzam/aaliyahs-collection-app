import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/form/form_header_widget.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pinput/pinput.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class TwoFactorScreen extends StatefulWidget {
  final String login;
  final String password;

  const TwoFactorScreen({super.key, required this.login, required this.password});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode(AuthProvider authProvider) async {
    if (authProvider.isLoading) return;
    final String code = _pinController.text;
    if (code.isEmpty || code.length < 6) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text("Empty Fields"),
        description: const Text("Please enter your authentication code!"),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    final result = await authProvider.verifyTwoFactor(
      login: widget.login,
      password: widget.password,
      code: code,
    );

    if (!mounted) return;

    if (result['status'] == 'success') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavigationMenu()),
        (route) => false,
      );
    } else {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text("Invalid Code!"),
        description: const Text("Please enter a valid authentication code!"),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Pinput theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: isDarkMode ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey.shade900 : const Color.fromRGBO(243, 246, 249, 1),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: isDarkMode ? Colors.white : aaliyahPrimaryColor),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: isDarkMode ? Colors.grey.shade900 : const Color.fromRGBO(243, 246, 249, 1),
      ),
    );

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: aaliyahDefaultSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormHeaderWidget(
                      image: aaliyahWelcomeScreenImage,
                      title: aaliyah2FATitle,
                      subTitle: aaliyah2FASubTitle,
                    ),
                    const SizedBox(height: aaliyahFormHeight),
                    Column(
                      children: [
                        Pinput(
                          length: 6,
                          controller: _pinController,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          onCompleted: (pin) => _verifyCode(authProvider),
                        ),
                        const SizedBox(height: aaliyahFormHeight),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _verifyCode(authProvider),
                            child: authProvider.isLoading
                                ? LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Text(aaliyahVerify.toUpperCase(), style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
