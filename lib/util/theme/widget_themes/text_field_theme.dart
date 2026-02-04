import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter/material.dart';

// Light and Dark Text Theme

class AaliyahTextFormFieldTheme {
  AaliyahTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(),
    prefixIconColor: aaliyahPrimaryColor,
    floatingLabelStyle: TextStyle(color: aaliyahPrimaryColor),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: aaliyahPrimaryColor),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    border: const OutlineInputBorder(),
    prefixIconColor: const Color(0xFF4CDABD), // Light Teal
    floatingLabelStyle: const TextStyle(color: Color(0xFF4CDABD)),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Color(0xFF4CDABD)),
    ),
  );
}
