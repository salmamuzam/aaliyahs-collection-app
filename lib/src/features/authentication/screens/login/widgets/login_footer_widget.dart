import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/signup/signup_screen.dart';

import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:toastification/toastification.dart';

// Refactored Login Footer
class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("OR"),
        const SizedBox(height: aaliyahFormHeight - 20),
        SizedBox(
          width: double.infinity,
          child: GoogleAuthButton(
            onPressed: () => _handleGoogleSignIn(context),
            themeMode: ThemeMode.system,
            style: const AuthButtonStyle(
              width: double.infinity,
              height: 50,
            ),
          ),
        ),
        const SizedBox(height: aaliyahFormHeight - 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: Text(
              aaliyahSignup.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading? The auth provider handles internal loading state but UI blocking needed?
    // GoogleSignin provides its own UI mostly.
    
    final result = await authProvider.signInWithGoogle();
    
    if (!context.mounted) return;

    if (result['status'] == 'success') {
      // Create a temporary User in UserProvider if needed or just navigate
      // Since we don't sync with Laravel, fetched profile will be empty/error.
      
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: const Text("Welcome"),
        description: Text("Signed in as ${result['name']}"),
        autoCloseDuration: const Duration(seconds: 3),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (route) => false,
      );
    } else if (result['status'] == 'cancelled') {
       // User cancelled
    } else {
       toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text("Sign In Failed"),
        description: Text(result['message'] ?? 'Unknown Error'),
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

}
