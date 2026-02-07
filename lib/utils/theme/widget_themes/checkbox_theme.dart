import 'package:flutter/material.dart';


class AaliyahCheckboxTheme {
  AaliyahCheckboxTheme._();

  static CheckboxThemeData checkboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        if (states.contains(WidgetState.error)) {
          return colorScheme.error;
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null; // Transparent / Border only
      }),
      checkColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.surface.withValues(alpha: 0.38);
        }
        return colorScheme.onPrimary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.primary.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.primary.withValues(alpha: 0.1);
        }
        return null;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2), // M3 Spec: 2dp corner shape
      ),
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.38));
        }
        if (states.contains(WidgetState.error)) {
          return BorderSide(color: colorScheme.error, width: 2);
        }
        if (states.contains(WidgetState.selected)) {
          return BorderSide(color: colorScheme.primary);
        }
        return BorderSide(color: colorScheme.onSurfaceVariant); // M3 Spec: On-surface-variant for unselected
      }),
    );
  }
}
