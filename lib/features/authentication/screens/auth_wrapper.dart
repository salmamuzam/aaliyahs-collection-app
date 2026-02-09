import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aaliyahs_collection_estore/data/repositories/auth_repository.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen: true so that logout() triggers a rebuild to re-check token
    final authController = Provider.of<AuthController>(context);

    return FutureBuilder<String?>(
      future: AuthRepository().getToken(),
      builder: (context, tokenSnapshot) {
        // If checking token, show loading
        if (tokenSnapshot.connectionState == ConnectionState.waiting) {
             return const Scaffold(
                body: Center(
                child: ExpressiveCircularProgressIndicator(
                  color: aaliyahPrimaryColor, 
                  isWavy: true,
                  semanticLabel: 'Authenticating your credentials',
                ),
                ),
             );
        }

        final bool hasLaravelToken = tokenSnapshot.data != null;

        return StreamBuilder<User?>(
          stream: authController.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                child: ExpressiveCircularProgressIndicator(
                  color: aaliyahPrimaryColor, 
                  isWavy: true,
                  semanticLabel: 'Checking your account status',
                ),
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
