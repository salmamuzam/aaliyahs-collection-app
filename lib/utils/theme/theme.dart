import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/filled_button_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_button_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/app_bar_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_field_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/checkbox_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/chip_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/date_picker_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/time_picker_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/dialog_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/list_tile_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/slider_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/snackbar_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/switch_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/tab_bar_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/floating_action_button_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/icon_button_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/custom_colors.dart';
import 'package:flutter/material.dart';

class AaliyahAppTheme {
  AaliyahAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    brightness: Brightness.light,
    primaryColor: aaliyahPrimaryColor,
    scaffoldBackgroundColor: aaliyahLightColor,
    textTheme: AaliyahTextTheme.generateTextTheme(aaliyahDarkColor),
    appBarTheme: AaliyahAppBarTheme.lightAppBarTheme,
    outlinedButtonTheme: AaliyahOutlinedButtonTheme.lightOutlinedButtonTheme,
    elevatedButtonTheme: AaliyahElevatedButtonTheme.lightElevatedButtonTheme,
    filledButtonTheme: AaliyahFilledButtonTheme.lightFilledButtonTheme,
    textButtonTheme: AaliyahTextButtonTheme.lightTextButtonTheme,
    floatingActionButtonTheme: AaliyahFloatingActionButtonTheme.lightFloatingActionButtonTheme,
    iconButtonTheme: AaliyahIconButtonTheme.lightIconButtonTheme,
    inputDecorationTheme: AaliyahTextFormFieldTheme.lightInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF006A60), // Refined Teal Seed for better tonal generation
      primary: const Color(0xFF006A60),
      onPrimary: Colors.white,
      secondary: const Color(0xFF4A635F),
      tertiary: const Color(0xFF456179), // Muted Blue tertiary
      error: const Color(0xFFBA1A1A),
      surface: const Color(0xFFFBFDFA),
      surfaceTint: const Color(0xFF006A60), // Tint for elevation overlay
    ),
    extensions: [
      StaticColors.getLight(null),
      AaliyahTypography.generateExtension(aaliyahDarkColor, false),
    ],
    // ... rest of lightTheme checkbox/switch
    checkboxTheme: AaliyahCheckboxTheme.checkboxTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60))),
    // States: Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey.withValues(alpha: 0.38);
        if (states.contains(WidgetState.selected)) return Colors.white;
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey.withValues(alpha: 0.12);
        if (states.contains(WidgetState.selected)) return const Color(0xFF006A60);
        return Colors.grey.shade200;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return const Color(0xFF006A60).withValues(alpha: 0.08);
        if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
          return const Color(0xFF006A60).withValues(alpha: 0.1);
        }
        return null;
      }),
    ),
    chipTheme: AaliyahChipTheme.chipTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60))),
    datePickerTheme: AaliyahDatePickerTheme.datePickerTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60))),
    timePickerTheme: AaliyahTimePickerTheme.timePickerTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60))),
    dialogTheme: AaliyahDialogTheme.dialogTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60))),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    brightness: Brightness.dark,
    primaryColor: aaliyahPrimaryColor,
    scaffoldBackgroundColor: const Color(0xFF191C1B), // Dark Green-Grey Surface
    textTheme: AaliyahTextTheme.generateTextTheme(aaliyahLightColor),
    appBarTheme: AaliyahAppBarTheme.darkAppBarTheme,
    outlinedButtonTheme: AaliyahOutlinedButtonTheme.darkOutlinedButtonTheme,
    elevatedButtonTheme: AaliyahElevatedButtonTheme.darkElevatedButtonTheme,
    filledButtonTheme: AaliyahFilledButtonTheme.darkFilledButtonTheme,
    textButtonTheme: AaliyahTextButtonTheme.darkTextButtonTheme,
    floatingActionButtonTheme: AaliyahFloatingActionButtonTheme.darkFloatingActionButtonTheme,
    iconButtonTheme: AaliyahIconButtonTheme.darkIconButtonTheme,
    inputDecorationTheme: AaliyahTextFormFieldTheme.darkInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF006A60),
      brightness: Brightness.dark,
      primary: const Color(0xFF4CDABD), // Lighter Teal for Dark Mode
      onPrimary: const Color(0xFF003731),
      secondary: const Color(0xFFB1CCC6),
      tertiary: const Color(0xFFAEC9E5),
      error: const Color(0xFFFFB4AB),
      surface: const Color(0xFF191C1B),
      surfaceTint: const Color(0xFF4CDABD),
    ),
    extensions: [
      StaticColors.getDark(null),
      AaliyahTypography.generateExtension(aaliyahLightColor, true),
    ],
    // States: Checkbox
    checkboxTheme: AaliyahCheckboxTheme.checkboxTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60), brightness: Brightness.dark)),
    // States: Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey.withValues(alpha: 0.38);
        if (states.contains(WidgetState.selected)) return Colors.white;
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey.withValues(alpha: 0.12);
        if (states.contains(WidgetState.selected)) return const Color(0xFF4CDABD);
        return Colors.grey.shade700;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return const Color(0xFF4CDABD).withValues(alpha: 0.08);
        if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
          return const Color(0xFF4CDABD).withValues(alpha: 0.1);
        }
        return null;
      }),
    ),
    chipTheme: AaliyahChipTheme.chipTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60), brightness: Brightness.dark)),
    datePickerTheme: AaliyahDatePickerTheme.datePickerTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60), brightness: Brightness.dark)),
    timePickerTheme: AaliyahTimePickerTheme.timePickerTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60), brightness: Brightness.dark)),
    dialogTheme: AaliyahDialogTheme.dialogTheme(ColorScheme.fromSeed(seedColor: const Color(0xFF006A60), brightness: Brightness.dark)),
  );

  static ThemeData highContrastLightTheme = lightTheme.copyWith(
    colorScheme: lightTheme.colorScheme.copyWith(
      surface: Colors.white,
      onSurface: Colors.black,
      primary: const Color(0xFF003731), // Darker Teal
      secondary: const Color(0xFF2E3D3A),
      outline: Colors.black87,
    ),
    dividerTheme: const DividerThemeData(color: Colors.black, thickness: 1),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(width: 1.5),
      ),
    ),
  );

  static ThemeData highContrastDarkTheme = darkTheme.copyWith(
    colorScheme: darkTheme.colorScheme.copyWith(
      surface: Colors.black,
      onSurface: Colors.white,
      primary: const Color(0xFFBEFFEC), // Extra light for contrast
      secondary: const Color(0xFFD3EBE5),
      outline: Colors.white,
    ),
    dividerTheme: const DividerThemeData(color: Colors.white, thickness: 1),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
    ),
  );
  static ThemeData createTheme(ColorScheme colorScheme, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final baseTheme = isDark ? darkTheme : lightTheme;

    return ThemeData(
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: AaliyahTextTheme.generateTextTheme(colorScheme.onSurface),
      extensions: [
        isDark ? StaticColors.getDark(colorScheme) : StaticColors.getLight(colorScheme),
        AaliyahTypography.generateExtension(colorScheme.onSurface, isDark),
      ],
      
      // Global State Layers
      hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
      focusColor: colorScheme.onSurface.withValues(alpha: 0.1),
      highlightColor: colorScheme.onSurface.withValues(alpha: 0.1),
      splashColor: colorScheme.onSurface.withValues(alpha: 0.1),
      
      // States: AppBar
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        // surfaceTintColor: Colors.transparent, // Removed to allow M3 default tint/fill
        elevation: 0, // Level 0 resting
        // scrolledUnderElevation: 3, // Default M3 elevation is 3.0 when scrolled under
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        titleTextStyle: AaliyahTypography.generateExtension(colorScheme.onSurface, isDark).titleLargeEmphasized,
      ),

      // States: Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.12);
            return colorScheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.38);
            return colorScheme.onPrimary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return null;
            if (states.contains(WidgetState.dragged)) return colorScheme.onPrimary.withValues(alpha: 0.16);
            if (states.contains(WidgetState.hovered)) return colorScheme.onPrimary.withValues(alpha: 0.08);
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
              return colorScheme.onPrimary.withValues(alpha: 0.1);
            }
            return null;
          }),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
          textStyle: WidgetStateProperty.all(AaliyahTypography.generateExtension(colorScheme.onPrimary, isDark).labelLargeEmphasized),
          shape: WidgetStateProperty.all(const StadiumBorder()),
        ),
      ),

      // States: Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.38);
            return colorScheme.primary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.12));
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.hovered)) return BorderSide(color: colorScheme.primary, width: 2); // Thicker border on hover/focus (M3)
            return BorderSide(color: colorScheme.outline); // Default width 1 (M3)
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return null;
            if (states.contains(WidgetState.dragged)) return colorScheme.primary.withValues(alpha: 0.16);
            if (states.contains(WidgetState.hovered)) return colorScheme.primary.withValues(alpha: 0.08);
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
              return colorScheme.primary.withValues(alpha: 0.1);
            }
            return null;
          }),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
          textStyle: WidgetStateProperty.all(AaliyahTypography.generateExtension(colorScheme.primary, isDark).labelLargeEmphasized),
          shape: WidgetStateProperty.all(const StadiumBorder()),
        ),
      ),

      // States: Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return 0;
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return 2; // Elevate on hover/focus (M3)
            if (states.contains(WidgetState.pressed)) return 0;
            return 1;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.12);
            return colorScheme.surfaceContainerLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.38);
            return colorScheme.primary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return null;
            if (states.contains(WidgetState.dragged)) return colorScheme.primary.withValues(alpha: 0.16);
            if (states.contains(WidgetState.hovered)) return colorScheme.primary.withValues(alpha: 0.08);
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
              return colorScheme.primary.withValues(alpha: 0.1);
            }
            return null;
          }),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
          textStyle: WidgetStateProperty.all(AaliyahTypography.generateExtension(colorScheme.primary, isDark).labelLargeEmphasized),
          shape: WidgetStateProperty.all(const StadiumBorder()),
        ),
      ),

      // States: Text Field (Input Decoration)
      inputDecorationTheme: AaliyahTextFormFieldTheme.inputDecorationTheme(colorScheme),

      checkboxTheme: AaliyahCheckboxTheme.checkboxTheme(colorScheme),
      switchTheme: AaliyahSwitchTheme.switchTheme(colorScheme),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.38);
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.onSurfaceVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return colorScheme.primary.withValues(alpha: 0.08);
          if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.1);
          }
          return null;
        }),
      ),

      // States: Slider
      sliderTheme: AaliyahSliderTheme.sliderTheme(colorScheme),

      // States: Card
      cardTheme: CardThemeData(
        elevation: 0, 
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium), // M3 Standard: 12dp
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),

      // States: List Tile
      listTileTheme: AaliyahListTileTheme.listTileTheme(colorScheme),

      // States: Text Button
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withValues(alpha: 0.38);
            return colorScheme.primary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return null;
            if (states.contains(WidgetState.hovered)) return colorScheme.primary.withValues(alpha: 0.08);
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
              return colorScheme.primary.withValues(alpha: 0.1);
            }
            return null;
          }),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
          textStyle: WidgetStateProperty.all(AaliyahTypography.generateExtension(colorScheme.primary, isDark).labelLargeEmphasized),
          shape: WidgetStateProperty.all(const StadiumBorder()),
        ),
      ),

      // States: Chip
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        brightness: brightness,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusSmall)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),



      dividerTheme: AaliyahDividerTheme.dividerTheme(colorScheme),

      // States: Tab Bar
      tabBarTheme: AaliyahTabBarTheme.tabBarTheme(colorScheme),

      // States: Badge
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        textStyle: AaliyahTypography.generateExtension(colorScheme.onError, isDark).labelSmallEmphasized,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        largeSize: 16,
        smallSize: 6,
      ),

      // M3 Elevation: Scrim & Overlays
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        scrimColor: colorScheme.scrim.withValues(alpha: 0.32),
        surfaceTintColor: Colors.transparent,
        elevation: 1, 
      ),

      dialogTheme: AaliyahDialogTheme.dialogTheme(colorScheme),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 1, 
        modalElevation: 1,
        modalBarrierColor: colorScheme.scrim.withValues(alpha: 0.32),
        constraints: const BoxConstraints(maxWidth: 640),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(TUIConstants.bottomSheetRadius)),
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0, // Level 0 per M3 Tokens
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        unselectedLabelTextStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 3, // Level 2 per M3 Tokens
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surface,
      ),
      // M3 Docked Toolbar Spec
      bottomAppBarTheme: BottomAppBarThemeData(
        color: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      datePickerTheme: AaliyahDatePickerTheme.datePickerTheme(colorScheme),
      timePickerTheme: AaliyahTimePickerTheme.timePickerTheme(colorScheme),
      // M3 Plain Tooltip Spec
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: TextStyle(color: colorScheme.onInverseSurface),
        constraints: const BoxConstraints(minHeight: 24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        preferBelow: false,
      ),
      floatingActionButtonTheme: AaliyahFloatingActionButtonTheme.floatingActionButtonTheme(colorScheme),
      iconButtonTheme: AaliyahIconButtonTheme.iconButtonTheme(colorScheme),
      snackBarTheme: AaliyahSnackBarTheme.snackBarTheme(colorScheme),
    );
  }
}
