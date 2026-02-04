import 'package:aaliyahs_collection_estore/util/constants/sizes.dart';
import 'package:flutter/material.dart';

// ============================================================================
// FORM HEADER WIDGET - Reusable Header for Login/Signup Forms
// ============================================================================
// This widget shows a nice header at the top of forms
// It includes:
// - An image/logo
// - A title (big text)
// - A subtitle (smaller description text)
// I use this on login, signup, and forgot password screens
// ============================================================================

class FormHeaderWidget extends StatelessWidget {
  // Properties that can be customized
  final String image;                          // Path to the image file
  final String title;                          // Main heading text
  final String subTitle;                       // Description text below title
  final double imageHeight;                    // How tall the image should be (as % of screen)
  final double? heightBetween;                 // Space between image and title
  final TextAlign? textAlign;                  // How to align the subtitle text
  final CrossAxisAlignment crossAxisAlignment; // How to align items in the column

  const FormHeaderWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.imageHeight = 0.2,  // Default: image takes 20% of screen height
    this.heightBetween,
    this.textAlign,
    this.crossAxisAlignment = CrossAxisAlignment.start,  // Default: align to left
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size to make image responsive
    final size = MediaQuery.of(context).size;
    
    // Stack items vertically
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  // Align everything to the left
      children: [
        // Logo/Image at the top
        Image(
          image: AssetImage(image),
          // Calculate image height based on screen size
          // clamp() ensures it's between 50 and 200 pixels (not too small or too big)
          height: (size.height * imageHeight).clamp(50, 200),
        ),
        
        // Space between image and title
        SizedBox(height: heightBetween ?? (AaliyahSizes.aaliyahFormHeight - 20)),
        
        // Main title (big text)
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,  // Use theme's large heading style
        ),
        
        // Small space between title and subtitle
        const SizedBox(height: 5),
        
        // Subtitle (description text)
        Text(
          subTitle,
          style: Theme.of(context).textTheme.bodyLarge,  // Use theme's body text style
          textAlign: textAlign,
        ),
        
        // Space at the bottom
        const SizedBox(height: 10),
      ],
    );
  }
}
