import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';

class ProfileMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color effectiveIconColor = widget.isLogout ? colorScheme.error : widget.iconColor;
    final Color textColor = widget.isLogout ? colorScheme.error : colorScheme.onSurface;

    return Semantics(
      label: widget.title,
      button: true,
      hint: widget.isLogout ? 'Double tap to log out of your account' : 'Double tap to open ${widget.title}',
      child: ListTile(
        onTap: widget.onTap,
        leading: AnimatedContainer(
          duration: AMotion.durationShort4,
          curve: AMotion.easingStandard,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: effectiveIconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(22), // Circle
          ),
          child: Icon(widget.icon, color: effectiveIconColor, size: 22),
        ),
        title: Text(
          widget.title,
          style: (Theme.of(context).extension<AaliyahTypography>()?.titleMediumEmphasized ??
                 Theme.of(context).textTheme.titleMedium)?.copyWith(
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        trailing: widget.isLogout 
          ? null 
          : AnimatedContainer(
              duration: AMotion.durationShort4,
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: colorScheme.onSurfaceVariant),
            ),
      ),
    );
  }
}
