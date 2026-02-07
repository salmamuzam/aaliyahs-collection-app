
import 'package:aaliyahs_collection_estore/utils/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';

import 'package:aaliyahs_collection_estore/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import 'package:flutter/material.dart';

// Main Sign Up Screen

import 'package:aaliyahs_collection_estore/common/widgets/misc/keyboard_dismisser.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return KeyboardDismisser(
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
               // Subtle Top Background Design
              Positioned(
                 top: -100,
                 right: -50,
                 child: Container(
                   height: 250,
                   width: 250,
                   decoration: BoxDecoration(
                     color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05),
                     shape: BoxShape.circle,
                   ),
                 ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(AaliyahSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: AaliyahSizes.aaliyahFormHeight - 20),
                          Text(
                            aaliyahSignUpTitle,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(aaliyahAlreadyHaveAccount, style: Theme.of(context).textTheme.bodyMedium),
                              TextButton(
                                onPressed: () => Navigator.pop(context), // Go back to login
                                child: Text(aaliyahLogin.toUpperCase()),
                              ),
                            ],
                          ),
                          const SizedBox(height: AaliyahSizes.aaliyahFormHeight - 20),
                          Text(
                            aaliyahSignUpSubTitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SignUpFormWidget(),
                      // SignUpFooterWidget(), // Removed as link is moved to top
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
