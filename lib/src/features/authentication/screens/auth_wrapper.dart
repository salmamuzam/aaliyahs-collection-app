import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:aaliyahs_collection_estore/src/data/services/auth_service.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/providers/auth_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

/// Monitoring user identity via Firebase Auth state changes.
/// Best practice: Strike a balance between security and accessibility.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen: true so that logout() triggers a rebuild to re-check token
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    return FutureBuilder<String?>(
      future: AuthService().getToken(),
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
          stream: authProvider.authStateChanges,
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
