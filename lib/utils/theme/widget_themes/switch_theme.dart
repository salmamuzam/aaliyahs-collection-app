import 'package:flutter/material.dart';

class AaliyahSwitchTheme {
  AaliyahSwitchTheme._();

  static SwitchThemeData switchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        if (states.contains(WidgetState.selected)) {

          return colorScheme.onPrimary;
        }

        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent; 
        }
        return colorScheme.outline;
      }),
      trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return 0.0;
        return 2.0; 
      }),
      thumbIcon: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          
          return Icon(Icons.check, color: colorScheme.onPrimaryContainer);
        }
        return null; 
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withValues(alpha: 0.08);
        if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.1);
        }
        return null;
      }),
    );
  }
}
