import 'package:flutter/material.dart';

class AaliyahDatePickerTheme {
  AaliyahDatePickerTheme._();

  static DatePickerThemeData datePickerTheme(ColorScheme colorScheme) {
    return DatePickerThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh, // M3 Token: Surface container high
      elevation: 0,
      
      // Header Roles
      headerBackgroundColor: colorScheme.surfaceContainerHigh,
      headerForegroundColor: colorScheme.onSurface,
      headerHeadlineStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.normal, letterSpacing: 0),
      headerHelpStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      
      // Day Selection Roles
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.onPrimary;
        if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.38);
        return colorScheme.onSurface;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return null;
      }),
      dayOverlayColor: WidgetStateProperty.all(colorScheme.primary.withValues(alpha: 0.1)),
      
      // Range Selection Roles (M3 spec: Secondary Container)
      rangeSelectionBackgroundColor: colorScheme.secondaryContainer,
      rangeSelectionOverlayColor: WidgetStateProperty.all(colorScheme.onSecondaryContainer.withValues(alpha: 0.1)),
      rangePickerHeaderBackgroundColor: colorScheme.surfaceContainerHigh,
      rangePickerHeaderForegroundColor: colorScheme.onSurface,
      rangePickerHeaderHeadlineStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
      rangePickerHeaderHelpStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      rangePickerSurfaceTintColor: Colors.transparent,
      
      // Today roles
      todayForegroundColor: WidgetStateProperty.all(colorScheme.primary),
      todayBorder: BorderSide(color: colorScheme.primary),
      
      // Year Selection Roles
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.onPrimary;
        return colorScheme.onSurfaceVariant;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return null;
      }),
      
      // Shape & Divider
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      dividerColor: colorScheme.outlineVariant,
      
      // Text Styles
      dayStyle: const TextStyle(fontSize: 14),
      weekdayStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.normal),
      yearStyle: const TextStyle(fontSize: 16),
      
      // Modal Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.outline), borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2), borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
