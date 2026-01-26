import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_footer_widget.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_form_widget.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_header_widget.dart';
import 'package:flutter/material.dart';

// Main Login Screen

import 'package:aaliyahs_collection_estore/src/common_widgets/keyboard_dismisser.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return KeyboardDismisser(
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              // Subtle Top Background Design
              Positioned(
                 top: -50,
                 left: -50,
                 child: Container(
                   height: 200,
                   width: 200,
                    decoration: BoxDecoration(
                      color: isDarkMode ? aaliyahLightColor.withValues(alpha: 0.05) : aaliyahPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                 ),
              ),
               Positioned(
                 top: 50,
                 right: -30,
                 child: Container(
                   height: 150,
                   width: 150,
                    decoration: BoxDecoration(
                      color: isDarkMode ? aaliyahLightColor.withValues(alpha: 0.05) : aaliyahSecondaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                 ),
              ),
              
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(aaliyahDefaultSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 01
                      LoginHeaderWidget(size: size),
                      // Section 02
                      LoginForm(),
                      // Section 03
                      LoginFooterWidget(),
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
