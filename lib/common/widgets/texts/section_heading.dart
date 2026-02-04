import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/util/device/device_utility.dart';

// ============================================================================
// SECTION HEADING - Reusable Heading with Optional Action Button
// ============================================================================
// This widget creates a heading with an optional "View All" or "See More" button
// Used throughout the app to separate different sections
//
// Example:
// "Best Sellers" [View All →]
// "Categories"   [See More →]
// ============================================================================

class SectionHeading extends StatelessWidget {
  final String title;                  // The heading text (e.g., "Best Sellers")
  final String? actionLabel;           // Optional button text (e.g., "View All")
  final VoidCallback? onActionPressed; // What happens when button is pressed

  const SectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Row puts title and button side by side
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Title on left, button on right
      children: [
        // Heading text
        Flexible(  // Flexible prevents text overflow on small screens
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: DeviceUtils.getFontSize(22),  // Responsive font size based on screen
            ),
            maxLines: 1,  // Only show 1 line
            overflow: TextOverflow.ellipsis,  // Add ... if text is too long
          ),
        ),
        
        // Action button (only show if actionLabel is provided)
        if (actionLabel != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              // White text in dark mode, default color in light mode
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
