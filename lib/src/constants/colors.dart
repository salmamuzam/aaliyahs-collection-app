import 'package:flutter/material.dart';

// List of all colors

const aaliyahPrimaryColor = Color(0xFF004D61);
const aaliyahSecondaryColor = Color(0xFF822659);

const aaliyahLightColor = Color(0xFFF0F0F0);
const aaliyahDarkColor = Color(0xFF1A1A1A);

// This is a class I created to store colors for the Checkout Screen
class CheckoutColors {
  final bool isDarkMode;

  CheckoutColors(this.isDarkMode);

  Color get primaryColor => aaliyahPrimaryColor;
  Color get secondaryColor => aaliyahSecondaryColor;
  Color get backgroundColor =>
      isDarkMode ? aaliyahDarkColor : aaliyahLightColor;
  Color get textColor => isDarkMode ? aaliyahLightColor : aaliyahDarkColor;
  Color get surfaceColor => isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFF8F5F2);
  Color get borderColor => isDarkMode ? Color(0xFF555555) : Color(0xFFE0D6CC);
  Color get successColor => Colors.green;
}
