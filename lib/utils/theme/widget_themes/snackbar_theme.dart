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
        fontSize: 14, // M3 Body Medium - like
        fontWeight: FontWeight.normal,
      ),
      elevation: 6, // M3 Elevation Level 3 for SnackBar? Or 6dp?
      // M3: "Usually appear at the bottom... Can disappear...".
      // Elevation: Level 3 (6dp) is standard for floating components in M3? 
      // Actually standard standard is 6dp.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusSmall), // 4dp usually for snackbar
      ),
      closeIconColor: colorScheme.onInverseSurface,
      // M3 Spec: Floating behavior to avoid obscuring navigation
      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.all(16), // 16dp margins from screen edges
    );
  }
}
