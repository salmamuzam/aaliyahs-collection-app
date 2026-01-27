import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:aaliyahs_collection_estore/src/features/personalization/providers/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class ProfileHeader extends StatelessWidget {
  final File? localImageFile;
  final VoidCallback onEditImage;

  const ProfileHeader({
    super.key,
    this.localImageFile,
    required this.onEditImage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final String name = user?.name ?? "Guest";
        final String email = user?.email ?? "";
        final bool hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

        return Column(
          children: [
            _buildAvatar(isDarkMode, userProvider, hasProfileImg, user?.profilePhotoUrl),
            const SizedBox(height: 15),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(bool isDarkMode, UserProvider userProvider, bool hasProfileImg, String? profileUrl) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: localImageFile != null
                ? Image.file(localImageFile!, fit: BoxFit.cover)
                : (hasProfileImg
                    ? CachedNetworkImage(
                        imageUrl: profileUrl!,
                        fit: BoxFit.cover,
                        httpHeaders: userProvider.token != null ? {'Authorization': 'Bearer ${userProvider.token}'} : null,
                      )
                    : Image.asset(aaliyahProfileImage, fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onEditImage,
            child: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: aaliyahPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
