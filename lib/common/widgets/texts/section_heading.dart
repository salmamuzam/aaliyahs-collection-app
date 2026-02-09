import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';




class SectionHeading extends StatelessWidget {
  final String title;               
  final String? actionLabel;           
  final VoidCallback? onActionPressed; 

  const SectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Title on left, button on right
      children: [
        // Heading text
        Flexible(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).extension<AaliyahTypography>()?.headlineSmallEmphasized ?? 
                     Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,  // Only show 1 line
              overflow: TextOverflow.ellipsis,  // Add ... if text is too long
            ),
          ),
        ),
        
        // Action button 
        if (actionLabel != null)
          Semantics(
            label: 'See all ${title.toLowerCase()}',
            button: true,
            child: TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
              
                foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
              ),
              child: Text(actionLabel!),
            ),
          ),
      ],
    );
  }
}
