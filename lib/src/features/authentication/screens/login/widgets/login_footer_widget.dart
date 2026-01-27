import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/providers/auth_provider.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("OR"),
        SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
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
        SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? const Color(0xFFE5EDEF) : null,
              side: isDarkMode ? const BorderSide(color: Color(0xFFE5EDEF)) : null,
            ),
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
    final result = await authProvider.signInWithGoogle();
    
    if (!context.mounted) return;

    if (result['status'] == 'success') {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: const Text("Welcome"),
        description: Text("Signed in as ${result['name']}"),
        autoCloseDuration: const Duration(seconds: 3),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
