import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/screens/profile/profile_screen.dart';
import 'package:aaliyahs_collection_estore/screens/shop/home/notification_screen.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/util/formatters/text_formatter.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:aaliyahs_collection_estore/widgets/smart_image.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final user = userController.user;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: _buildProfileImage(user, isDarkMode),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildWelcomeText(context, user)),
            const SizedBox(width: 8),
            _buildNotificationIcon(context, isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildProfileImage(dynamic user, bool isDarkMode) {
    final bool hasProfileImg = user?.profilePhotoUrl != null && user!.profilePhotoUrl.isNotEmpty;
    
    return CircularProfileAvatar(
      '', // DO NOT pass assets here, it triggers network loading errors
      radius: 25,
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      borderWidth: 2,
      borderColor: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
      showInitialTextAbovePicture: false,
      child: hasProfileImg
          ? SmartImage(imageUrl: user!.profilePhotoUrl)
          : Initicon(
              text: user?.name ?? "Guest",
              size: 50,
              backgroundColor: isDarkMode ? aaliyahPrimaryColor.withValues(alpha: 0.8) : aaliyahPrimaryColor,
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
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            "Hi, ${TFormatter.toSentenceCase(user?.firstName ?? 'Guest')} ${TFormatter.toSentenceCase(user?.lastName ?? '')}",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (20 * textScale).clamp(16.0, 30.0), // Responsive + Accessible
                  color: colorScheme.onSurface,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          "Welcome back",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: (14 * textScale).clamp(12.0, 18.0),
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
        return Stack(
          children: [
            // M3 Standard: Min touch target size 48x48 handled by IconButton default padding
            IconButton( 
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurface,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.all(12), // Visual padding
                minimumSize: const Size(48, 48), // Explicit minimum touch target
              ),
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${provider.unreadCount}',
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
