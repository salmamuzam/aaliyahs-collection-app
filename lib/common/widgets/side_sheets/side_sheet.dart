import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';

/// Shows a Modal Side Sheet adhering to Material 3 specifications.
/// 
/// Specs:
/// - Corner Radius: 16dp (TUIConstants.shapeRadiusLarge)
/// - Background: Surface Container Low
/// - Elevation: 1 (Modal)
/// - Animation: Slide from Side (Standard Easing)
/// - Scrim: Standard Scrim Color
Future<T?> showModalSideSheet<T>({
  required BuildContext context,
  required Widget body,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  SideSheetSide side = SideSheetSide.right,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? colorScheme.scrim.withValues(alpha: 0.32),
    transitionDuration: AMotion.durationEnterEmphasized, // 400ms
    pageBuilder: (context, animation, secondaryAnimation) {
      return Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: 'Side sheet',
        explicitChildNodes: true,
        child: Align(
          alignment: side == SideSheetSide.right ? Alignment.centerRight : Alignment.centerLeft,
          child: Material(
            color: colorScheme.surfaceContainerLow,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: side == SideSheetSide.right ? const Radius.circular(16) : Radius.zero,
                right: side == SideSheetSide.left ? const Radius.circular(16) : Radius.zero,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400), // Standard Side Sheet max width
                child: body,
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final Offset begin = side == SideSheetSide.right ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
      return SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: AMotion.easingEmphasizedDecelerate), // M3 Standard
        ),
        child: child,
      );
    },
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}

enum SideSheetSide { left, right }

/// A Standard Side Sheet widget for use in large screen layouts.
/// 
/// Specs:
/// - Max Width: 400dp
/// - Color: Surface (or Surface Container Low if elevated)
/// - Border: Outline Variant (if needed for separation)
class StandardSideSheet extends StatelessWidget {
  final Widget child;
  final double width;
  final bool showBorder;
  final SideSheetSide side;
  final Color? backgroundColor;

  const StandardSideSheet({
    super.key,
    required this.child,
    this.width = 400,
    this.showBorder = true,
    this.side = SideSheetSide.right,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface, // Standard Side Sheet background (Surface per specs)
        border: showBorder ? Border(
          left: side == SideSheetSide.right ? BorderSide(color: colorScheme.outlineVariant) : BorderSide.none,
          right: side == SideSheetSide.left ? BorderSide(color: colorScheme.outlineVariant) : BorderSide.none,
        ) : null,
      ),
      child: child,
    );
  }
}

/// A standard header for Side Sheets adhering to M3 padding specs.
/// 
/// Specs:
/// - Start/End Padding: 24dp
/// - Padding between elements: 12dp
/// - Title Style: Headline Small
class SideSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const SideSheetHeader({
    super.key,
    required this.title,
    this.onClose,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      // Padding spec: 24dp start/end, 12dp between top elements
      // Vertical padding isn't strictly defined but visual examples show spacing.
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), 
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
              tooltip: 'Back',
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12), // Padding between top elements
          ],
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (actions != null) ...[
             const SizedBox(width: 12),
             ...actions!,
          ],
          if (onClose != null) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: 'Close',
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}

/// A standard footer for Side Sheets containing action buttons.
/// 
/// Specs:
/// - Height: 72dp (implied minimum with padding)
/// - Top Padding: 16dp
/// - Bottom Padding: 24dp
/// - Start/End Padding: 24dp
/// - Alignment: Start (Left) with 8dp gap
class SideSheetFooter extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const SideSheetFooter({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    // Interleave with SizedBox(width: 8)
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(const SizedBox(width: 8));
        }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Footer should size to content? Or fill? Usually fill but items align left.
        mainAxisAlignment: mainAxisAlignment,
        children: spacedChildren,
      ),
    );
  }
}
