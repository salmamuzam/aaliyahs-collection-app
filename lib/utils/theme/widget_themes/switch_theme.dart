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
          // M3: Selected thumb is OnPrimary inside Primary track
          return colorScheme.onPrimary;
        }
        // M3: Unselected thumb is Outline inside SurfaceContainerHighest track
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
          return Colors.transparent; // Active usually has no border or same as track
        }
        return colorScheme.outline;
      }),
      trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return 0.0; // Usually no outline when selected/filled
        return 2.0; // Unselected M3 Spec: 2dp
      }),
      thumbIcon: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          // M3 Spec: Icon color on selected handle is OnPrimaryContainer
          return Icon(Icons.check, color: colorScheme.onPrimaryContainer);
        }
        return null; // No icon for unselected by default. Optional: Add Icon(Icons.close) if desired.
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
