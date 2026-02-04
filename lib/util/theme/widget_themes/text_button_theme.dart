import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter/material.dart';

class AaliyahTextButtonTheme {
  AaliyahTextButtonTheme._();

  static final lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: aaliyahPrimaryColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(), // Consistent M3 Pill Shape for Hover/Focus ring
    ),
  );

  static final darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF4CDABD), // Light Teal for M3 Dark Mode
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
    ),
  );
}
