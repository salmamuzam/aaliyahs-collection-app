import 'package:flutter/material.dart';

class AaliyahDragHandle extends StatelessWidget {
  final VoidCallback? onTap; 
  final String label;

  const AaliyahDragHandle({
    super.key,
    this.onTap,
    this.label = 'Dismiss',
  });

  @override
  Widget build(BuildContext context) {


    
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      button: true, 
      label: label, // Label the drag handle
      onTap: onTap ?? () => Navigator.pop(context),
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(4), 
     
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
