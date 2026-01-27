import 'package:flutter/material.dart';

class TUIConstants {
  // Paging & Loading
  static const int pagingThreshold = 200;
  static const int defaultSkeletonCount = 6;

  // Spacing & Padding
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 8.0;
  static const double cardRadius = 15.0;
  static const double buttonRadius = 10.0;

  // Animations
  static const Duration fadeInFast = Duration(milliseconds: 200);
  static const Duration fadeInMedium = Duration(milliseconds: 400);
  static const Duration fadeInSlow = Duration(milliseconds: 600);
  static const Duration fadeInExtraSlow = Duration(milliseconds: 800);
  static const Duration bannerAutoPlay = Duration(seconds: 4);

  // Cart Animation
  static const double cartAnimHeight = 30.0;
  static const double cartAnimWidth = 30.0;
  static const double cartAnimOpacity = 0.85;

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
