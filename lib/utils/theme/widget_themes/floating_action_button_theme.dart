import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter/material.dart';


class AaliyahFloatingActionButtonTheme {
  AaliyahFloatingActionButtonTheme._();
  

  static const double fabSize = 56.0;

  static const double mediumFabSize = 80.0;

  static const double largeFabSize = 96.0;

  @Deprecated('Small FAB is no longer recommended.')
  static const double smallFabSize = 40.0;
  

  static const double smallExtendedFabHeight = 56.0;

  static const double mediumExtendedFabHeight = 80.0;

  static const double largeExtendedFabHeight = 96.0;
  

  static const double fabCornerRadius = 16.0;
  

  static const double fabIconSize = 24.0;
  

  static const double fabLeadingSpace = 16.0;
  static const double fabIconLabelSpace = 8.0;
  static const double fabTrailingSpace = 16.0;
  static const double fabMargin = 16.0;

  static final lightFloatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: aaliyahPrimaryColor, 
    foregroundColor: Colors.white, 
    splashColor: Colors.white.withValues(alpha: 0.12),
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

  static final darkFloatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF4CDABD),
    foregroundColor: const Color(0xFF003731), 
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
  

  static FloatingActionButtonThemeData floatingActionButtonTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer, 
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
  
 
  static FloatingActionButtonThemeData forSize(
    ColorScheme colorScheme, 
    ExtendedFabSize size,
  ) {
    final double height = switch (size) {
      ExtendedFabSize.small => smallExtendedFabHeight,
      ExtendedFabSize.medium => mediumExtendedFabHeight,
      ExtendedFabSize.large => largeExtendedFabHeight,
    };
    
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
  

  static FloatingActionButtonThemeData withColorStyle(
    ColorScheme colorScheme,
    FabColorStyle colorStyle,
  ) {
    final (Color bg, Color fg) = switch (colorStyle) {
 
      FabColorStyle.primaryContainer => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      FabColorStyle.secondaryContainer => (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
      FabColorStyle.tertiaryContainer => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
  
      FabColorStyle.primary => (colorScheme.primary, colorScheme.onPrimary),
      FabColorStyle.secondary => (colorScheme.secondary, colorScheme.onSecondary),
      FabColorStyle.tertiary => (colorScheme.tertiary, colorScheme.onTertiary),
    };
    
    return FloatingActionButtonThemeData(
      backgroundColor: bg,
      foregroundColor: fg,
      splashColor: fg.withValues(alpha: 0.10), 
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


enum ExtendedFabSize {

  small,

  medium,

  large,
}


enum FabColorStyle {

  primaryContainer,

  secondaryContainer,

  tertiaryContainer,
  
  primary,

  secondary,

  tertiary,
}
