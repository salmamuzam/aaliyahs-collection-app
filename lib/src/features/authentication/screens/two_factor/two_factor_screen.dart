import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/form/form_header_widget.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snackify/snackify.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TwoFactorScreen extends StatefulWidget {
  final String login;
  final String password;

  const TwoFactorScreen({super.key, required this.login, required this.password});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((e) => e.text).join();

  Future<void> _verifyCode(AuthProvider authProvider) async {
    if (_otpCode.isEmpty || _otpCode.length < 6) {
      Snackify.show(
        context: context,
        type: SnackType.error,
        title: const Text("Error"),
        subtitle: const Text("Please enter the 6-digit code"),
      );
      return;
    }

    final result = await authProvider.verifyTwoFactor(
      login: widget.login,
      password: widget.password,
      code: _otpCode,
    );

    if (!mounted) return;

    if (result['status'] == 'success') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (route) => false,
      );
    } else {
      Snackify.show(
        context: context,
        type: SnackType.error,
        title: const Text("Verification Error"),
        subtitle: Text(result['message'] ?? "Invalid verification code"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(aaliyahDefaultSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    const SizedBox(height: aaliyahDefaultSize),
                    const FormHeaderWidget(
                      image: aaliyahWelcomeScreenImage,
                      title: aaliyah2FATitle,
                      subTitle: aaliyah2FASubTitle,
                    ),
                    const SizedBox(height: aaliyahFormHeight),
                    Form(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) => _otpBox(context, index)),
                          ),
                          const SizedBox(height: aaliyahFormHeight),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : () => _verifyCode(authProvider),
                              child: authProvider.isLoading
                                  ? LoadingAnimationWidget.staggeredDotsWave(
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : const Text(aaliyahVerify),
                            ),
                          ),
                        ],
                      ),
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

  Widget _otpBox(BuildContext context, int index) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextFormField(
        controller: _controllers[index],
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        style: Theme.of(context).textTheme.headlineMedium,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: "",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
