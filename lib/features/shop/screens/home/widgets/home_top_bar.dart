import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/profile_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/notification_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/favorites/favorites_screen.dart';

import 'package:aaliyahs_collection_estore/common/widgets/images/user_profile_image.dart';

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
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
      ),
      child: UserProfileImage(
        imageUrl: user?.profilePhotoUrl,
        name: user?.name ?? 'Guest',
        size: 40,
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wishlist Icon
        Consumer<FavoriteController>(
          builder: (context, provider, child) {
            return Semantics(
              label: "Wishlist${provider.favorites.isNotEmpty ? ', ${provider.favorites.length} items' : ''}",
              button: true,
              child: Badge(
                isLabelVisible: provider.favorites.isNotEmpty,
                label: Text(provider.favorites.length > 999 ? '999+' : provider.favorites.length.toString()),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FavoriteScreen()),
                    );
                  },
                  tooltip: 'Wishlist',
                  icon: Icon(
                    Icons.favorite_border_rounded,
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
        ),
        const SizedBox(width: 8), // Gap between icons

        // Notification Icon
        Consumer<NotificationController>(
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
        ),
      ],
    );
  }
}
