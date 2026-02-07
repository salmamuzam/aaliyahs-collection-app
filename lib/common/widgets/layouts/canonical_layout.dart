import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

/// A wrapper that implements the Material Design 3 Feed Canonical Layout.
/// It ensures content stays centered with appropriate margins and a maximum 
/// width on large screens to prevent horizontal stretching.
class CanonicalLayout extends StatelessWidget {
  final Widget child;
  final bool useSliver;
  final double? maxWidth;

  const CanonicalLayout({
    super.key,
    required this.child,
    this.useSliver = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Determine layout properties based on M3 Window Size Classes
    final double margin = DeviceUtils.m3Margin;
    final double effectiveMaxWidth = maxWidth ?? DeviceUtils.maxContentWidth;

    if (useSliver) {
      return SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: _calculateSidePadding(context, effectiveMaxWidth, margin)),
            sliver: child,
          ),
        ],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: margin),
          child: child,
        ),
      ),
    );
  }

  double _calculateSidePadding(BuildContext context, double maxWidth, double minMargin) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= maxWidth) {
      return minMargin / 2; // Split half as Padding in CustomScrollView is often applied to the whole sliver list
    }
    return (screenWidth - maxWidth) / 2 + minMargin;
  }
}
