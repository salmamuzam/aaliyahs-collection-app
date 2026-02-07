import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';

// Refactored Login Header

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 60), // Increased top padding
        Semantics(
          header: true,
          child: Text(
            'Sign In', 
            style: (Theme.of(context).extension<AaliyahTypography>()?.editorialLarge ?? 
                    Theme.of(context).textTheme.headlineLarge),
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Don't have an account?", style: Theme.of(context).textTheme.bodyMedium),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text(
                'Sign Up',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
