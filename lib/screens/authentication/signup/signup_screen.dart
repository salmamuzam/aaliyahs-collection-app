import 'package:aaliyahs_collection_estore/common/widgets/form/form_header_widget.dart';
import 'package:aaliyahs_collection_estore/util/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/util/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/util/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/signup/widgets/signup_footer_widget.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/signup/widgets/signup_form_widget.dart';
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
                      FormHeaderWidget(
                        image: aaliyahWelcomeScreenImage,
                        title: aaliyahSignUpTitle,
                        subTitle: aaliyahSignUpSubTitle,
                        heightBetween: 10,
                        imageHeight: 0.12, // Reduced from default (usually 0.2 or higher)
                      ),
                      SignUpFormWidget(),
                      SignUpFooterWidget(),
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
