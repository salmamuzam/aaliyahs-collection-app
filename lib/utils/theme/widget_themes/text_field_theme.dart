import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class AaliyahTextFormFieldTheme {
  AaliyahTextFormFieldTheme._();

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return Colors.transparent;
        if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.04);
        if (states.contains(WidgetState.hovered)) return colorScheme.onSurface.withValues(alpha: 0.08);
        
        return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
      }),
      
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      
      // Borders
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(TUIConstants.inputFieldRadius), borderSide: BorderSide(color: colorScheme.outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUIConstants.inputFieldRadius), borderSide: BorderSide(color: colorScheme.outline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUIConstants.inputFieldRadius), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUIConstants.inputFieldRadius), borderSide: BorderSide(color: colorScheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUIConstants.inputFieldRadius), borderSide: BorderSide(color: colorScheme.error, width: 2)),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TUIConstants.inputFieldRadius), borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.12))),
      
      // Label / Floating Label
      labelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return TextStyle(color: colorScheme.primary);
        if (states.contains(WidgetState.error)) return TextStyle(color: colorScheme.error);
        return TextStyle(color: colorScheme.onSurfaceVariant);
      }),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
         if (states.contains(WidgetState.error)) return TextStyle(color: colorScheme.error);
         if (states.contains(WidgetState.focused)) return TextStyle(color: colorScheme.primary);
         return TextStyle(color: colorScheme.onSurfaceVariant);
      }),
      
      // Icons
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,

      // Helper & Error Text
      helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      errorStyle: TextStyle(color: colorScheme.error),
      errorMaxLines: 2,
    );
  }


  static InputDecorationTheme lightInputDecorationTheme = const InputDecorationTheme(border: OutlineInputBorder());
  static InputDecorationTheme darkInputDecorationTheme = const InputDecorationTheme(border: OutlineInputBorder());
}
