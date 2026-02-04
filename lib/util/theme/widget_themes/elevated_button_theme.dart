import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter/material.dart';

// Light and Dark Elevated Button Theme

class AaliyahElevatedButtonTheme {
  AaliyahElevatedButtonTheme._();

  // Light Theme

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: aaliyahPrimaryColor, // High contrast against light surface
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey,
      side: const BorderSide(color: aaliyahPrimaryColor),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      shape: const StadiumBorder(), // M3 Pill Shape
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: aaliyahDarkColor, // Dark text on light button
      backgroundColor: aaliyahLightColor, // High contrast against dark surface
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey,
      side: const BorderSide(color: aaliyahLightColor),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: aaliyahDarkColor),
      shape: const StadiumBorder(), // M3 Pill Shape
    ),
  );
}
