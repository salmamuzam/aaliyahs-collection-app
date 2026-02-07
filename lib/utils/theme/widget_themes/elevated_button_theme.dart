import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter/material.dart';

// Light and Dark Elevated Button Theme

class AaliyahElevatedButtonTheme {
  AaliyahElevatedButtonTheme._();

  // Light Theme

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 1,
      foregroundColor: Colors.white,
      backgroundColor: aaliyahPrimaryColor, // High contrast against light surface
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      shape: const StadiumBorder(), // M3 Pill Shape
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 1,
      foregroundColor: aaliyahDarkColor, // Dark text on light button
      backgroundColor: aaliyahLightColor, // High contrast against dark surface
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: aaliyahDarkColor),
      shape: const StadiumBorder(), // M3 Pill Shape
    ),
  );
}
