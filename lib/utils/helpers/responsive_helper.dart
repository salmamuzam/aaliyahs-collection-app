import 'package:flutter/material.dart';


class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });



  static double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;
  static Orientation orientation(BuildContext context) => MediaQuery.orientationOf(context);
  static bool isPortrait(BuildContext context) => orientation(context) == Orientation.portrait;
  static bool isLandscape(BuildContext context) => orientation(context) == Orientation.landscape;

  // --- Breakpoint Checkers ---

  static bool isMobile(BuildContext context) => screenWidth(context) < 600;

  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= 600 && screenWidth(context) < 1200;

  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1200;

  // --- Advanced Layout Builders ---


  static Widget buildByOrientation({
    required BuildContext context,
    required Widget portrait,
    required Widget landscape,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }


  static int getGridColumnCount(BuildContext context) {
    double width = screenWidth(context);
    bool landscape = isLandscape(context);
    
    if (width > 1201) return 5;
    if (width > 801) return 4;
    if (width > 600) return 3;
    if (landscape) return 3; 
    return 2; 
  }


  static double getGridAspectRatio(BuildContext context) {
    double width = screenWidth(context);
    if (width > 1200) return 0.55; 
    if (width > 800) return 0.50;  
    if (width < 360) return 0.44; 
    return 0.46; 
  }


  static double getPadding(BuildContext context) {
    double width = screenWidth(context);
    if (width > 1200) return 32.0;
    if (width > 600) return 24.0;
    return 16.0;
  }
}
