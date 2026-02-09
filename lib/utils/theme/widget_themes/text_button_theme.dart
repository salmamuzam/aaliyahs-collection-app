import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class AaliyahTextButtonTheme {
  AaliyahTextButtonTheme._();

  static final lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: aaliyahPrimaryColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
    ),
  );

  static final darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF4CDABD), 
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
    ),
  );
}
