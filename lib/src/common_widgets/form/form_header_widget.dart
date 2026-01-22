import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:flutter/material.dart';

// This is a common widget which will be used in Login and Sign up Form

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(image: AssetImage(image), height: size.height * 0.2),
        const SizedBox(height: aaliyahFormHeight - 20),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: aaliyahFormHeight - 20),
        Text(subTitle, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: aaliyahFormHeight - 20),
      ],
    );
  }
}
