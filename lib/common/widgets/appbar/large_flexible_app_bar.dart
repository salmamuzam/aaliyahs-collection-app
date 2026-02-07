import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Large Flexible App Bar - M3 Expressive
/// Height: 152dp (reduced from previous 176dp large app bar)
/// Features: Larger title, subtitle support, flexible alignment, more space for imagery
class AaliyahLargeFlexibleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool pinned;
  final bool floating;
  final Color? backgroundColor;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const AaliyahLargeFlexibleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.pinned = true,
    this.floating = false,
    this.backgroundColor,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final access = Provider.of<AccessibilityController>(context);
    final bool reduceMotion = access.reduceMotion;

    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      expandedHeight: 152.0, // M3 Expressive: Large flexible height
      toolbarHeight: 64.0,
      scrolledUnderElevation: 0, // M3 Expressive: No shadow
      backgroundColor: backgroundColor ?? colorScheme.surface,
      leading: leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: flexibleSpace ?? FlexibleSpaceBar(
        centerTitle: centerTitle,
        titlePadding: EdgeInsets.only(
          left: centerTitle ? 0 : (leading != null ? 56 : 16),
          right: 16,
          bottom: 16,
        ),
        title: Semantics(
          header: true,
          label: subtitle != null ? '$title. $subtitle' : title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 32.0, // M3 Expressive: Larger title for large
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.2,
                ),
                maxLines: 3, // M3 Expressive: Text wrapping support
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ).animate().fadeIn(
            duration: reduceMotion ? AMotion.durationShort4 : AMotion.durationEnterStandard,
            curve: AMotion.effects,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(152.0);
}
