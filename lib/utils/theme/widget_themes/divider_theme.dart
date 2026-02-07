import 'package:flutter/material.dart';

class AaliyahDividerTheme {
  AaliyahDividerTheme._();

  static DividerThemeData dividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1.0,
      space: 1.0, // Default space of 1 for tight lists, override contextually
    );
  }

  /// Helper for Inset Dividers that align with text content in ListTiles
  /// Standard Material 3 Inset: indent based on leading icon/avatar
  static Widget insetDivider(BuildContext context, {double indent = 72.0, double endIndent = 0.0}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Divider(
        height: 1,
        thickness: 1,
        indent: indent,
        endIndent: endIndent,
        color: colorScheme.outlineVariant,
      ),
    );
  }

  /// Full width divider for major section separation
  static Widget fullWidthDivider(BuildContext context, {double height = 16.0}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Divider(
        height: height,
        thickness: 1,
        color: colorScheme.outlineVariant,
      ),
    );
  }
}
