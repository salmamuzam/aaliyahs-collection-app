import 'package:flutter/material.dart';

/// Battle-tested Screen utility class for pixel-perfect responsive design.
/// Bridges the gap between Figma designs and production Flutter code.
class DeviceUtils {
  // Figma design dimensions (Baseline truth)
  static num figmaDesignWidth = 360;
  static num figmaDesignHeight = 812;
  
  static num _width = 0;
  static num _height = 0;

  /// Initialize screen adaptation using current context.
  /// Call this in the build method or didChangeDependencies of your root widget.
  void adaptDeviceScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
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

  // Device Type Detection
  static bool get isTablet => _width > 600;
  static bool get isDesktop => _width > 1200;
  static bool get isMobile => _width <= 600;
}
