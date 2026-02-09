import 'package:flutter/material.dart';

class DeviceUtils {

  static num figmaDesignWidth = 360;
  static num figmaDesignHeight = 812;
  
  static num _width = 0;
  static num _height = 0;


  void adaptDeviceScreenSize(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _width = size.width;
    _height = size.height;
  }

  static double getScaleFactor() {
    double scaleWidth = _width / figmaDesignWidth;
    double scaleHeight = _height / figmaDesignHeight;
  
    return scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
  }

  static double get width => _width * 1.0;
  static double get height => _height * 1.0;


  static double getSafeHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }


  static double getHorizontalSize(double px) {
    return ((px * width) / figmaDesignWidth);
  }


  static double getVerticalSize(double px) {
    return ((px * height) / figmaDesignHeight);
  }


  static double getSize(double px) {
    return px * getScaleFactor();
  }


  static double getFontSize(double px) {
    return (px * _width / figmaDesignWidth).clamp(8.0, 40.0);
  }


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
  

  static bool get isTabletOrLarger => _width >= 840;
  

  static bool get isDesktop => _width >= 1240;


  static double get m3Margin => isCompact ? 16.0 : 24.0;


  static double get m3Spacer => 24.0;


  static double m3Padding(int multiplier) => getVerticalSize(multiplier * 4.0);


  static double m3HSpace(int multiplier) => getHorizontalSize(multiplier * 4.0);

  static double get m3TargetSize => 48.0;

  static VisualDensity getVisualDensity(BuildContext context) {
    if (isExpanded) return const VisualDensity(horizontal: -1, vertical: -1);
    return VisualDensity.standard;
  }


  static double get maxContentWidth => 1200.0;

  static const double paneMinWidth = 280.0;
  static const double paneStandardWidth = 360.0;
  static const double paneMaxWidth = 412.0;
  static const double sidesheetMaxWidth = 400.0;
  
 
  static const double paneSpacer = 24.0;
  

  static const double dragHandleWidth = 4.0;
  static const double dragHandleHeight = 48.0;
  

  static double get recommendedFixedPaneWidth {
    if (isCompact) return 0; 
    if (isMedium) return paneMinWidth; 
    if (isExpanded) return paneStandardWidth; 
    return paneMaxWidth; 
  }

  static int getResponsiveGridCount(BuildContext context) {
    if (isDesktop) return 5;
    if (isTabletOrLarger) return 4;
    double width = MediaQuery.of(context).size.width;
    if (width > 600) return 3; 
    return 2; 
  }
}

enum WindowSizeClass {
  compact,    
  medium,       
  expanded,  
  large,       
  extraLarge, 
}
