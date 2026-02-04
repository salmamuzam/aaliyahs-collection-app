import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light and Dark Text Theme

class AaliyahTextTheme {
  AaliyahTextTheme._();

  // Light Theme

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.normal, color: aaliyahDarkColor),
    displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.normal, color: aaliyahDarkColor),
    displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.normal, color: aaliyahDarkColor),
    
    headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: aaliyahDarkColor),
    headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: aaliyahDarkColor),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: aaliyahDarkColor),

    titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: aaliyahDarkColor),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: aaliyahDarkColor, letterSpacing: 0.15),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: aaliyahDarkColor, letterSpacing: 0.1),

    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal, color: aaliyahDarkColor, letterSpacing: 0.5),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal, color: aaliyahDarkColor, letterSpacing: 0.25),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, color: aaliyahDarkColor.withValues(alpha: 0.8), letterSpacing: 0.4),

    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: aaliyahDarkColor, letterSpacing: 0.1),
    labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: aaliyahDarkColor.withValues(alpha: 0.7), letterSpacing: 0.5),
    labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: aaliyahDarkColor.withValues(alpha: 0.6), letterSpacing: 0.5),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.normal, color: aaliyahLightColor),
    displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.normal, color: aaliyahLightColor),
    displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.normal, color: aaliyahLightColor),
    
    headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: aaliyahLightColor),
    headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: aaliyahLightColor),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: aaliyahLightColor),

    titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: aaliyahLightColor),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: aaliyahLightColor, letterSpacing: 0.15),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: aaliyahLightColor, letterSpacing: 0.1),

    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal, color: aaliyahLightColor, letterSpacing: 0.5),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal, color: aaliyahLightColor, letterSpacing: 0.25),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, color: aaliyahLightColor.withValues(alpha: 0.8), letterSpacing: 0.4),

    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: aaliyahLightColor, letterSpacing: 0.1),
    labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: aaliyahLightColor.withValues(alpha: 0.7), letterSpacing: 0.5),
    labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: aaliyahLightColor.withValues(alpha: 0.6), letterSpacing: 0.5),
  );
}
