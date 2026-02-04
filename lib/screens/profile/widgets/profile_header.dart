import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:aaliyahs_collection_estore/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';

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

    return Consumer<UserController>(
      builder: (context, userController, child) {
        final user = userController.user;
        final String name = user?.name ?? "Guest";
        final String email = user?.email ?? "";
        final bool hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

        return Column(
          children: [
            _buildAvatar(isDarkMode, userController, hasProfileImg, user?.profilePhotoUrl),
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

  Widget _buildAvatar(bool isDarkMode, UserController userController, bool hasProfileImg, String? profileUrl) {
    final String name = userController.user?.name ?? "Guest";
    
    return Stack(
      children: [
        CircularProfileAvatar(
          profileUrl ?? '',
          radius: 60,
          backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
          borderWidth: 2,
          borderColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          elevation: 5,
          cacheImage: true,
          showInitialTextAbovePicture: false,
          onTap: onEditImage,
          child: localImageFile != null
              ? Image.file(localImageFile!, fit: BoxFit.cover)
              : (!hasProfileImg
                  ? Initicon(
                      text: name,
                      size: 120,
                      backgroundColor: isDarkMode ? aaliyahPrimaryColor.withValues(alpha: 0.8) : aaliyahPrimaryColor,
                    )
                  : null), // CircularProfileAvatar handles networks image automatically if profileUrl is provided
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: IgnorePointer(
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: aaliyahPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
