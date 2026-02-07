import 'package:flutter/material.dart';

class AaliyahTabBarTheme {
  AaliyahTabBarTheme._();

  static TabBarThemeData tabBarTheme(ColorScheme colorScheme) {
    return TabBarThemeData(
      indicatorColor: colorScheme.primary, // Selected Indicator
      indicatorSize: TabBarIndicatorSize.label, // M3 Primary Tabs: Indicator width equals text width
      labelColor: colorScheme.primary, // Selected Label High Emphasis
      unselectedLabelColor: colorScheme.onSurfaceVariant, // Unselected Label
      labelStyle: const TextStyle(fontWeight: FontWeight.bold), // M3 Title Small Bold for selected
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), // M3 Title Small Regular for unselected
      dividerColor: colorScheme.outlineVariant, // M3 Divider usually OutlineVariant
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withValues(alpha: 0.08);
        if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.1);
        }
        return null; // Transparent otherwise
      }),
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
    );
  }
}
