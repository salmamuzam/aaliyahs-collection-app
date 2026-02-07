import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/profile_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/notification_screen.dart';

import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final user = userController.user;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Row(
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
            const Spacer(),
            _buildNotificationIcon(context, isDarkMode),
          ],
        );
      },
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
