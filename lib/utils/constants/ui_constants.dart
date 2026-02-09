import 'package:flutter/material.dart';

class TUIConstants {
  // Paging & Loading
  static const int pagingThreshold = 200;
  static const int defaultSkeletonCount = 6;

  // Spacing & Padding
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 8.0;

  static const double shapeRadiusXS = 4.0;
  static const double shapeRadiusExtraSmall = shapeRadiusXS;
  static const double shapeRadiusSmall = 8.0;
  static const double shapeRadiusMedium = 12.0;    
  static const double shapeRadiusLarge = 16.0;
  static const double shapeRadiusLargeIncreased = 20.0;
  static const double shapeRadiusXL = 28.0;
  
  static const double buttonRadius = 24.0;
  
  // Cart Animation
  static const double cartAnimHeight = 30.0;
  static const double cartAnimWidth = 30.0;
  static const double cartAnimOpacity = 0.85;
  static const double shapeRadiusXLIncreased = 32.0;
  static const double shapeRadiusXXL = 48.0;
  static const double shapeRadiusFull = 999.0;    

  static const double cardRadius = shapeRadiusMedium; 

  static const double inputFieldRadius = shapeRadiusMedium;
  static const double dialogRadius = shapeRadiusXL; 
  static const double bottomSheetRadius = shapeRadiusXL; 

  // Animations
  static const Duration fadeInFast = Duration(milliseconds: 200);
  static const Duration fadeInMedium = Duration(milliseconds: 400);
  static const Duration fadeInSlow = Duration(milliseconds: 600);
  static const Duration fadeInExtraSlow = Duration(milliseconds: 800);
  static const Duration bannerAutoPlay = Duration(seconds: 4);



  // Responsive Helpers
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double relativeHeight(BuildContext context, double multiplier) =>
      screenHeight(context) * multiplier;
  static double relativeWidth(BuildContext context, double multiplier) =>
      screenWidth(context) * multiplier;

  // Private constructor to prevent instantiation
  TUIConstants._();
}
