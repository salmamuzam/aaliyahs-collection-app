import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light and Dark Text Theme

class AaliyahTextTheme {
  AaliyahTextTheme._();

  // Light Theme

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      color: aaliyahDarkColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      color: aaliyahDarkColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: aaliyahDarkColor,
    ),
  );

  // Dark Theme

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      color: aaliyahLightColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      color: aaliyahLightColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: aaliyahLightColor,
    ),
  );
}
