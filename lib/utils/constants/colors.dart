import 'package:flutter/material.dart';

// List of all colors

const aaliyahPrimaryColor = Color(0xFF004D61);
const aaliyahSecondaryColor = Color(0xFF822659);

const aaliyahLightColor = Color(0xFFF0F0F0);
const aaliyahDarkColor = Color(0xFF1A1A1A);

// === SHIMMER COLORS ===
/// Shimmer base color for loading placeholders
const aaliyahShimmerBaseColor = Color(0xFFE0E0E0);
/// Shimmer highlight color for loading placeholders
const aaliyahShimmerHighlightColor = Color(0xFFF5F5F5);
/// Dark mode shimmer base color
const aaliyahShimmerBaseColorDark = Color(0xFF2A2A2A);
/// Dark mode shimmer highlight color
const aaliyahShimmerHighlightColorDark = Color(0xFF3A3A3A);

// === COMMON UI COLORS ===
/// Dark slate color for text on light backgrounds
const aaliyahDarkSlateColor = Color(0xFF0F172A);
/// Light background color (used in screens)
const aaliyahLightBackgroundColor = Color(0xFFF8F9FA);
/// Light text color for dark mode
const aaliyahLightTextOnDark = Color(0xFFE5EDEF);

// This is a class I created to store colors for the Checkout Screen
class CheckoutColors {
  final bool isDarkMode;

  CheckoutColors(this.isDarkMode);

  Color get primaryColor => aaliyahPrimaryColor;
  Color get secondaryColor => aaliyahSecondaryColor;
  Color get backgroundColor =>
      isDarkMode ? aaliyahDarkColor : aaliyahLightColor;
  Color get textColor => isDarkMode ? aaliyahLightColor : aaliyahDarkColor;
  Color get surfaceColor => isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8F5F2);
  Color get borderColor => isDarkMode ? const Color(0xFF555555) : const Color(0xFFE0D6CC);
  Color get successColor => Colors.green;
}
