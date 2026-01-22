import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:flutter/material.dart';

// Light and Dark Outlined Button Theme

class AaliyahOutlinedButtonTheme {
  AaliyahOutlinedButtonTheme._();

  // Light Theme

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(),
      foregroundColor: aaliyahPrimaryColor,
      side: BorderSide(color: aaliyahPrimaryColor),
      padding: EdgeInsets.symmetric(vertical: aaliyahButtonHeight),
    ),
  );

  // Dark Theme

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(),
      foregroundColor: aaliyahSecondaryColor,
      side: BorderSide(color: aaliyahSecondaryColor),
      padding: EdgeInsets.symmetric(vertical: aaliyahButtonHeight),
    ),
  );
}
