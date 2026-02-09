import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class AaliyahFilledButtonTheme {
  AaliyahFilledButtonTheme._();

  static final lightFilledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: aaliyahPrimaryColor,
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
    ),
  );

  static final darkFilledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      foregroundColor: const Color(0xFF003731), 
      backgroundColor: const Color(0xFF4CDABD), 
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey.shade800,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(), 
    ),
  );
}
