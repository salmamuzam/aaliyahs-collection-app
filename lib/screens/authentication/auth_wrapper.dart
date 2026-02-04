import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aaliyahs_collection_estore/data/repositories/auth_repository.dart';
import 'package:aaliyahs_collection_estore/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/welcome/welcome_screen.dart';
import 'package:aaliyahs_collection_estore/screens/navigation/navigation_menu.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';

/// Monitoring user identity via Firebase Auth state changes.
/// Best practice: Strike a balance between security and accessibility.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen: true so that logout() triggers a rebuild to re-check token
    final authController = Provider.of<AuthController>(context, listen: true);

    return FutureBuilder<String?>(
      future: AuthRepository().getToken(),
      builder: (context, tokenSnapshot) {
        // If checking token, show loading
        if (tokenSnapshot.connectionState == ConnectionState.waiting) {
             return Scaffold(
                body: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(color: aaliyahPrimaryColor, size: 50),
                ),
             );
        }

        final bool hasLaravelToken = tokenSnapshot.data != null;

        return StreamBuilder<User?>(
          stream: authController.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(color: aaliyahPrimaryColor, size: 50),
                ),
              );
            }

            // Check if user is logged in (either Firebase or via Laravel token)
            if (snapshot.hasData || hasLaravelToken) {
              return const NavigationMenu();
            }

            // If no Firebase user AND no Laravel token, show welcome
            return const WelcomeScreen();
          },
        );
      },
    );
  }
}
