import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/common/widgets/layouts/pane_container.dart';
import 'package:aaliyahs_collection_estore/common/widgets/layouts/pane_drag_handle.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

/// Defines how panes should adapt when window size changes
enum PaneAdaptationStrategy {
  /// Panes show/hide based on available space
  showHide,
  
  /// Panes float above content (as dialogs or bottom sheets)
  levitate,
  
  /// Panes reorganize their position (e.g., side-by-side to stacked)
  reflow,
}

/// Configuration for a pane and its content
class AdaptivePaneItem {
  /// Unique identifier for this pane
  final String id;
  
  /// The widget to display in this pane
  final Widget child;
  
  /// Configuration for this pane
  final PaneConfig config;
  
  /// How this pane should adapt to window size changes
  final PaneAdaptationStrategy adaptationStrategy;
  
  /// Minimum window size class where this pane is visible
  final WindowSizeClass minWindowSize;

  const AdaptivePaneItem({
    required this.id,
    required this.child,
    required this.config,
    this.adaptationStrategy = PaneAdaptationStrategy.showHide,
    this.minWindowSize = WindowSizeClass.compact,
  });
}

/// A widget that creates adaptive multi-pane layouts following Material Design 3 guidelines.
/// 
/// This widget automatically arranges panes based on the current window size class
/// and supports resizing, show/hide, levitate, and reflow adaptation strategies.
class AdaptivePaneLayout extends StatefulWidget {
  /// List of panes to display
  final List<AdaptivePaneItem> panes;
  
  /// Axis along which panes are arranged (horizontal = row, vertical = column)
  final Axis axis;
  
  /// Whether to show dividers between panes
  final bool showDividers;
  
  /// Whether dividers should have drag handles for resizing
  final bool resizableDividers;
  
  /// Callback when a pane is resized
  final void Function(String paneId, double newWidth)? onPaneResized;
  
  /// Custom spacing between panes (defaults to M3 standard 24dp)
  final double? spacing;
  
  /// Whether to center content when max width is reached
  final bool centerContent;
  
  /// Maximum total width for the layout
  final double? maxWidth;

  const AdaptivePaneLayout({
    super.key,
    required this.panes,
    this.axis = Axis.horizontal,
    this.showDividers = true,
    this.resizableDividers = false,
    this.onPaneResized,
    this.spacing,
    this.centerContent = true,
    this.maxWidth,
  });

  @override
  State<AdaptivePaneLayout> createState() => _AdaptivePaneLayoutState();
}

class _AdaptivePaneLayoutState extends State<AdaptivePaneLayout> {
  // Store custom widths for resizable panes
  final Map<String, double> _paneWidths = {};

  @override
  Widget build(BuildContext context) {
    final currentWindowSize = DeviceUtils.windowSizeClass;
    final spacing = widget.spacing ?? DeviceUtils.paneSpacer;
    
    // Filter visible panes based on window size
    final visiblePanes = widget.panes.where((pane) {
      return pane.config.visible && 
             _isVisibleInWindowSize(pane.minWindowSize, currentWindowSize);
    }).toList();
    
    if (visiblePanes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Build pane widgets
    List<Widget> children = [];
    for (int i = 0; i < visiblePanes.length; i++) {
      final pane = visiblePanes[i];
      
      // Add pane
      children.add(_buildPane(pane));
      
      // Add divider/spacer between panes (but not after the last one)
      if (i < visiblePanes.length - 1) {
        children.add(_buildDivider(pane, visiblePanes[i + 1], spacing));
      }
    }
    
    Widget layout = widget.axis == Axis.horizontal
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
    
    // Apply max width constraint if specified
    if (widget.maxWidth != null) {
      layout = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth!),
        child: layout,
      );
    }
    
    // Center content if requested
    if (widget.centerContent && widget.maxWidth != null) {
      layout = Center(child: layout);
    }
    
    return layout;
  }

  Widget _buildPane(AdaptivePaneItem pane) {
    // Get custom width if pane has been resized
    final customWidth = _paneWidths[pane.id];
    
    // Create modified config with custom width if available
    final effectiveConfig = customWidth != null && pane.config.isFixed
        ? pane.config.copyWith(fixedWidth: customWidth)
        : pane.config;
    
    return PaneContainer(
      config: effectiveConfig,
      child: pane.child,
    );
  }

  Widget _buildDivider(AdaptivePaneItem leftPane, AdaptivePaneItem rightPane, double spacing) {
    // Check if either pane is resizable
    final isResizable = widget.resizableDividers && 
                       (leftPane.config.resizable || rightPane.config.resizable);
    
    if (!widget.showDividers && !isResizable) {
      // Just add spacing
      return SizedBox(
        width: widget.axis == Axis.horizontal ? spacing : null,
        height: widget.axis == Axis.vertical ? spacing : null,
      );
    }
    
    return PaneDivider(
      axis: widget.axis,
      width: widget.axis == Axis.horizontal ? spacing : null,
      height: widget.axis == Axis.vertical ? spacing : null,
      showDragHandle: isResizable,
      onDragUpdate: isResizable
          ? (delta) => _handlePaneResize(leftPane, rightPane, delta)
          : null,
      onDragEnd: isResizable
          ? () => _handlePaneResizeEnd(leftPane, rightPane)
          : null,
    );
  }

  void _handlePaneResize(AdaptivePaneItem leftPane, AdaptivePaneItem rightPane, double delta) {
    setState(() {
      // Resize the left pane if it's resizable and fixed
      if (leftPane.config.resizable && leftPane.config.isFixed) {
        final currentWidth = _paneWidths[leftPane.id] ?? leftPane.config.fixedWidth!;
        final newWidth = (currentWidth + delta).clamp(
          leftPane.config.minWidth ?? DeviceUtils.paneMinWidth,
          leftPane.config.maxWidth ?? DeviceUtils.paneMaxWidth,
        );
        _paneWidths[leftPane.id] = newWidth;
      }
      
      // Resize the right pane if it's resizable and fixed
      if (rightPane.config.resizable && rightPane.config.isFixed) {
        final currentWidth = _paneWidths[rightPane.id] ?? rightPane.config.fixedWidth!;
        final newWidth = (currentWidth - delta).clamp(
          rightPane.config.minWidth ?? DeviceUtils.paneMinWidth,
          rightPane.config.maxWidth ?? DeviceUtils.paneMaxWidth,
        );
        _paneWidths[rightPane.id] = newWidth;
      }
    });
  }

  void _handlePaneResizeEnd(AdaptivePaneItem leftPane, AdaptivePaneItem rightPane) {
    // Snap to standard widths
    setState(() {
      if (leftPane.config.resizable && leftPane.config.isFixed) {
        final currentWidth = _paneWidths[leftPane.id] ?? leftPane.config.fixedWidth!;
        _paneWidths[leftPane.id] = _snapToStandardWidth(currentWidth);
        
        // Notify callback
        widget.onPaneResized?.call(leftPane.id, _paneWidths[leftPane.id]!);
      }
      
      if (rightPane.config.resizable && rightPane.config.isFixed) {
        final currentWidth = _paneWidths[rightPane.id] ?? rightPane.config.fixedWidth!;
        _paneWidths[rightPane.id] = _snapToStandardWidth(currentWidth);
        
        // Notify callback
        widget.onPaneResized?.call(rightPane.id, _paneWidths[rightPane.id]!);
      }
    });
  }

  double _snapToStandardWidth(double width) {
    // Snap to nearest standard width: 280, 360, or 412
    if (width < 320) return DeviceUtils.paneMinWidth; // 280
    if (width < 386) return DeviceUtils.paneStandardWidth; // 360
    return DeviceUtils.paneMaxWidth; // 412
  }

  bool _isVisibleInWindowSize(WindowSizeClass minSize, WindowSizeClass currentSize) {
    final sizeOrder = [
      WindowSizeClass.compact,
      WindowSizeClass.medium,
      WindowSizeClass.expanded,
      WindowSizeClass.large,
      WindowSizeClass.extraLarge,
    ];
    
    final minIndex = sizeOrder.indexOf(minSize);
    final currentIndex = sizeOrder.indexOf(currentSize);
    
    return currentIndex >= minIndex;
  }
}
