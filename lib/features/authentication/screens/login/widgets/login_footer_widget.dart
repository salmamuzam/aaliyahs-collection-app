import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/routes/app_routes.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('OR'),
        SizedBox(height: TUIConstants.relativeHeight(context, 0.02)),
        SizedBox(
          width: double.infinity,
          child: GoogleAuthButton(
            onPressed: () => _handleGoogleSignIn(context),
            style: const AuthButtonStyle(
              height: 50,
              borderRadius: 30.0,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final result = await authController.signInWithGoogle();
    
    if (!context.mounted) return;

    if (result['status'] == 'success') {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: const Text('Welcome'),
        description: Text("Signed in as ${result['name']}"),
        autoCloseDuration: const Duration(seconds: 3),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.navigationMenu, (route) => false);
    } else if (result['status'] == 'cancelled') {
        // User cancelled
    } else {
       toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text('Sign In Failed'),
        description: Text(result['message'] ?? 'Unknown Error'),
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }
}
