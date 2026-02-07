import 'package:flutter/material.dart';

class AaliyahAppBarTheme {
  AaliyahAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0, // M3 Expressive: No shadow, use fill color instead
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent, // Controlled via ColorScheme in M3
    iconTheme: IconThemeData(color: Colors.black, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.black, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 24.0, // M3 Expressive: Larger title text (increased from 22)
      fontWeight: FontWeight.w600, 
      color: Colors.black,
      letterSpacing: 0,
      height: 1.2,
    ),
    toolbarHeight: 64.0, // M3 Expressive: Small app bar height (increased from 56)
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0, // M3 Expressive: No shadow, use fill color instead
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.white, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 24.0, // M3 Expressive: Larger title text (increased from 22)
      fontWeight: FontWeight.w600, 
      color: Colors.white,
      letterSpacing: 0,
      height: 1.2,
    ),
    toolbarHeight: 64.0, // M3 Expressive: Small app bar height (increased from 56)
  );
}
