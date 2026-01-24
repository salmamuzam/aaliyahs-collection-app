import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/signup/signup_screen.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';

// Main Welcome Screen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var brightness = mediaQuery.platformBrightness;
    var height = mediaQuery.size.height;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahPrimaryColor : aaliyahSecondaryColor,
      body: Container(
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Welcome Image
            Image(
              image: AssetImage(aaliyahWelcomeScreenImage),
              height: (height * 0.5).clamp(150, 400),
            ),
            // Welcome Title & Subtitle
            Column(
              children: [
                Text(
                  aaliyahWelcomeTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  aaliyahWelcomeSubTitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Two Buttons in a Row
            Row(
              children: [
                // Login and Signup Buttons
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      aaliyahLogin.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      aaliyahSignup.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
