import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

// Refactored Login Header

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(
          image: AssetImage(aaliyahWelcomeScreenImage),
          height: (size.height * 0.2).clamp(100, 200),
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE5EDEF) : null,
        ),
        const SizedBox(height: aaliyahFormHeight - 20),
        Text(
          aaliyahLoginTitle,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: aaliyahFormHeight - 20),
        Text(
          aaliyahLoginSubTitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: aaliyahFormHeight - 20),
      ],
    );
  }
}
