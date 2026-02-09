import 'package:flutter/material.dart';

class AaliyahDividerTheme {
  AaliyahDividerTheme._();

  static DividerThemeData dividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1.0,
      space: 1.0, 
    );
  }


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
