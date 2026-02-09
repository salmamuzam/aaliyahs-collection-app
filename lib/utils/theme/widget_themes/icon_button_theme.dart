import 'package:flutter/material.dart';



class AaliyahIconButtonTheme {
  AaliyahIconButtonTheme._();
  


  static const double extraSmallSize = 32.0;

  static const double smallSize = 40.0;

  static const double mediumSize = 48.0;

  static const double largeSize = 56.0;

  static const double extraLargeSize = 64.0;
  

  static const double extraSmallIconSize = 18.0;

  static const double smallIconSize = 20.0;

  static const double mediumIconSize = 24.0;

  static const double largeIconSize = 24.0;

  static const double extraLargeIconSize = 28.0;
  
 
  static const double xsSquareRadius = 12.0;
  static const double sSquareRadius = 12.0;
  static const double mSquareRadius = 16.0;
  static const double lSquareRadius = 28.0;
  static const double xlSquareRadius = 28.0;
  

  static const double xsPressedRadius = 8.0;
  static const double sPressedRadius = 8.0;
  static const double mPressedRadius = 12.0;
  static const double lPressedRadius = 16.0;
  static const double xlPressedRadius = 16.0;
  
  
  static const double minTargetSize = 48.0;
  

  static const OutlinedBorder roundShape = CircleBorder();
  

  static OutlinedBorder getSquareShape(IconButtonSize size) {
    final double radius = switch (size) {
      IconButtonSize.extraSmall => xsSquareRadius,
      IconButtonSize.small => sSquareRadius,
      IconButtonSize.medium => mSquareRadius,
      IconButtonSize.large => lSquareRadius,
      IconButtonSize.extraLarge => xlSquareRadius,
    };
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
  

  static OutlinedBorder getPressedShape(IconButtonSize size) {
    final double radius = switch (size) {
      IconButtonSize.extraSmall => xsPressedRadius,
      IconButtonSize.small => sPressedRadius,
      IconButtonSize.medium => mPressedRadius,
      IconButtonSize.large => lPressedRadius,
      IconButtonSize.extraLarge => xlPressedRadius,
    };
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
  

  static WidgetStateProperty<OutlinedBorder> morphingShape(IconButtonSize size, {bool isSquare = false}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return getPressedShape(size);
      }
      return isSquare ? getSquareShape(size) : roundShape;
    });
  }
  

  static WidgetStateProperty<OutlinedBorder> toggleMorphingShape(IconButtonSize size, {required bool isSelected}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return getPressedShape(size);
      }

      return isSelected ? getSquareShape(size) : roundShape;
    });
  }
  

  static final IconButtonThemeData lightIconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(

      minimumSize: WidgetStateProperty.all(const Size(smallSize, smallSize)),

      shape: WidgetStateProperty.all(roundShape),
 
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.black.withValues(alpha: 0.10); 
        }
        if (states.contains(WidgetState.focused)) {
          return Colors.black.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.black.withValues(alpha: 0.08); 
        }
        return null;
      }),

      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.black.withValues(alpha: 0.38);
        }
        return Colors.black87;
      }),

      tapTargetSize: MaterialTapTargetSize.padded,
    ),
  );
  
  // === DARK THEME ===
  static final IconButtonThemeData darkIconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(smallSize, smallSize)),
      shape: WidgetStateProperty.all(roundShape),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.white.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return Colors.white.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withValues(alpha: 0.08);
        }
        return null;
      }),
      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.white.withValues(alpha: 0.38);
        }
        return Colors.white;
      }),
      tapTargetSize: MaterialTapTargetSize.padded,
    ),
  );
  

  static IconButtonThemeData iconButtonTheme(ColorScheme colorScheme) {
    return IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(smallSize, smallSize)),
        shape: WidgetStateProperty.all(roundShape),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.onSurface.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.focused)) {
            return colorScheme.onSurface.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.onSurface.withValues(alpha: 0.08);
          }
          return null;
        }),
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          return colorScheme.onSurfaceVariant;
        }),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
  
  /// Creates a filled icon button style
  static ButtonStyle filledStyle(ColorScheme colorScheme, {IconButtonSize size = IconButtonSize.small}) {
    final double buttonSize = _getSizeValue(size);
    
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return colorScheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return colorScheme.onPrimary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.onPrimary.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.onPrimary.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.onPrimary.withValues(alpha: 0.08);
        }
        return null;
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: WidgetStateProperty.all(roundShape),
    );
  }
  
  /// Creates a filled tonal icon button style
  static ButtonStyle filledTonalStyle(ColorScheme colorScheme, {IconButtonSize size = IconButtonSize.small}) {
    final double buttonSize = _getSizeValue(size);
    
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return colorScheme.secondaryContainer;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return colorScheme.onSecondaryContainer;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.onSecondaryContainer.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.onSecondaryContainer.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.onSecondaryContainer.withValues(alpha: 0.08);
        }
        return null;
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: WidgetStateProperty.all(roundShape),
    );
  }
  
  /// Creates an outlined icon button style
  static ButtonStyle outlinedStyle(ColorScheme colorScheme, {IconButtonSize size = IconButtonSize.small}) {
    final double buttonSize = _getSizeValue(size);
    
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return colorScheme.onSurfaceVariant;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.onSurfaceVariant.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.onSurfaceVariant.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.onSurfaceVariant.withValues(alpha: 0.08);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.12));
        }
        return BorderSide(color: colorScheme.outline);
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: WidgetStateProperty.all(roundShape),
    );
  }
  

  static ButtonStyle toggleStyle(
    ColorScheme colorScheme, {
    bool isSelected = false,
    IconButtonSize size = IconButtonSize.small,
    IconButtonColorStyle colorStyle = IconButtonColorStyle.filled,
  }) {
    final double buttonSize = _getSizeValue(size);
    

    final shape = toggleMorphingShape(size, isSelected: isSelected);
    
    return switch (colorStyle) {
      IconButtonColorStyle.filled => _filledToggleStyle(colorScheme, isSelected, buttonSize, shape),
      IconButtonColorStyle.filledTonal => _tonalToggleStyle(colorScheme, isSelected, buttonSize, shape),
      IconButtonColorStyle.outlined => _outlinedToggleStyle(colorScheme, isSelected, buttonSize, shape),
      IconButtonColorStyle.standard => _standardToggleStyle(colorScheme, isSelected, buttonSize, shape),
    };
  }
  

  static ButtonStyle _filledToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return isSelected ? colorScheme.onPrimary : colorScheme.primary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        final Color stateColor = isSelected ? colorScheme.onPrimary : colorScheme.primary;
        if (states.contains(WidgetState.pressed)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return stateColor.withValues(alpha: 0.08);
        }
        return null;
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: shape,
    );
  }
  

  static ButtonStyle _tonalToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {
    
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return isSelected ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHighest;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        final Color stateColor = isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant;
        if (states.contains(WidgetState.pressed)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return stateColor.withValues(alpha: 0.08);
        }
        return null;
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: shape,
    );
  }
  

  static ButtonStyle _outlinedToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return isSelected ? colorScheme.inverseSurface : Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return isSelected ? colorScheme.onInverseSurface : colorScheme.onSurfaceVariant;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        final Color stateColor = isSelected ? colorScheme.onInverseSurface : colorScheme.onSurfaceVariant;
        if (states.contains(WidgetState.pressed)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return stateColor.withValues(alpha: 0.08);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.12));
        }

        return isSelected ? BorderSide.none : BorderSide(color: colorScheme.outlineVariant);
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: shape,
    );
  }

  static ButtonStyle _standardToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        final Color stateColor = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
        if (states.contains(WidgetState.pressed)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.focused)) {
          return stateColor.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return stateColor.withValues(alpha: 0.08);
        }
        return null;
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: shape,
    );
  }
  

  static double _getSizeValue(IconButtonSize size) {
    return switch (size) {
      IconButtonSize.extraSmall => extraSmallSize,
      IconButtonSize.small => smallSize,
      IconButtonSize.medium => mediumSize,
      IconButtonSize.large => largeSize,
      IconButtonSize.extraLarge => extraLargeSize,
    };
  }
  

  static double getIconSize(IconButtonSize size) {
    return switch (size) {
      IconButtonSize.extraSmall => extraSmallIconSize,
      IconButtonSize.small => smallIconSize,
      IconButtonSize.medium => mediumIconSize,
      IconButtonSize.large => largeIconSize,
      IconButtonSize.extraLarge => extraLargeIconSize,
    };
  }
}


enum IconButtonSize {
  /// Extra small: 32dp
  extraSmall,
  /// Small: 40dp (default)
  small,
  /// Medium: 48dp
  medium,
  /// Large: 56dp
  large,
  /// Extra large: 64dp
  extraLarge,
}


enum IconButtonShape {
  /// Circular shape (default)
  round,
  /// Rounded rectangle shape
  square,
}


enum IconButtonColorStyle {
  /// Standard: No container, icon only
  standard,
  /// Filled: Solid primary container
  filled,
  /// Filled Tonal: Secondary container colors
  filledTonal,
  /// Outlined: Border with no fill
  outlined,
}
