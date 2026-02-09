import 'package:flutter/material.dart';

class AaliyahTimePickerTheme {
  AaliyahTimePickerTheme._();

  static TimePickerThemeData timePickerTheme(ColorScheme colorScheme) {
    return TimePickerThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      
   
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      
      hourMinuteColor: colorScheme.surfaceContainerHighest,
      hourMinuteTextColor: colorScheme.onSurface,
      hourMinuteTextStyle: const TextStyle(fontSize: 45, fontWeight: FontWeight.normal),
      

      dayPeriodColor: Colors.transparent,
      dayPeriodTextColor: colorScheme.onSurfaceVariant,
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outline),
      ),
      dayPeriodTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      
 
      dialBackgroundColor: colorScheme.surfaceContainerHighest,
      dialHandColor: colorScheme.primary,
      dialTextColor: colorScheme.onSurface,
      dialTextStyle: const TextStyle(fontSize: 16),
      
    
      entryModeIconColor: colorScheme.onSurfaceVariant,
      helpTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      
    
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
