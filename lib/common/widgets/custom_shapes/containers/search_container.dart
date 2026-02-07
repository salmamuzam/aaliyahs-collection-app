import 'package:flutter/material.dart';
// removed device_utility.dart

class SearchContainer extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool showBackground, showBorder, showMic;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const SearchContainer({
    super.key,
    required this.text,
    this.icon = Icons.search,
    this.showBackground = true,
    this.showBorder = true,
    this.showMic = false,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Semantics(
        label: text,
        button: true,
        hint: 'Double tap to activate search',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            // Removed fixed width to respect parent constraints (e.g. max 720dp)
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: showBackground
                  ? isDarkMode
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surfaceContainerHigh 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(28), // M3 Stadium/Pill Shape (56dp height / 2)
              border: showBorder 
                  ? Border.all(color: colorScheme.outlineVariant) 
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (showMic) Icon(Icons.mic_none_rounded, color: colorScheme.onSurfaceVariant, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
