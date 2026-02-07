import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';

class EditProfileImagePicker extends StatelessWidget {
  final File? localImageFile;
  final VoidCallback onPickImage;

  const EditProfileImagePicker({
    super.key,
    this.localImageFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<UserController>(
      builder: (context, userController, child) {
        final user = userController.user;
        final bool hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

        return Stack(
          children: [
            CircularProfileAvatar(
              '', // DO NOT pass assets here, it triggers network loading errors
              radius: 60,
              backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
              borderWidth: 2,
              borderColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              elevation: 5,
              onTap: onPickImage,
              child: localImageFile != null
                  ? Image.file(localImageFile!, fit: BoxFit.cover)
                  : (hasProfileImg
                       ? SmartImage(imageUrl: user.profilePhotoUrl)
                      : Initicon(
                          text: user?.name ?? 'Guest',
                          size: 120,
                          backgroundColor: isDarkMode ? aaliyahPrimaryColor.withValues(alpha: 0.8) : aaliyahPrimaryColor,
                        )),
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
      },
    );
  }
}
