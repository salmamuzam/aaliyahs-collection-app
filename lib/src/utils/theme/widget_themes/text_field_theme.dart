import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
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
    border: OutlineInputBorder(),
    prefixIconColor: aaliyahSecondaryColor,
    floatingLabelStyle: TextStyle(color: aaliyahSecondaryColor),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: aaliyahSecondaryColor),
    ),
  );
}
