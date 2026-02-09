import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class AaliyahChipTheme {
  AaliyahChipTheme._();

  static ChipThemeData chipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      elevation: 0,
      pressElevation: 0,
      surfaceTintColor: Colors.transparent,
      

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusSmall),
        side: BorderSide(
          color: colorScheme.outline, 
        ),
      ),


      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant, 
      ),

 
      backgroundColor: Colors.transparent,
      selectedColor: colorScheme.secondaryContainer,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
   
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),


      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
      secondarySelectedColor: colorScheme.secondaryContainer,
      
      
      showCheckmark: true,
      checkmarkColor: colorScheme.onSecondaryContainer,
    );
  }
}
