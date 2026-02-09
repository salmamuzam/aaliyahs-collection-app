import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class AaliyahSnackBarTheme {
  AaliyahSnackBarTheme._();

  static SnackBarThemeData snackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      actionTextColor: colorScheme.inversePrimary,
      contentTextStyle: TextStyle(
        color: colorScheme.onInverseSurface,
        fontSize: 14, 
        fontWeight: FontWeight.normal,
      ),
      elevation: 6, 
    
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusSmall), 
      ),
      closeIconColor: colorScheme.onInverseSurface,

      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.all(16), 
    );
  }
}
