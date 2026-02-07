import 'package:aaliyahs_collection_estore/utils/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/common/widgets/misc/keyboard_dismisser.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(AaliyahSizes.defaultSpace),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  // Heading Section
                  Column(
                    children: [
                      Text(
                        aaliyahSignUpTitle,
                        style: (Theme.of(context).extension<AaliyahTypography>()?.editorialLarge ?? 
                                Theme.of(context).textTheme.headlineLarge)?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        aaliyahAlreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        ), // Go back to login
                        child: const Text(
                          aaliyahLogin,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 5),
                  const SignUpFormWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
