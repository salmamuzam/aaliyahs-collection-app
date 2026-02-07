import 'package:flutter/material.dart';

/// M3 Expressive Icon Button Specifications
/// 
/// === TYPES ===
/// - Default: Standard icon button for actions
/// - Toggle: Selection icon button (outlined unselected, filled selected)
/// 
/// === COLOR STYLES ===
/// - Standard: No container, icon only
/// - Filled: Solid container background
/// - Filled Tonal: Tonal container (secondary container colors)
/// - Outlined: Outlined border, no fill
/// 
/// === SIZES (M3 Expressive) ===
/// - Extra Small: 32dp
/// - Small: 40dp (default)
/// - Medium: 48dp
/// - Large: 56dp
/// - Extra Large: 64dp
/// 
/// === SHAPES ===
/// - Round: Circular (default)
/// - Square: Rounded rectangle (corner radius varies by size)
/// - Shape morphs when pressed or selected
/// 
/// === WIDTHS ===
/// - Narrow: Compact horizontal padding
/// - Default: Standard padding
/// - Wide: Extended horizontal padding
/// 
/// === STATES ===
/// - Enabled: No state layer
/// - Hovered: 8% state layer
/// - Focused: 10% state layer  
/// - Pressed: 10% state layer
/// - Selected: Uses filled style
/// 
/// === ACCESSIBILITY (M3 Requirements) ===
/// - Icon must have 3:1 contrast ratio with surface/background
/// - Target size must be at least 48dp (even when nested)
/// - Tab focuses, Space/Enter activates
/// - Tooltip on hover (web) describing the ACTION (not icon name)
/// - Accessibility label describes the ACTION (e.g., "Add to favorites")
/// - Don't apply density by default (keeps targets below 48dp)

class AaliyahIconButtonTheme {
  AaliyahIconButtonTheme._();
  
  // === SIZES (M3 Expressive) ===
  /// Extra small icon button: 32dp
  static const double extraSmallSize = 32.0;
  /// Small icon button: 40dp (default)
  static const double smallSize = 40.0;
  /// Medium icon button: 48dp
  static const double mediumSize = 48.0;
  /// Large icon button: 56dp
  static const double largeSize = 56.0;
  /// Extra large icon button: 64dp
  static const double extraLargeSize = 64.0;
  
  // === ICON SIZES ===
  /// Icon size for extra small button
  static const double extraSmallIconSize = 18.0;
  /// Icon size for small button (default)
  static const double smallIconSize = 20.0;
  /// Icon size for medium button
  static const double mediumIconSize = 24.0;
  /// Icon size for large button
  static const double largeIconSize = 24.0;
  /// Icon size for extra large button
  static const double extraLargeIconSize = 28.0;
  
  // === CORNER RADII (M3 Expressive) ===
  // Round button: Full radius (circular)
  // Square button corner radii per size:
  static const double xsSquareRadius = 12.0;
  static const double sSquareRadius = 12.0;
  static const double mSquareRadius = 16.0;
  static const double lSquareRadius = 28.0;
  static const double xlSquareRadius = 28.0;
  
  // Pressed state corner radii per size:
  static const double xsPressedRadius = 8.0;
  static const double sPressedRadius = 8.0;
  static const double mPressedRadius = 12.0;
  static const double lPressedRadius = 16.0;
  static const double xlPressedRadius = 16.0;
  
  // === MINIMUM TARGET SIZE (48x48dp for XS and S) ===
  static const double minTargetSize = 48.0;
  
  // === SHAPES ===
  /// Round shape (default for icon buttons) - circular
  static const OutlinedBorder roundShape = CircleBorder();
  
  /// Gets the square shape for a given size
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
  
  /// Gets the pressed state shape for a given size
  /// Shape morphs to more square when pressed
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
  
  /// Creates a shape that morphs when pressed
  /// Round buttons become more square when pressed
  static WidgetStateProperty<OutlinedBorder> morphingShape(IconButtonSize size, {bool isSquare = false}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return getPressedShape(size);
      }
      return isSquare ? getSquareShape(size) : roundShape;
    });
  }
  
  /// Creates a toggle shape that morphs between round (unselected) and square (selected)
  static WidgetStateProperty<OutlinedBorder> toggleMorphingShape(IconButtonSize size, {required bool isSelected}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return getPressedShape(size);
      }
      // Toggle: round when unselected, square when selected
      return isSelected ? getSquareShape(size) : roundShape;
    });
  }
  
  // === LIGHT THEME ===
  static final IconButtonThemeData lightIconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(
      // M3 Expressive: Small size (40dp) as default
      minimumSize: WidgetStateProperty.all(const Size(smallSize, smallSize)),
      // M3 Expressive: Round shape by default
      shape: WidgetStateProperty.all(roundShape),
      // M3: State layer colors
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.black.withValues(alpha: 0.10); // 10% pressed
        }
        if (states.contains(WidgetState.focused)) {
          return Colors.black.withValues(alpha: 0.10); // 10% focused
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.black.withValues(alpha: 0.08); // 8% hovered
        }
        return null;
      }),
      // M3: Icon color
      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.black.withValues(alpha: 0.38);
        }
        return Colors.black87;
      }),
      // M3: Proper tap target size
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
  
  /// Dynamic theme using ColorScheme
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
  
  /// Creates a toggle icon button style (for selection)
  /// M3 Expressive: Round shape unselected, square shape selected
  /// Uses correct color roles per M3 specs
  static ButtonStyle toggleStyle(
    ColorScheme colorScheme, {
    bool isSelected = false,
    IconButtonSize size = IconButtonSize.small,
    IconButtonColorStyle colorStyle = IconButtonColorStyle.filled,
  }) {
    final double buttonSize = _getSizeValue(size);
    
    // M3 Expressive: Shape morphs between round (unselected) and square (selected)
    final shape = toggleMorphingShape(size, isSelected: isSelected);
    
    return switch (colorStyle) {
      IconButtonColorStyle.filled => _filledToggleStyle(colorScheme, isSelected, buttonSize, shape),
      IconButtonColorStyle.filledTonal => _tonalToggleStyle(colorScheme, isSelected, buttonSize, shape),
      IconButtonColorStyle.outlined => _outlinedToggleStyle(colorScheme, isSelected, buttonSize, shape),
      IconButtonColorStyle.standard => _standardToggleStyle(colorScheme, isSelected, buttonSize, shape),
    };
  }
  
  /// Filled toggle button style per M3 Expressive specs
  static ButtonStyle _filledToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {
    // M3 Color roles:
    // Unselected: surfaceContainerHighest container, primary icon
    // Selected: primary container, onPrimary icon
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
  
  /// Tonal toggle button style per M3 Expressive specs
  static ButtonStyle _tonalToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {
    // M3 Color roles:
    // Unselected: surfaceContainerHighest container, onSurfaceVariant icon
    // Selected: secondaryContainer container, onSecondaryContainer icon
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
  
  /// Outlined toggle button style per M3 Expressive specs
  static ButtonStyle _outlinedToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {
    // M3 Color roles:
    // Unselected: transparent container, outlineVariant border, onSurfaceVariant icon
    // Selected: inverseSurface container, inverseOnSurface icon
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
        // No border when selected (filled)
        return isSelected ? BorderSide.none : BorderSide(color: colorScheme.outlineVariant);
      }),
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      shape: shape,
    );
  }
  
  /// Standard toggle button style per M3 Expressive specs
  static ButtonStyle _standardToggleStyle(
    ColorScheme colorScheme,
    bool isSelected,
    double buttonSize,
    WidgetStateProperty<OutlinedBorder> shape,
  ) {
    // M3 Color roles:
    // Unselected: onSurfaceVariant icon
    // Selected: primary icon
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
  
  /// Gets the size value for a given IconButtonSize
  static double _getSizeValue(IconButtonSize size) {
    return switch (size) {
      IconButtonSize.extraSmall => extraSmallSize,
      IconButtonSize.small => smallSize,
      IconButtonSize.medium => mediumSize,
      IconButtonSize.large => largeSize,
      IconButtonSize.extraLarge => extraLargeSize,
    };
  }
  
  /// Gets the icon size for a given IconButtonSize
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

/// M3 Expressive Icon Button sizes
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

/// M3 Expressive Icon Button shapes
enum IconButtonShape {
  /// Circular shape (default)
  round,
  /// Rounded rectangle shape
  square,
}

/// M3 Expressive Icon Button color styles
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
