import 'package:flutter/material.dart';

/// Helper class for responsive design based on MediaQuery best practices.
/// Follows Samuel Getachew's guide on orientation and breakpoints.
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

  // --- MediaQuery Accessors ---
  // Using MediaQuery.sizeOf() for better performance - only rebuilds on size changes

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

  /// Builds different layouts based on orientation as per Samuel Getachew's guide.
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

  // Helper for dynamic Grid Column Count based on MediaQuery scaling
  static int getGridColumnCount(BuildContext context) {
    double width = screenWidth(context);
    bool landscape = isLandscape(context);
    
    if (width > 1201) return 5;
    if (width > 801) return 4;
    if (width > 600) return 3;
    if (landscape) return 3; // Extra column in landscape for mobile
    return 2; 
  }

  // Dynamic Aspect Ratio to prevent overflows on different screen sizes
  static double getGridAspectRatio(BuildContext context) {
    double width = screenWidth(context);
    if (width > 1200) return 0.72; // Increased space
    if (width > 800) return 0.65;  // Increased space
    if (width < 360) return 0.58; // Significantly more space for small screens
    return 0.62; // Better for standard phones
  }

  // Helper for responsive padding using relative dimensions
  static double getPadding(BuildContext context) {
    double width = screenWidth(context);
    if (width > 1200) return 32.0;
    if (width > 600) return 24.0;
    return 16.0;
  }
}
