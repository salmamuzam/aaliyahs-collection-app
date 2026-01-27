import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/notification_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/profile_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/home/notification_screen.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/utils/formatters/text_formatter.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                _buildWelcomeText(context, user),
              ],
            ),
            _buildNotificationIcon(context, isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildProfileImage(dynamic user, bool isDarkMode) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        border: Border.all(color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: user?.profilePhotoUrl != null && user!.profilePhotoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user.profilePhotoUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.person),
              )
            : const Icon(Icons.person),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context, dynamic user) {
    // Best Practice: Respect system font scale for accessibility
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2), // Use padding instead of fixed sizedbox
          child: Text(
            "Hi, ${TFormatter.toSentenceCase(user?.firstName ?? 'Guest')} ${TFormatter.toSentenceCase(user?.lastName ?? '')}",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (14 * textScale).clamp(12.0, 24.0),
                ),
          ),
        ),
        Text(
          "Welcome",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: (12 * textScale).clamp(10.0, 18.0),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context, bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
              icon: Icon(
                Icons.notifications_outlined,
                size: 28,
                color: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
              ),
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${provider.unreadCount}',
                    style: const TextStyle(
                      color: aaliyahLightColor,
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
