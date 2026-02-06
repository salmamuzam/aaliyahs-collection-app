import 'package:flutter/material.dart';

// Refactored Login Header

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const SizedBox(height: 60), // Increased top padding
        Text(
          "Sign In", // Changed title
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?", style: Theme.of(context).textTheme.bodyMedium),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text("Sign Up"),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
