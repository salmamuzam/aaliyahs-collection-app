import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class AaliyahChipTheme {
  AaliyahChipTheme._();

  static ChipThemeData chipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      elevation: 0,
      pressElevation: 0,
      surfaceTintColor: Colors.transparent,
      
      // M3: Rounded rectangle shape (standardized to 8dp per M3 guidelines)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusSmall),
        side: BorderSide(
          color: colorScheme.outline, // Default for most chips (Assist, Filter, Suggestion)
        ),
      ),

      // Label Styling: M3 Label Large/Medium
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant, // M3 Default for most chips
      ),
      secondaryLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSecondaryContainer,
      ),

      // Color Mappings
      backgroundColor: Colors.transparent,
      selectedColor: colorScheme.secondaryContainer,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
      brightness: colorScheme.brightness,
      
      // M3 Measurements: 32dp height is achieved through vertical padding + label height
      // Horizontal: 8dp Padding + 8dp LabelPadding = 16dp (Standard without icon)
      // When icon is present: 8dp Padding (Edge to Icon) + 8dp LabelPadding (Icon to Label) = 8dp spacing
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),

      // Icon Colors & Sizes (Standard M3: 18dp)
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
      secondarySelectedColor: colorScheme.secondaryContainer,
      
      // Selected State Border & Checkmark
      showCheckmark: true,
      checkmarkColor: colorScheme.onSecondaryContainer,
    );
  }
}
