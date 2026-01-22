import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:flutter/material.dart';

// Light and Dark Elevated Button Theme

class AaliyahElevatedButtonTheme {
  AaliyahElevatedButtonTheme._();

  // Light Theme

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(),
      foregroundColor: aaliyahSecondaryColor,
      backgroundColor: aaliyahPrimaryColor,
      side: BorderSide(color: aaliyahPrimaryColor),
      padding: EdgeInsets.symmetric(vertical: aaliyahButtonHeight),
    ),
  );

  // Dark Theme

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(),
      foregroundColor: aaliyahPrimaryColor,
      backgroundColor: aaliyahSecondaryColor,
      side: BorderSide(color: aaliyahSecondaryColor),
      padding: EdgeInsets.symmetric(vertical: aaliyahButtonHeight),
    ),
  );
}
