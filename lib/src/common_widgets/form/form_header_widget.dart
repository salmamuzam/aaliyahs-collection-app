import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:flutter/material.dart';

// This is a common widget which will be used in Login and Sign up Form

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.imageHeight = 0.2,
    this.heightBetween,
    this.textAlign,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String image, title, subTitle;
  final double imageHeight;
  final double? heightBetween;
  final TextAlign? textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(image: AssetImage(image), height: (size.height * imageHeight).clamp(50, 200)),
        SizedBox(height: heightBetween ?? (aaliyahFormHeight - 20)),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 5),
        Text(subTitle, style: Theme.of(context).textTheme.bodyLarge, textAlign: textAlign),
        const SizedBox(height: 10),
      ],
    );
  }
}
