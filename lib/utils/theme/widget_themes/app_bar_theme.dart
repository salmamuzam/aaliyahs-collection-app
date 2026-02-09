import 'package:flutter/material.dart';

class AaliyahAppBarTheme {
  AaliyahAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0, 
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent, 
    iconTheme: IconThemeData(color: Colors.black, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.black, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 24.0, 
      fontWeight: FontWeight.w600, 
      color: Colors.black,
      letterSpacing: 0,
      height: 1.2,
    ),
    toolbarHeight: 64.0, 
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0, 
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.white, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 24.0, 
      fontWeight: FontWeight.w600, 
      color: Colors.white,
      letterSpacing: 0,
      height: 1.2,
    ),
    toolbarHeight: 64.0, 
  );
}
