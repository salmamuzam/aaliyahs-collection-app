import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';

/// A Material Design 3 Expressive Menu implementation.
/// 
/// Follows November 2025 M3 Expressive Specs:
/// - Shapes: M3 Extra Large (28dp) corners for containers.
/// - Color (Standard): Surface-based. Background: surfaceContainerLow. Selected: TertiaryContainer/OnTertiaryContainer.
/// - Color (Vibrant): Tertiary-based. Background: tertiaryContainer. Selected: Tertiary/OnTertiary.
/// - Layout: Supports supportingText, trailingText, and Dividers.
class AaliyahExpressiveMenu extends StatelessWidget {
  final List<dynamic> items; // AaliyahMenuItem or Widget (for Dividers)
  final String? selectedValue;
  final List<String>? selectedValues; // For multi-select
  final ValueChanged<String>? onSelected;
  final Widget child;
  final bool isVibrant;
  final double? width;
  final bool useGaps;
  final bool closeOnSelect;

  const AaliyahExpressiveMenu({
    super.key,
    required this.items,
    required this.child,
    this.selectedValue,
    this.selectedValues,
    this.onSelected,
    this.isVibrant = false,
    this.width,
    this.useGaps = false,
    this.closeOnSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color bgColor = isVibrant 
        ? colorScheme.tertiaryContainer 
        : colorScheme.surfaceContainerLow;

    return MenuAnchor(
      clipBehavior: Clip.antiAlias,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(bgColor),
        elevation: const WidgetStatePropertyAll(3),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusXL), // 28dp
          ),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: useGaps ? 4 : 8)),
        minimumSize: WidgetStatePropertyAll(Size(width ?? 240, 0)),
        maximumSize: width != null ? WidgetStatePropertyAll(Size(width!, double.infinity)) : null,
      ),
      builder: (context, controller, childWidget) {
        return InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium),
          child: child,
        );
      },
      menuChildren: items.map<Widget>((item) {
        if (item is! AaliyahMenuItem) {
          if (item is Widget) {
            return ExcludeSemantics(child: item);
          }
          return const SizedBox.shrink();
        }

        final bool isSelected = selectedValues != null 
            ? selectedValues!.contains(item.value)
            : selectedValue == item.value;
        
        final Color selectedBg = isVibrant ? colorScheme.tertiary : colorScheme.tertiaryContainer;
        final Color selectedFg = isVibrant ? colorScheme.onTertiary : colorScheme.onTertiaryContainer;
        final Color unselectedFg = isVibrant 
            ? colorScheme.onTertiaryContainer.withValues(alpha: item.enabled ? 1.0 : 0.38) 
            : colorScheme.onSurface.withValues(alpha: item.enabled ? 1.0 : 0.38);

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: useGaps ? 3.0 : 0.0,
            horizontal: useGaps ? 8.0 : 0.0,
          ),
          child: MenuItemButton(
            onPressed: item.enabled ? () {
              if (onSelected != null) onSelected!(item.value);
            } : null,
            closeOnActivate: closeOnSelect,
            style: MenuItemButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              minimumSize: const Size(0, 48), // M3 Spec: List item height 48dp
              shape: useGaps 
                  ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)) 
                  : (isSelected ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)) : null),
              foregroundColor: isSelected ? selectedFg : unselectedFg,
              backgroundColor: isSelected ? (item.enabled ? selectedBg : selectedBg.withValues(alpha: 0.12)) : Colors.transparent,
            ),
            leadingIcon: item.leadingIcon != null 
                ? ExcludeSemantics(child: Icon(item.leadingIcon, size: 24)) 
                : null,
            trailingIcon: ExcludeSemantics(child: _buildTrailing(item, isSelected, selectedFg, colorScheme)),
            child: Semantics(
              label: '${item.label}${item.supportingText != null ? ". ${item.supportingText}" : ""}${isSelected ? ". Selected" : ""}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  if (item.supportingText != null)
                    Text(
                      item.supportingText!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected 
                            ? selectedFg.withValues(alpha: 0.8) 
                            : colorScheme.onSurfaceVariant.withValues(alpha: item.enabled ? 1.0 : 0.38),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget? _buildTrailing(AaliyahMenuItem item, bool isSelected, Color selectedFg, ColorScheme colorScheme) {
    if (item.badge != null) {
      return Badge(
        label: Text(item.badge!),
        backgroundColor: isSelected ? colorScheme.onTertiaryContainer : colorScheme.primary,
        textColor: isSelected ? colorScheme.tertiaryContainer : colorScheme.onPrimary,
      );
    }
    
    if (item.trailingText != null) {
      return Text(
        item.trailingText!, 
        style: TextStyle(
          fontSize: 12, 
          color: isSelected ? selectedFg : colorScheme.onSurfaceVariant
        )
      );
    }

    if (isSelected) {
      return const Icon(Icons.check_circle_rounded, size: 18);
    }

    return null;
  }
}

class AaliyahMenuItem {
  final String label;
  final String value;
  final String? supportingText;
  final String? trailingText;
  final String? badge;
  final IconData? leadingIcon;
  final bool enabled;

  const AaliyahMenuItem({
    required this.label,
    required this.value,
    this.supportingText,
    this.trailingText,
    this.badge,
    this.leadingIcon,
    this.enabled = true,
  });
}



