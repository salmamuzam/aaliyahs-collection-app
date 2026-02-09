import 'package:flutter/material.dart';


class PaneDragHandle extends StatefulWidget {
  /// The axis along which the drag handle operates
  final Axis axis;
  
  /// Callback when drag is updated with delta movement
  final ValueChanged<double>? onDragUpdate;
  
  /// Callback when drag ends
  final VoidCallback? onDragEnd;
  
  /// Whether the drag handle is enabled
  final bool enabled;
  

  final Color? color;
  
  /// Custom width for vertical drag handles (defaults to 24dp)
  final double? width;
  
  /// Custom height for horizontal drag handles (defaults to 24dp)
  final double? height;

  const PaneDragHandle({
    super.key,
    this.axis = Axis.vertical,
    this.onDragUpdate,
    this.onDragEnd,
    this.enabled = true,
    this.color,
    this.width,
    this.height,
  });

  @override
  State<PaneDragHandle> createState() => _PaneDragHandleState();
}

class _PaneDragHandleState extends State<PaneDragHandle> {
  bool _isHovering = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final handleColor = widget.color ?? colorScheme.outlineVariant;
    
    final isVertical = widget.axis == Axis.vertical;
    
    return MouseRegion(
      cursor: widget.enabled 
          ? (isVertical ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow)
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onHorizontalDragUpdate: isVertical && widget.enabled
            ? (details) {
                setState(() => _isDragging = true);
                widget.onDragUpdate?.call(details.delta.dx);
              }
            : null,
        onVerticalDragUpdate: !isVertical && widget.enabled
            ? (details) {
                setState(() => _isDragging = true);
                widget.onDragUpdate?.call(details.delta.dy);
              }
            : null,
        onHorizontalDragEnd: isVertical && widget.enabled
            ? (_) {
                setState(() => _isDragging = false);
                widget.onDragEnd?.call();
              }
            : null,
        onVerticalDragEnd: !isVertical && widget.enabled
            ? (_) {
                setState(() => _isDragging = false);
                widget.onDragEnd?.call();
              }
            : null,
        child: Container(
          width: isVertical ? (widget.width ?? 24.0) : null,
          height: !isVertical ? (widget.height ?? 24.0) : null,
          color: Colors.transparent, // Expand hit area
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isVertical ? 4.0 : 48.0,
              height: isVertical ? 48.0 : 4.0,
              decoration: BoxDecoration(
                color: _isDragging || _isHovering
                    ? colorScheme.primary.withValues(alpha: 0.6)
                    : handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class PaneDivider extends StatelessWidget {
  /// The axis along which the divider runs
  final Axis axis;
  
  /// Width for vertical dividers (defaults to 24dp)
  final double? width;
  
  /// Height for horizontal dividers (defaults to 24dp)
  final double? height;
  
  /// Thickness of the divider line (defaults to 1dp)
  final double thickness;
  

  final Color? color;
  
  /// Whether to show a drag handle overlay
  final bool showDragHandle;
  
  /// Callback when drag handle is updated
  final ValueChanged<double>? onDragUpdate;
  
  /// Callback when drag ends
  final VoidCallback? onDragEnd;

  const PaneDivider({
    super.key,
    this.axis = Axis.vertical,
    this.width,
    this.height,
    this.thickness = 1.0,
    this.color,
    this.showDragHandle = false,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = color ?? colorScheme.outlineVariant;
    
    final isVertical = axis == Axis.vertical;
    
    if (showDragHandle) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Background divider
          Container(
            width: isVertical ? (width ?? 24.0) : null,
            height: !isVertical ? (height ?? 24.0) : null,
            color: dividerColor.withValues(alpha: 0.2),
            child: Center(
              child: Container(
                width: isVertical ? thickness : null,
                height: !isVertical ? thickness : null,
                color: dividerColor,
              ),
            ),
          ),
          // Drag handle overlay
          PaneDragHandle(
            axis: axis,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            width: width,
            height: height,
          ),
        ],
      );
    }
    
    // Simple divider without drag handle
    return isVertical
        ? VerticalDivider(
            width: width ?? 24.0,
            thickness: thickness,
            color: dividerColor,
          )
        : Divider(
            height: height ?? 24.0,
            thickness: thickness,
            color: dividerColor,
          );
  }
}
