import 'package:flutter/material.dart';

class AaliyahSliderTheme {
  AaliyahSliderTheme._();

  static SliderThemeData sliderTheme(ColorScheme colorScheme) {
    // M3 Standard Variant (Horizontal)
    return SliderThemeData(
      // Track (Active: Primary, Inactive: Secondary Container)
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.secondaryContainer,
      disabledActiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.12),
      disabledInactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.12),
      
      // Thumb (Primary)
      thumbColor: colorScheme.primary,
      disabledThumbColor: colorScheme.onSurface.withValues(alpha: 0.38),
      
      // Overlay (Ripple effect - usually Primary with low opacity)
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      
      // Value Indicator (Inverse Surface / Inverse On Surface)
      valueIndicatorColor: colorScheme.inverseSurface,
      valueIndicatorTextStyle: TextStyle(
        color: colorScheme.onInverseSurface,
        fontWeight: FontWeight.bold,
      ),
      
      // Ticks (Division markers)
      activeTickMarkColor: colorScheme.onPrimary.withValues(alpha: 0.38),
      inactiveTickMarkColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.38),
      disabledActiveTickMarkColor: colorScheme.onSurface.withValues(alpha: 0.12),
      disabledInactiveTickMarkColor: colorScheme.onSurface.withValues(alpha: 0.12),

      // Shapes (Letting M3 defaults handle Track/Thumb for standard animations like shrinking handle)
      valueIndicatorShape: const DropSliderValueIndicatorShape(), // Teardrop shape
      showValueIndicator: ShowValueIndicator.onlyForContinuous, // M3 says "Slider value should take effect immediately... Label on press"
    );
  }
}
