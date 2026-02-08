import 'package:flutter/material.dart';

/// Battle-tested Screen utility class for pixel-perfect responsive design.
/// Bridges the gap between Figma designs and ProductModelion Flutter code.
class DeviceUtils {
  // Figma design dimensions (Baseline truth)
  static num figmaDesignWidth = 360;
  static num figmaDesignHeight = 812;
  
  static num _width = 0;
  static num _height = 0;

  /// Initialize screen adaptation using current context.
  /// Call this in the build method or didChangeDependencies of your root widget.
  /// Uses MediaQuery.sizeOf() for better performance - only rebuilds on size changes.
  void adaptDeviceScreenSize(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _width = size.width;
    _height = size.height;
  }

  /// Calculate unified scaling factor to maintain aspect ratio.
  static double getScaleFactor() {
    double scaleWidth = _width / figmaDesignWidth;
    double scaleHeight = _height / figmaDesignHeight;
    // Choose the smaller one to ensure nothing gets cut off
    return scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
  }

  static double get width => _width * 1.0;
  static double get height => _height * 1.0;

  /// Dynamic Safe Height Calculation (excludes status bar and nav bar).
  static double getSafeHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }

  /// Scale based on width - Use for container widths and horizontal spacing.
  static double getHorizontalSize(double px) {
    return ((px * width) / figmaDesignWidth);
  }

  /// Scale based on height - Use for container heights and vertical spacing.
  static double getVerticalSize(double px) {
    return ((px * height) / figmaDesignHeight);
  }

  /// Uniform Scaling - Use for icons, border-radius, and depth.
  static double getSize(double px) {
    return px * getScaleFactor();
  }

  /// Smart Font Scaling with safety limits (8.0 to 40.0).
  static double getFontSize(double px) {
    return (px * _width / figmaDesignWidth).clamp(8.0, 40.0);
  }

  /// Responsive Padding.
  static EdgeInsets getPadding({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) {
    return getMarginOrPadding(
      all: all,
      left: left ?? horizontal,
      top: top ?? vertical,
      right: right ?? horizontal,
      bottom: bottom ?? vertical,
    );
  }

  /// Responsive Margin.
  static EdgeInsets getMargin({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) {
    return getMarginOrPadding(
      all: all,
      left: left ?? horizontal,
      top: top ?? vertical,
      right: right ?? horizontal,
      bottom: bottom ?? vertical,
    );
  }

  static EdgeInsets getMarginOrPadding({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      left = all;
      top = all;
      right = all;
      bottom = all;
    }
    return EdgeInsets.only(
      left: getHorizontalSize(left ?? 0),
      top: getVerticalSize(top ?? 0),
      right: getHorizontalSize(right ?? 0),
      bottom: getVerticalSize(bottom ?? 0),
    );
  }

  // Material Design 3 Window Size Class Detection
  static WindowSizeClass get windowSizeClass {
    if (_width < 600) return WindowSizeClass.compact;
    if (_width < 840) return WindowSizeClass.medium;
    if (_width < 1240) return WindowSizeClass.expanded;
    if (_width < 1600) return WindowSizeClass.large;
    return WindowSizeClass.extraLarge;
  }

  static bool get isCompact => windowSizeClass == WindowSizeClass.compact;
  static bool get isMedium => windowSizeClass == WindowSizeClass.medium;
  static bool get isExpanded => windowSizeClass == WindowSizeClass.expanded;
  static bool get isLarge => windowSizeClass == WindowSizeClass.large;
  static bool get isExtraLarge => windowSizeClass == WindowSizeClass.extraLarge;
  
  /// Returns true if window size is expanded or larger (tablet/desktop)
  static bool get isTabletOrLarger => _width >= 840;
  
  /// Returns true if window size is large or extra-large (desktop)
  static bool get isDesktop => _width >= 1240;

  /// Standard M3 Margin for the current window size class.
  static double get m3Margin => isCompact ? 16.0 : 24.0;

  /// Standard M3 Spacer between panes (usually 24dp).
  static double get m3Spacer => 24.0;

  /// Returns padding in M3 recommended 4dp increments.
  /// Example: m3Padding(2) returns 8.0, m3Padding(4) returns 16.0
  static double m3Padding(int multiplier) => multiplier * 4.0;

  /// Standard M3 Minimum Interactive Target Size (48x48dp).
  static double get m3TargetSize => 48.0;

  /// Returns recommended VisualDensity based on window size.
  /// Desktop/Web often benefits from slightly higher density.
  static VisualDensity getVisualDensity(BuildContext context) {
    if (isExpanded) return const VisualDensity(horizontal: -1, vertical: -1);
    return VisualDensity.standard;
  }

  /// Recommended Max Width for a single pane of content (e.g. 840dp for expanded)
  static double get maxContentWidth => 1200.0;
  
  // ========== Material Design 3 Pane Layout Constants ==========
  
  /// Standard pane widths following M3 guidelines
  static const double paneMinWidth = 280.0;
  static const double paneStandardWidth = 360.0;
  static const double paneMaxWidth = 412.0;
  static const double sidesheetMaxWidth = 400.0;
  
  /// Pane spacer/divider width (24dp per M3 spec)
  static const double paneSpacer = 24.0;
  
  /// Drag handle dimensions
  static const double dragHandleWidth = 4.0;
  static const double dragHandleHeight = 48.0;
  
  /// Returns recommended fixed pane width based on window size class
  static double get recommendedFixedPaneWidth {
    if (isCompact) return 0; // No fixed pane on compact
    if (isMedium) return paneMinWidth; // 280dp
    if (isExpanded) return paneStandardWidth; // 360dp
    return paneMaxWidth; // 412dp for large/extra-large
  }
  /// Returns clear column count for responsive grids (2 for mobile, 4 for tablet/landscape)
  static int getResponsiveGridCount(BuildContext context) {
    if (isDesktop) return 5;
    if (isTabletOrLarger) return 4;
    double width = MediaQuery.of(context).size.width;
    if (width > 600) return 3; // Landscape Mobile
    return 2; // Portrait Mobile
  }
}

enum WindowSizeClass {
  compact,      // < 600dp (Mobile)
  medium,       // 600-839dp (Foldables/Small Tablets)
  expanded,     // 840-1239dp (Large Tablets)
  large,        // 1240-1599dp (Desktop)
  extraLarge,   // >= 1600dp (Ultra-wide Desktop)
}
