import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class AaliyahDialogTheme {
  AaliyahDialogTheme._();

  static DialogThemeData dialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh, 
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.dialogRadius), 
      ),

      insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      actionsPadding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
      
      titleTextStyle: TextStyle(
        fontSize: 24, 
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.25,
      ),
     
      alignment: Alignment.center,
      iconColor: colorScheme.secondary,
    );
  }
}
