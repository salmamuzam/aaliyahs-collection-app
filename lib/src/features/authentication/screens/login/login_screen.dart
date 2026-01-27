import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_footer_widget.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_form_widget.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_header_widget.dart';
import 'package:flutter/material.dart';

// Main Login Screen

import 'package:aaliyahs_collection_estore/src/common_widgets/keyboard_dismisser.dart';

import 'package:responsive_builder/responsive_builder.dart';

import 'package:aaliyahs_collection_estore/src/utils/device/device_utility.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return KeyboardDismisser(
      child: SafeArea(
        child: Scaffold(
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return Stack(
                children: [
                  // Subtle Top Background Design - Scaled with Screen Utility
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

                  SingleChildScrollView(
                    child: Container(
                      padding: DeviceUtils.getPadding(all: 20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 01
                          LoginHeaderWidget(size: size),
                          // Section 02 - Add extra space if tablet/desktop
                          SizedBox(height: sizingInformation.isTablet ? DeviceUtils.getVerticalSize(40) : DeviceUtils.getVerticalSize(20)),
                          LoginForm(),
                          // Section 03
                          LoginFooterWidget(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
