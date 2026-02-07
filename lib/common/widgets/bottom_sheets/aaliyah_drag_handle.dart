import 'package:flutter/material.dart';

class AaliyahDragHandle extends StatelessWidget {
  final VoidCallback? onTap; // Optional override, defaults to pop
  final String label;

  const AaliyahDragHandle({
    super.key,
    this.onTap,
    this.label = 'Dismiss',
  });

  @override
  Widget build(BuildContext context) {
    // M3 Specs:
    // Touch target: 48dp height minimum
    // Handle size: 32dp x 4dp
    // Color: OnSurfaceVariant (Active/Focus should be visible)
    
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      button: true, // Role: Button
      label: label, // Label the drag handle
      onTap: onTap ?? () => Navigator.pop(context),
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(4), // Focus highlight shape roughly around handle area? Or full width?
        // Full width tap target is better for "Top 48dp portion" spec.
        child: SizedBox(
          width: double.infinity,
          height: 48, 
          child: Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
