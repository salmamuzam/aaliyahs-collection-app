import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/util/theme/widget_themes/filled_button_theme.dart';
import 'package:aaliyahs_collection_estore/util/theme/widget_themes/text_button_theme.dart';
import 'package:aaliyahs_collection_estore/util/theme/widget_themes/app_bar_theme.dart';
import 'package:aaliyahs_collection_estore/util/theme/widget_themes/elevated_button_theme.dart';
import 'package:aaliyahs_collection_estore/util/theme/widget_themes/outlined_button_theme.dart';
import 'package:aaliyahs_collection_estore/util/theme/widget_themes/text_field_theme.dart';
import 'package:aaliyahs_collection_estore/util/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';

class AaliyahAppTheme {
  AaliyahAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: aaliyahPrimaryColor,
    scaffoldBackgroundColor: aaliyahLightColor,
    textTheme: AaliyahTextTheme.lightTextTheme,
    appBarTheme: AaliyahAppBarTheme.lightAppBarTheme,
    outlinedButtonTheme: AaliyahOutlinedButtonTheme.lightOutlinedButtonTheme,
    elevatedButtonTheme: AaliyahElevatedButtonTheme.lightElevatedButtonTheme,
    filledButtonTheme: AaliyahFilledButtonTheme.lightFilledButtonTheme,
    textButtonTheme: AaliyahTextButtonTheme.lightTextButtonTheme,
    inputDecorationTheme: AaliyahTextFormFieldTheme.lightInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF006A60), // Refined Teal Seed for better tonal generation
      brightness: Brightness.light,
      primary: const Color(0xFF006A60),
      onPrimary: Colors.white,
      secondary: const Color(0xFF4A635F),
      tertiary: const Color(0xFF456179), // Muted Blue tertiary
      error: const Color(0xFFBA1A1A),
      surface: const Color(0xFFFBFDFA),
      surfaceTint: const Color(0xFF006A60), // Tint for elevation overlay
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: aaliyahPrimaryColor,
    scaffoldBackgroundColor: const Color(0xFF191C1B), // Dark Green-Grey Surface
    textTheme: AaliyahTextTheme.darkTextTheme,
    appBarTheme: AaliyahAppBarTheme.darkAppBarTheme,
    outlinedButtonTheme: AaliyahOutlinedButtonTheme.darkOutlinedButtonTheme,
    elevatedButtonTheme: AaliyahElevatedButtonTheme.darkElevatedButtonTheme,
    filledButtonTheme: AaliyahFilledButtonTheme.darkFilledButtonTheme,
    textButtonTheme: AaliyahTextButtonTheme.darkTextButtonTheme,
    inputDecorationTheme: AaliyahTextFormFieldTheme.darkInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF006A60),
      brightness: Brightness.dark,
      primary: const Color(0xFF4CDABD), // Lighter Teal for Dark Mode
      onPrimary: const Color(0xFF003731),
      secondary: const Color(0xFFB1CCC6),
      tertiary: const Color(0xFFAEC9E5),
      error: const Color(0xFFFFB4AB),
      surface: const Color(0xFF191C1B),
      surfaceTint: const Color(0xFF4CDABD),
    ),
  );
}
