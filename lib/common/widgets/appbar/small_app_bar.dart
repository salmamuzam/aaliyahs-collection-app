import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Small App Bar with M3 Expressive Updates
/// Height: 64dp (updated from 56dp)
/// Features: Subtitle support, center-aligned text option, flexible elements
class AaliyahSmallAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const AaliyahSmallAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final access = Provider.of<AccessibilityController>(context);
    final bool reduceMotion = access.reduceMotion;

    return AppBar(
      toolbarHeight: 64.0, // M3 Expressive: Small app bar height
      scrolledUnderElevation: 0, // M3 Expressive: No shadow
      backgroundColor: backgroundColor ?? colorScheme.surface,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      bottom: bottom,
      title: subtitle != null
          ? Semantics(
              header: true,
              label: '$title. $subtitle',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24.0, // M3 Expressive: Larger title
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ).animate().fadeIn(
                duration: reduceMotion ? AMotion.durationShort4 : AMotion.durationEnterStandard,
                curve: AMotion.effects,
              ),
            )
          : Semantics(
              header: true,
              label: title,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24.0, // M3 Expressive: Larger title
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.2,
                ),
              ).animate().fadeIn(
                duration: reduceMotion ? AMotion.durationShort4 : AMotion.durationEnterStandard,
                curve: AMotion.effects,
              ),
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}
