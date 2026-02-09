import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter/material.dart';

// Light and Dark Outlined Button Theme

class AaliyahOutlinedButtonTheme {
  AaliyahOutlinedButtonTheme._();

  // Light Theme

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: aaliyahPrimaryColor,
      side: const BorderSide(color: aaliyahPrimaryColor),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: aaliyahPrimaryColor),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: const StadiumBorder(),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF4CDABD), 
      side: const BorderSide(color: Color(0xFF4CDABD)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4CDABD)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: const StadiumBorder(), 
    ),
  );
}
