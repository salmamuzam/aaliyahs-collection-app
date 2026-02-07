import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/profile_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/notification_screen.dart';

import 'package:aaliyahs_collection_estore/utils/formatters/text_formatter.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback? onRefresh;

  const HomeTopBar({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final user = userController.user;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: 'View profile',
              button: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: _buildProfileImage(context, user),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildWelcomeText(context, user)),
            const SizedBox(width: 4),
            if (onRefresh != null) ...[
              _buildRefreshButton(context),
              const SizedBox(width: 8),
            ],
            _buildNotificationIcon(context, isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Refresh content',
      button: true,
      hint: 'Updates the home page data',
      child: IconButton(
        onPressed: onRefresh,
        tooltip: 'Refresh',
        icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(12),
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasProfileImg = user?.profilePhotoUrl != null && user!.profilePhotoUrl.isNotEmpty;
    
    return CircularProfileAvatar(
      '', // DO NOT pass assets here, it triggers network loading errors
      radius: 20,
      backgroundColor: colorScheme.surfaceContainer,
      borderWidth: 1.5,
      borderColor: colorScheme.outlineVariant,
      child: hasProfileImg
          ? SmartImage(imageUrl: user!.profilePhotoUrl)
          : Initicon(
              text: user?.name ?? 'Guest',
              size: 50,
              backgroundColor: colorScheme.primary,
            ),
    );
  }

  Widget _buildWelcomeText(BuildContext context, dynamic user) {
    // Best Practice: Respect system font scale for accessibility
    // Clamp values prevent layout breakage on extreme text scale settings
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi, ${TFormatter.toSentenceCase(user?.firstName ?? 'Guest')} ${TFormatter.toSentenceCase(user?.lastName ?? '')}",
          style: (Theme.of(context).extension<AaliyahTypography>()?.editorialSmall ?? 
                  Theme.of(context).textTheme.titleLarge)?.copyWith(
            fontSize: (20 * textScale).clamp(16.0, 32.0), // reduced size for a cleaner mobile look
            color: colorScheme.onSurface,
          ),
          maxLines: 2, // Allow 2 lines for long names/large text
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Welcome back',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: (12 * textScale).clamp(10.0, 16.0),
             color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<NotificationController>(
      builder: (context, provider, child) {
        return Semantics(
          label: "Notifications${provider.unreadCount > 0 ? ', ${provider.unreadCount > 999 ? "999+" : provider.unreadCount}' : ''}",
          button: true,
          child: Badge(
            isLabelVisible: provider.unreadCount > 0,
            label: Text(provider.unreadCount > 999 ? '999+' : provider.unreadCount.toString()),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
              tooltip: 'Notifications',
              icon: Icon(
                Icons.notifications_none_rounded,
                color: colorScheme.onSurface,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.all(12),
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
        );
      },
    );
  }
}
