import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/signup/signup_screen.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';

// Refactored Login Header

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          header: true,
          child: Text(
            'Sign In', 
            style: (Theme.of(context).extension<AaliyahTypography>()?.editorialLarge ?? 
                    Theme.of(context).textTheme.headlineLarge)?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
          ),
        ),
        const SizedBox(height: 10),
        Text("Don't Have an Account?", style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          ),
          child: const Text(
            'Sign Up',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
