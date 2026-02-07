
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AALIYAH TYPOGRAPHY - Material Design 3 Expressive Type System
/// 
/// Updated with Typesetting & Readability Standards (May 2025):
/// - Large Type (Display, Headline, Title): 1.2 Height Ratio
/// - Small Type (Body, Label): 1.5 Height Ratio
/// - Fallback: Roboto Flex -> Roboto -> Noto Sans
class AaliyahTypography extends ThemeExtension<AaliyahTypography> {
  static final List<String> _fontFallback = ['Roboto', 'Noto Sans'];

  // Emphasized Styles (High-impact weights for highlighted moments)
  final TextStyle displayLargeEmphasized;
  final TextStyle displayMediumEmphasized;
  final TextStyle displaySmallEmphasized;
  
  final TextStyle headlineLargeEmphasized;
  final TextStyle headlineMediumEmphasized;
  final TextStyle headlineSmallEmphasized;

  final TextStyle titleLargeEmphasized;
  final TextStyle titleMediumEmphasized;
  final TextStyle titleSmallEmphasized;

  final TextStyle bodyLargeEmphasized;
  final TextStyle bodyMediumEmphasized;
  final TextStyle bodySmallEmphasized;

  final TextStyle labelLargeEmphasized;
  final TextStyle labelMediumEmphasized;
  final TextStyle labelSmallEmphasized;

  // Editorial Treatments (Showcase moments using variable axes: Width, Grade)
  final TextStyle editorialLarge;
  final TextStyle editorialMedium;
  final TextStyle editorialSmall;

  AaliyahTypography({
    required this.displayLargeEmphasized,
    required this.displayMediumEmphasized,
    required this.displaySmallEmphasized,
    required this.headlineLargeEmphasized,
    required this.headlineMediumEmphasized,
    required this.headlineSmallEmphasized,
    required this.titleLargeEmphasized,
    required this.titleMediumEmphasized,
    required this.titleSmallEmphasized,
    required this.bodyLargeEmphasized,
    required this.bodyMediumEmphasized,
    required this.bodySmallEmphasized,
    required this.labelLargeEmphasized,
    required this.labelMediumEmphasized,
    required this.labelSmallEmphasized,
    required this.editorialLarge,
    required this.editorialMedium,
    required this.editorialSmall,
  });

  @override
  ThemeExtension<AaliyahTypography> copyWith({
    TextStyle? displayLargeEmphasized,
    TextStyle? displayMediumEmphasized,
    TextStyle? displaySmallEmphasized,
    TextStyle? headlineLargeEmphasized,
    TextStyle? headlineMediumEmphasized,
    TextStyle? headlineSmallEmphasized,
    TextStyle? titleLargeEmphasized,
    TextStyle? titleMediumEmphasized,
    TextStyle? titleSmallEmphasized,
    TextStyle? bodyLargeEmphasized,
    TextStyle? bodyMediumEmphasized,
    TextStyle? bodySmallEmphasized,
    TextStyle? labelLargeEmphasized,
    TextStyle? labelMediumEmphasized,
    TextStyle? labelSmallEmphasized,
    TextStyle? editorialLarge,
    TextStyle? editorialMedium,
    TextStyle? editorialSmall,
  }) {
    return AaliyahTypography(
      displayLargeEmphasized: displayLargeEmphasized ?? this.displayLargeEmphasized,
      displayMediumEmphasized: displayMediumEmphasized ?? this.displayMediumEmphasized,
      displaySmallEmphasized: displaySmallEmphasized ?? this.displaySmallEmphasized,
      headlineLargeEmphasized: headlineLargeEmphasized ?? this.headlineLargeEmphasized,
      headlineMediumEmphasized: headlineMediumEmphasized ?? this.headlineMediumEmphasized,
      headlineSmallEmphasized: headlineSmallEmphasized ?? this.headlineSmallEmphasized,
      titleLargeEmphasized: titleLargeEmphasized ?? this.titleLargeEmphasized,
      titleMediumEmphasized: titleMediumEmphasized ?? this.titleMediumEmphasized,
      titleSmallEmphasized: titleSmallEmphasized ?? this.titleSmallEmphasized,
      bodyLargeEmphasized: bodyLargeEmphasized ?? this.bodyLargeEmphasized,
      bodyMediumEmphasized: bodyMediumEmphasized ?? this.bodyMediumEmphasized,
      bodySmallEmphasized: bodySmallEmphasized ?? this.bodySmallEmphasized,
      labelLargeEmphasized: labelLargeEmphasized ?? this.labelLargeEmphasized,
      labelMediumEmphasized: labelMediumEmphasized ?? this.labelMediumEmphasized,
      labelSmallEmphasized: labelSmallEmphasized ?? this.labelSmallEmphasized,
      editorialLarge: editorialLarge ?? this.editorialLarge,
      editorialMedium: editorialMedium ?? this.editorialMedium,
      editorialSmall: editorialSmall ?? this.editorialSmall,
    );
  }

  @override
  ThemeExtension<AaliyahTypography> lerp(ThemeExtension<AaliyahTypography>? other, double t) {
    if (other is! AaliyahTypography) return this;
    return AaliyahTypography(
      displayLargeEmphasized: TextStyle.lerp(displayLargeEmphasized, other.displayLargeEmphasized, t)!,
      displayMediumEmphasized: TextStyle.lerp(displayMediumEmphasized, other.displayMediumEmphasized, t)!,
      displaySmallEmphasized: TextStyle.lerp(displaySmallEmphasized, other.displaySmallEmphasized, t)!,
      headlineLargeEmphasized: TextStyle.lerp(headlineLargeEmphasized, other.headlineLargeEmphasized, t)!,
      headlineMediumEmphasized: TextStyle.lerp(headlineMediumEmphasized, other.headlineMediumEmphasized, t)!,
      headlineSmallEmphasized: TextStyle.lerp(headlineSmallEmphasized, other.headlineSmallEmphasized, t)!,
      titleLargeEmphasized: TextStyle.lerp(titleLargeEmphasized, other.titleLargeEmphasized, t)!,
      titleMediumEmphasized: TextStyle.lerp(titleMediumEmphasized, other.titleMediumEmphasized, t)!,
      titleSmallEmphasized: TextStyle.lerp(titleSmallEmphasized, other.titleSmallEmphasized, t)!,
      bodyLargeEmphasized: TextStyle.lerp(bodyLargeEmphasized, other.bodyLargeEmphasized, t)!,
      bodyMediumEmphasized: TextStyle.lerp(bodyMediumEmphasized, other.bodyMediumEmphasized, t)!,
      bodySmallEmphasized: TextStyle.lerp(bodySmallEmphasized, other.bodySmallEmphasized, t)!,
      labelLargeEmphasized: TextStyle.lerp(labelLargeEmphasized, other.labelLargeEmphasized, t)!,
      labelMediumEmphasized: TextStyle.lerp(labelMediumEmphasized, other.labelMediumEmphasized, t)!,
      labelSmallEmphasized: TextStyle.lerp(labelSmallEmphasized, other.labelSmallEmphasized, t)!,
      editorialLarge: TextStyle.lerp(editorialLarge, other.editorialLarge, t)!,
      editorialMedium: TextStyle.lerp(editorialMedium, other.editorialMedium, t)!,
      editorialSmall: TextStyle.lerp(editorialSmall, other.editorialSmall, t)!,
    );
  }

  /// Helper to generate the emphasized style set
  static AaliyahTypography generateExtension(Color color, bool isDark) {
    return AaliyahTypography(
      // Display: 1.2 Height
      displayLargeEmphasized: GoogleFonts.robotoFlex(fontSize: 57, fontWeight: FontWeight.w900, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      displayMediumEmphasized: GoogleFonts.robotoFlex(fontSize: 45, fontWeight: FontWeight.w900, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      displaySmallEmphasized: GoogleFonts.robotoFlex(fontSize: 36, fontWeight: FontWeight.w800, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      
      // Headline: 1.2 Height
      headlineLargeEmphasized: GoogleFonts.robotoFlex(fontSize: 32, fontWeight: FontWeight.w800, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      headlineMediumEmphasized: GoogleFonts.robotoFlex(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      headlineSmallEmphasized: GoogleFonts.robotoFlex(fontSize: 24, fontWeight: FontWeight.w800, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      
      // Title: 1.2 Height
      titleLargeEmphasized: GoogleFonts.robotoFlex(fontSize: 22, fontWeight: FontWeight.w700, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      titleMediumEmphasized: GoogleFonts.robotoFlex(fontSize: 16, fontWeight: FontWeight.w700, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      titleSmallEmphasized: GoogleFonts.robotoFlex(fontSize: 14, fontWeight: FontWeight.w700, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      
      // Body: 1.5 Height
      bodyLargeEmphasized: GoogleFonts.robotoFlex(fontSize: 16, fontWeight: FontWeight.w600, color: color, height: 1.5).copyWith(fontFamilyFallback: _fontFallback),
      bodyMediumEmphasized: GoogleFonts.robotoFlex(fontSize: 14, fontWeight: FontWeight.w600, color: color, height: 1.5).copyWith(fontFamilyFallback: _fontFallback),
      bodySmallEmphasized: GoogleFonts.robotoFlex(fontSize: 12, fontWeight: FontWeight.w600, color: color, height: 1.5).copyWith(fontFamilyFallback: _fontFallback),
      
      // Label: 1.5 Height
      labelLargeEmphasized: GoogleFonts.robotoFlex(fontSize: 14, fontWeight: FontWeight.w700, color: color, height: 1.5, letterSpacing: 0.1).copyWith(fontFamilyFallback: _fontFallback),
      labelMediumEmphasized: GoogleFonts.robotoFlex(fontSize: 12, fontWeight: FontWeight.w700, color: color, height: 1.5, letterSpacing: 0.5).copyWith(fontFamilyFallback: _fontFallback),
      labelSmallEmphasized: GoogleFonts.robotoFlex(fontSize: 11, fontWeight: FontWeight.w700, color: color, height: 1.5, letterSpacing: 0.5).copyWith(fontFamilyFallback: _fontFallback),
      
      // Editorial Treatments: Wide Width (150) + High Grade (150) + Bold
      editorialLarge: GoogleFonts.robotoFlex(
        fontSize: 32, 
        color: color, 
        height: 1.2, 
        textStyle: const TextStyle(
          fontVariations: [
            FontVariation('wdth', 150), // Wide
            FontVariation('wght', 800), // ExtraBold
            FontVariation('GRAD', 150), // High Grade
          ],
        ),
      ).copyWith(fontFamilyFallback: _fontFallback),
      editorialMedium: GoogleFonts.robotoFlex(
        fontSize: 24, 
        color: color, 
        height: 1.2, 
        textStyle: const TextStyle(
          fontVariations: [
            FontVariation('wdth', 125), // Semi-Wide
            FontVariation('wght', 700), // Bold
            FontVariation('GRAD', 50),  // Medium Grade
          ],
        ),
      ).copyWith(fontFamilyFallback: _fontFallback),
      editorialSmall: GoogleFonts.robotoFlex(
        fontSize: 18, 
        color: color, 
        height: 1.2, 
        textStyle: const TextStyle(
          fontVariations: [
            FontVariation('wdth', 110), // Slight Width
            FontVariation('wght', 600), // SemiBold
          ],
        ),
      ).copyWith(fontFamilyFallback: _fontFallback),
    );
  }
}

class AaliyahTextTheme {
  AaliyahTextTheme._();

  static final List<String> _fontFallback = ['Roboto', 'Noto Sans'];

  static TextTheme generateTextTheme(Color color) {
    return TextTheme(
      // Display: 1.2 Height
      displayLarge: GoogleFonts.robotoFlex(fontSize: 57, fontWeight: FontWeight.w300, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      displayMedium: GoogleFonts.robotoFlex(fontSize: 45, fontWeight: FontWeight.w400, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      displaySmall: GoogleFonts.robotoFlex(fontSize: 36, fontWeight: FontWeight.w400, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      
      // Headline: 1.2 Height
      headlineLarge: GoogleFonts.robotoFlex(fontSize: 32, fontWeight: FontWeight.w400, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      headlineMedium: GoogleFonts.robotoFlex(fontSize: 28, fontWeight: FontWeight.w400, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      headlineSmall: GoogleFonts.robotoFlex(fontSize: 24, fontWeight: FontWeight.w400, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),

      // Title: 1.2 Height
      titleLarge: GoogleFonts.robotoFlex(fontSize: 22, fontWeight: FontWeight.w500, color: color, height: 1.2).copyWith(fontFamilyFallback: _fontFallback),
      titleMedium: GoogleFonts.robotoFlex(fontSize: 16, fontWeight: FontWeight.w500, color: color, height: 1.2, letterSpacing: 0.15).copyWith(fontFamilyFallback: _fontFallback),
      titleSmall: GoogleFonts.robotoFlex(fontSize: 14, fontWeight: FontWeight.w500, color: color, height: 1.2, letterSpacing: 0.1).copyWith(fontFamilyFallback: _fontFallback),

      // Body: 1.5 Height for optimal readability
      bodyLarge: GoogleFonts.robotoSerif(fontSize: 16, fontWeight: FontWeight.w400, color: color, height: 1.5, letterSpacing: 0.5).copyWith(fontFamilyFallback: _fontFallback),
      bodyMedium: GoogleFonts.robotoSerif(fontSize: 14, fontWeight: FontWeight.w400, color: color, height: 1.5, letterSpacing: 0.25).copyWith(fontFamilyFallback: _fontFallback),
      bodySmall: GoogleFonts.robotoSerif(fontSize: 12, fontWeight: FontWeight.w400, color: color.withValues(alpha: 0.8), height: 1.5, letterSpacing: 0.4).copyWith(fontFamilyFallback: _fontFallback),

      // Label: 1.5 Height
      labelLarge: GoogleFonts.robotoFlex(fontSize: 14, fontWeight: FontWeight.w500, color: color, height: 1.5, letterSpacing: 0.1).copyWith(fontFamilyFallback: _fontFallback),
      labelMedium: GoogleFonts.robotoFlex(fontSize: 12, fontWeight: FontWeight.w500, color: color, height: 1.5, letterSpacing: 0.5).copyWith(fontFamilyFallback: _fontFallback),
      labelSmall: GoogleFonts.robotoFlex(fontSize: 11, fontWeight: FontWeight.w500, color: color, height: 1.5, letterSpacing: 0.5).copyWith(fontFamilyFallback: _fontFallback),
    );
  }
}
