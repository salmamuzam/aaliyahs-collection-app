import 'package:flutter/material.dart';

class AaliyahTabBarTheme {
  AaliyahTabBarTheme._();

  static TabBarThemeData tabBarTheme(ColorScheme colorScheme) {
    return TabBarThemeData(
      indicatorColor: colorScheme.primary, 
      indicatorSize: TabBarIndicatorSize.label, 
      labelColor: colorScheme.primary, 
      unselectedLabelColor: colorScheme.onSurfaceVariant, 
      labelStyle: const TextStyle(fontWeight: FontWeight.bold), 
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), 
      dividerColor: colorScheme.outlineVariant, 
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return colorScheme.primary.withValues(alpha: 0.08);
        if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.1);
        }
        return null; 
      }),
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
    );
  }
}
