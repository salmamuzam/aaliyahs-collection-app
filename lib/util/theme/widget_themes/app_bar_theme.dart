import 'package:flutter/material.dart';

class AaliyahAppBarTheme {
  AaliyahAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 3,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent, // Controlled via ColorScheme in M3
    iconTheme: IconThemeData(color: Colors.black, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.black, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 22.0, // M3 Headline Small / Title Large style
      fontWeight: FontWeight.w600, 
      color: Colors.black,
      letterSpacing: 0,
    ),
    toolbarHeight: 64.0, // M3 Small App Bar standard height
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 3,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.white, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 22.0, 
      fontWeight: FontWeight.w600, 
      color: Colors.white,
      letterSpacing: 0,
    ),
    toolbarHeight: 64.0, 
  );
}
