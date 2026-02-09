import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';

class AaliyahListTileTheme {
  AaliyahListTileTheme._();

  static ListTileThemeData listTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(

      tileColor: Colors.transparent,
      selectedTileColor: colorScheme.secondaryContainer.withValues(alpha: 0.5),
      selectedColor: colorScheme.onSecondaryContainer,
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium), // 12dp
      ),
      

      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      

      titleAlignment: ListTileTitleAlignment.center,
      

      visualDensity: VisualDensity.standard,
      enableFeedback: true,
      mouseCursor: WidgetStateProperty.resolveWith<MouseCursor?>((states) {
        if (states.contains(WidgetState.disabled)) return SystemMouseCursors.basic;
        return SystemMouseCursors.click;
      }),
      
   
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600, 
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
