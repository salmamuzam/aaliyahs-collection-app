import 'package:flutter/material.dart';

import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/util/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/util/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/signup/signup_screen.dart';

import 'package:aaliyahs_collection_estore/util/device/device_utility.dart';

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
      image: AssetImage(aaliyahWelcomeScreenImage),
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
          aaliyahWelcomeSubTitle.replaceFirst(", ", ",\n"),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: DeviceUtils.getFontSize(14),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            style: OutlinedButton.styleFrom(
              padding: DeviceUtils.getPadding(vertical: 12),
              side: BorderSide(color: isDarkMode ? Colors.white : aaliyahPrimaryColor),
            ),
            child: Text(
              aaliyahLogin.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: DeviceUtils.getFontSize(14),
                color: isDarkMode ? Colors.white : aaliyahPrimaryColor,
              ),
            ),
          ),
        ),
        SizedBox(height: DeviceUtils.getVerticalSize(15)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.white : aaliyahPrimaryColor,
              foregroundColor: isDarkMode ? aaliyahPrimaryColor : Colors.white,
              padding: DeviceUtils.getPadding(vertical: 12),
              elevation: 0,
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
