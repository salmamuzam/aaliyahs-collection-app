import 'package:flutter/material.dart';

/// Configuration for a single pane in an adaptive layout.
class PaneConfig {
  /// Unique identifier for this pane
  final String id;
  

  final bool isFixed;
  

  final double? fixedWidth;
  
  /// Minimum width constraint for flexible panes
  final double? minWidth;
  
  /// Maximum width constraint for flexible panes
  final double? maxWidth;
  

  final bool resizable;
  
  /// Whether resize preferences should persist across sessions
  final bool persistResize;
  
  /// Whether this pane is currently visible
  final bool visible;
  

  final int flex;

  const PaneConfig({
    required this.id,
    this.isFixed = false,
    this.fixedWidth,
    this.minWidth,
    this.maxWidth,
    this.resizable = false,
    this.persistResize = false,
    this.visible = true,
    this.flex = 1,
  }) : assert(!isFixed || fixedWidth != null, 'Fixed panes must have a fixedWidth');

  PaneConfig copyWith({
    String? id,
    bool? isFixed,
    double? fixedWidth,
    double? minWidth,
    double? maxWidth,
    bool? resizable,
    bool? persistResize,
    bool? visible,
    int? flex,
  }) {
    return PaneConfig(
      id: id ?? this.id,
      isFixed: isFixed ?? this.isFixed,
      fixedWidth: fixedWidth ?? this.fixedWidth,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      resizable: resizable ?? this.resizable,
      persistResize: persistResize ?? this.persistResize,
      visible: visible ?? this.visible,
      flex: flex ?? this.flex,
    );
  }
}

/// A container widget for individual panes in adaptive layouts.

class PaneContainer extends StatelessWidget {
  /// Configuration for this pane
  final PaneConfig config;
  
  /// The content to display in this pane
  final Widget child;
  
  /// Background color (defaults to theme's surface)
  final Color? backgroundColor;
  
  /// Padding inside the pane
  final EdgeInsetsGeometry? padding;
  
  /// Whether to show elevation/shadow
  final bool elevated;
  
  /// Elevation value (only used if elevated is true)
  final double elevation;
  
  /// Border radius for the pane
  final BorderRadius? borderRadius;

  const PaneContainer({
    super.key,
    required this.config,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.elevated = false,
    this.elevation = 1.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (!config.visible) {
      return const SizedBox.shrink();
    }
    
    Widget content = Container(
      width: config.isFixed ? config.fixedWidth : null,
      constraints: config.isFixed
          ? null
          : BoxConstraints(
              minWidth: config.minWidth ?? 0,
              maxWidth: config.maxWidth ?? double.infinity,
            ),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (elevated ? colorScheme.surface : null),
        borderRadius: borderRadius,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: child,
    );
    
 
    if (!config.isFixed) {
      content = Expanded(
        flex: config.flex,
        child: content,
      );
    }
    
    return content;
  }
}
