import 'package:flutter/material.dart';

class AaliyahSliderTheme {
  AaliyahSliderTheme._();

  static SliderThemeData sliderTheme(ColorScheme colorScheme) {

    return SliderThemeData(

      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.secondaryContainer,
      disabledActiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.12),
      disabledInactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.12),
      
  
      thumbColor: colorScheme.primary,
      disabledThumbColor: colorScheme.onSurface.withValues(alpha: 0.38),
      
    
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      

      valueIndicatorColor: colorScheme.inverseSurface,
      valueIndicatorTextStyle: TextStyle(
        color: colorScheme.onInverseSurface,
        fontWeight: FontWeight.bold,
      ),
      

      activeTickMarkColor: colorScheme.onPrimary.withValues(alpha: 0.38),
      inactiveTickMarkColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.38),
      disabledActiveTickMarkColor: colorScheme.onSurface.withValues(alpha: 0.12),
      disabledInactiveTickMarkColor: colorScheme.onSurface.withValues(alpha: 0.12),


      valueIndicatorShape: const DropSliderValueIndicatorShape(), 
      showValueIndicator: ShowValueIndicator.onlyForContinuous, 
    );
  }
}
