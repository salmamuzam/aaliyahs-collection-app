import 'package:aaliyahs_collection_estore/utils/constants/sizes.dart';
import 'package:flutter/material.dart';



class FormHeaderWidget extends StatelessWidget {
  // Properties that can be customized
  final String image;                          // Path to the image file
  final String title;                          // Main heading text
  final String subTitle;                       // Description text below title
  final double imageHeight;                    // How tall the image should be 
  final double? heightBetween;                 // Space between image and title
  final TextAlign? textAlign;                  // How to align the subtitle text
  final CrossAxisAlignment crossAxisAlignment; // How to align items in the column

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

  @override
  Widget build(BuildContext context) {
 

    
    // Stack items vertically
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  
      children: [
        // Logo/Image at the top

        
        // Space between image and title
        SizedBox(height: heightBetween ?? (AaliyahSizes.aaliyahFormHeight - 20)),
        
        // Main title
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,  
        ),
        
        // Small space between title and subtitle
        const SizedBox(height: 5),
        
        // Subtitle 
        Text(
          subTitle,
          style: Theme.of(context).textTheme.bodyLarge, 
          textAlign: textAlign,
        ),
        
        // Space at the bottom
        const SizedBox(height: 10),
      ],
    );
  }
}
