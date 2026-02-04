import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter/material.dart';

// Light and Dark Outlined Button Theme

class AaliyahOutlinedButtonTheme {
  AaliyahOutlinedButtonTheme._();

  // Light Theme

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: aaliyahPrimaryColor,
      side: const BorderSide(color: aaliyahPrimaryColor, width: 2),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: aaliyahPrimaryColor),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      shape: const StadiumBorder(), // M3 Pill Shape
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF4CDABD), // Match Primary Light
      side: const BorderSide(color: Color(0xFF4CDABD), width: 2),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4CDABD)),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      shape: const StadiumBorder(), // M3 Pill Shape
    ),
  );
}
