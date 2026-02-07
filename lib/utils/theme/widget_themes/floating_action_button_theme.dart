import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter/material.dart';

/// M3 Expressive FAB & Extended FAB Specifications
/// 
/// === STANDARD FAB SIZES (M3 Expressive) ===
/// - FAB: 56dp (standard, recommended)
/// - Medium FAB: 80dp (new in M3 Expressive)  
/// - Large FAB: 96dp
/// - Small FAB: 40dp (DEPRECATED - no longer recommended)
/// 
/// === EXTENDED FAB SIZES ===
/// - Small Extended FAB: 56dp height (replaces deprecated original)
/// - Medium Extended FAB: 80dp height
/// - Large Extended FAB: 96dp height
/// 
/// === COMMON SPECS ===
/// - Container shape: 16dp corner radius (boxier style, not circular)
/// - Icon size: 24dp
/// - Leading space: 16dp
/// - Icon-label space: 8dp  
/// - Trailing space: 16dp
/// - Margins: 16dp from screen edges
/// 
/// === STATES ===
/// - Enabled: Elevation 3
/// - Hovered: Elevation 4
/// - Focused: Elevation 3 (with focus ring)
/// - Pressed: Elevation 3
/// 
/// === COLOR STYLES (M3 Expressive) ===
/// Tone colors (NEW):
/// - Primary, Secondary, Tertiary
/// Container colors (renamed):
/// - Primary container (default), Secondary container, Tertiary container
/// DEPRECATED: Surface color FABs

class AaliyahFloatingActionButtonTheme {
  AaliyahFloatingActionButtonTheme._();
  
  // === STANDARD FAB SIZES ===
  /// Standard FAB size: 56dp (recommended)
  static const double fabSize = 56.0;
  /// Medium FAB size: 80dp (NEW in M3 Expressive)
  static const double mediumFabSize = 80.0;
  /// Large FAB size: 96dp
  static const double largeFabSize = 96.0;
  /// Small FAB size: 40dp (DEPRECATED - do not use)
  @Deprecated('Small FAB is no longer recommended in M3 Expressive. Use standard FAB (56dp) instead.')
  static const double smallFabSize = 40.0;
  
  // === EXTENDED FAB SIZES ===
  /// Small Extended FAB: 56dp height (replaces deprecated original)
  static const double smallExtendedFabHeight = 56.0;
  /// Medium Extended FAB: 80dp height
  static const double mediumExtendedFabHeight = 80.0;
  /// Large Extended FAB: 96dp height
  static const double largeExtendedFabHeight = 96.0;
  
  // M3 Spec: Container shape 16dp corner radius (boxier, not circular)
  static const double fabCornerRadius = 16.0;
  
  // M3 Spec: Icon size 24dp
  static const double fabIconSize = 24.0;
  
  // M3 Spec: Spacing
  static const double fabLeadingSpace = 16.0;
  static const double fabIconLabelSpace = 8.0;
  static const double fabTrailingSpace = 16.0;
  static const double fabMargin = 16.0;

  static final lightFloatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: aaliyahPrimaryColor, // Primary container for default
    foregroundColor: Colors.white, // OnPrimaryContainer
    splashColor: Colors.white.withValues(alpha: 0.12),
    elevation: 3, // M3 Enabled state
    focusElevation: 3, // Same as enabled, focus ring provides feedback
    hoverElevation: 4, // M3 Hovered state
    highlightElevation: 3, // M3 Pressed state
    // M3 Expressive: Boxier shape with 16dp corner radius
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(fabCornerRadius)),
    ),
    // M3 Expressive: Small Extended FAB height (56dp)
    extendedSizeConstraints: const BoxConstraints.tightFor(height: smallExtendedFabHeight),
    // M3 Spec: Leading 16dp, trailing 16dp (icon-label space handled by child)
    extendedPadding: const EdgeInsetsDirectional.only(
      start: fabLeadingSpace, 
      end: fabTrailingSpace,
    ),
    extendedIconLabelSpacing: fabIconLabelSpace, // 8dp between icon and label
    extendedTextStyle: const TextStyle(
      fontSize: 16, // Title Medium for M3 Expressive small
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    iconSize: fabIconSize,
  );

  static final darkFloatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF4CDABD), // Primary container (Dark Mode)
    foregroundColor: const Color(0xFF003731), // OnPrimaryContainer (Dark Mode)
    splashColor: const Color(0xFF003731).withValues(alpha: 0.12),
    elevation: 3,
    focusElevation: 3,
    hoverElevation: 4,
    highlightElevation: 3,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(fabCornerRadius)),
    ),
    extendedSizeConstraints: const BoxConstraints.tightFor(height: smallExtendedFabHeight),
    extendedPadding: const EdgeInsetsDirectional.only(
      start: fabLeadingSpace, 
      end: fabTrailingSpace,
    ),
    extendedIconLabelSpacing: fabIconLabelSpace,
    extendedTextStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    iconSize: fabIconSize,
  );
  
  // Dynamic Theme - uses ColorScheme for M3 compliance
  static FloatingActionButtonThemeData floatingActionButtonTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer, // M3 Default color mapping
      foregroundColor: colorScheme.onPrimaryContainer,
      splashColor: colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
      elevation: 3,
      focusElevation: 3,
      hoverElevation: 4,
      highlightElevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(fabCornerRadius)),
      ),
      extendedSizeConstraints: const BoxConstraints.tightFor(height: smallExtendedFabHeight),
      extendedPadding: const EdgeInsetsDirectional.only(
        start: fabLeadingSpace, 
        end: fabTrailingSpace,
      ),
      extendedIconLabelSpacing: fabIconLabelSpace,
      extendedTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onPrimaryContainer,
      ), 
      iconSize: fabIconSize,
    );
  }
  
  /// Creates a custom Extended FAB theme for a specific size
  /// 
  /// [size] - One of: small (56dp), medium (80dp), large (96dp)
  static FloatingActionButtonThemeData forSize(
    ColorScheme colorScheme, 
    ExtendedFabSize size,
  ) {
    final double height = switch (size) {
      ExtendedFabSize.small => smallExtendedFabHeight,
      ExtendedFabSize.medium => mediumExtendedFabHeight,
      ExtendedFabSize.large => largeExtendedFabHeight,
    };
    
    // Typography scales with size per M3 Expressive
    final double fontSize = switch (size) {
      ExtendedFabSize.small => 16.0, // Title Medium
      ExtendedFabSize.medium => 18.0, // Title Large
      ExtendedFabSize.large => 22.0, // Headline Small
    };
    
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      splashColor: colorScheme.onPrimaryContainer.withValues(alpha: 0.10), // M3: 10% pressed
      elevation: 3,
      focusElevation: 3,
      hoverElevation: 4,
      highlightElevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(fabCornerRadius)),
      ),
      extendedSizeConstraints: BoxConstraints.tightFor(height: height),
      extendedPadding: const EdgeInsetsDirectional.only(
        start: fabLeadingSpace, 
        end: fabTrailingSpace,
      ),
      extendedIconLabelSpacing: fabIconLabelSpace,
      extendedTextStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onPrimaryContainer,
      ),
      iconSize: fabIconSize,
    );
  }
  
  /// Creates a FAB theme with a specific color style
  /// 
  /// M3 Expressive color styles:
  /// - Container colors (default): primaryContainer, secondaryContainer, tertiaryContainer
  /// - Tone colors (NEW): primary, secondary, tertiary
  static FloatingActionButtonThemeData withColorStyle(
    ColorScheme colorScheme,
    FabColorStyle colorStyle,
  ) {
    final (Color bg, Color fg) = switch (colorStyle) {
      // Container colors (default in M3)
      FabColorStyle.primaryContainer => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      FabColorStyle.secondaryContainer => (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
      FabColorStyle.tertiaryContainer => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      // Tone colors (NEW in M3 Expressive)
      FabColorStyle.primary => (colorScheme.primary, colorScheme.onPrimary),
      FabColorStyle.secondary => (colorScheme.secondary, colorScheme.onSecondary),
      FabColorStyle.tertiary => (colorScheme.tertiary, colorScheme.onTertiary),
    };
    
    return FloatingActionButtonThemeData(
      backgroundColor: bg,
      foregroundColor: fg,
      splashColor: fg.withValues(alpha: 0.10), // M3: 10% pressed state layer
      elevation: 3,
      focusElevation: 3,
      hoverElevation: 4,
      highlightElevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(fabCornerRadius)),
      ),
      extendedSizeConstraints: const BoxConstraints.tightFor(height: smallExtendedFabHeight),
      extendedPadding: const EdgeInsetsDirectional.only(
        start: fabLeadingSpace, 
        end: fabTrailingSpace,
      ),
      extendedIconLabelSpacing: fabIconLabelSpace,
      extendedTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: fg,
      ),
      iconSize: fabIconSize,
    );
  }
}

/// M3 Expressive Extended FAB sizes
enum ExtendedFabSize {
  /// Small: 56dp height (replaces deprecated original Extended FAB)
  small,
  /// Medium: 80dp height
  medium,
  /// Large: 96dp height
  large,
}

/// M3 Expressive FAB color styles
/// 
/// Container colors use the container/onContainer color pairs (default)
/// Tone colors use the base/on color pairs (NEW in M3 Expressive)
enum FabColorStyle {
  /// Primary container & On primary container (default)
  primaryContainer,
  /// Secondary container & On secondary container
  secondaryContainer,
  /// Tertiary container & On tertiary container
  tertiaryContainer,
  /// Primary & On primary (NEW in M3 Expressive)
  primary,
  /// Secondary & On secondary (NEW in M3 Expressive)
  secondary,
  /// Tertiary & On tertiary (NEW in M3 Expressive)
  tertiary,
}
