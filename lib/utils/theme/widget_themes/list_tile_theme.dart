import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';

class AaliyahListTileTheme {
  AaliyahListTileTheme._();

  static ListTileThemeData listTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      // M3 Color Mappings
      tileColor: Colors.transparent,
      selectedTileColor: colorScheme.secondaryContainer.withValues(alpha: 0.5),
      selectedColor: colorScheme.onSecondaryContainer,
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      
      // M3 Shape: Standardized at 12dp for rounded selection/hover
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium), // 12dp
      ),
      
      // M3 Content Padding: Standard 16dp horizontal
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      
      // M3 Alignment: Middle-aligned by default (M3 Baseline)
      titleAlignment: ListTileTitleAlignment.center,
      
      // Visual Density & Interaction
      visualDensity: VisualDensity.standard,
      enableFeedback: true,
      mouseCursor: WidgetStateProperty.resolveWith<MouseCursor?>((states) {
        if (states.contains(WidgetState.disabled)) return SystemMouseCursors.basic;
        return SystemMouseCursors.click;
      }),
      
      // Accessibility & States
      // Note: Focus and Hover colors are sometimes restricted in certain Flutter versions for ListTileThemeData
      
      // Text Styles: Mapping to M3 Baseline
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600, // titleMediumEmphasized
        color: colorScheme.onSurface,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 14,
        color: colorScheme.onSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: TextStyle(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
