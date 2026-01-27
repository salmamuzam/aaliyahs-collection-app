import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/utils/device/device_utility.dart';

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible( // Protection against overflow on small screens
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: DeviceUtils.getFontSize(22), // Responsive font size
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
