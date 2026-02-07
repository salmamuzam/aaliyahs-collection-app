import 'package:flutter/material.dart';

import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/signup/signup_screen.dart';

import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahPrimaryColor : Colors.white,
      body: SafeArea(
        child: Container(
          padding: DeviceUtils.getPadding(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWelcomeImage(),
              _buildWelcomeText(context),
              _buildActionButtons(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeImage() {
    return Image(
      image: const AssetImage(aaliyahWelcomeScreenImage),
      height: DeviceUtils.getVerticalSize(300),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text(
          aaliyahWelcomeTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: DeviceUtils.getFontSize(28),
          ),
        ),
        SizedBox(height: DeviceUtils.getVerticalSize(10)),
        Text(
          aaliyahWelcomeSubTitle.replaceFirst(', ', ',\n'),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: DeviceUtils.getFontSize(14),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            style: OutlinedButton.styleFrom(
              padding: DeviceUtils.getPadding(vertical: 16),
              side: BorderSide(color: isDarkMode ? Colors.white70 : colorScheme.primary),
            ),
            child: Text(
              aaliyahLogin.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: DeviceUtils.getFontSize(14),
                color: isDarkMode ? Colors.white : colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: DeviceUtils.getHorizontalSize(15)),
        Expanded(
          child: FilledButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            ),
            style: FilledButton.styleFrom(
              padding: DeviceUtils.getPadding(vertical: 16),
              backgroundColor: isDarkMode ? Colors.white : colorScheme.primary,
              foregroundColor: isDarkMode ? colorScheme.primary : Colors.white,
            ),
            child: Text(
              aaliyahSignup.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: DeviceUtils.getFontSize(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
