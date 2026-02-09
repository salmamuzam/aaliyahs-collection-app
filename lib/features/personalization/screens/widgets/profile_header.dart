import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';

import 'package:aaliyahs_collection_estore/common/widgets/images/user_profile_image.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';


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
        final String name = user?.name ?? 'Guest';
        final String email = user?.email ?? '';
        final bool hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

        return Column(
          children: [
            _buildAvatar(context, isDarkMode, userController, hasProfileImg, user?.profilePhotoUrl),
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

  Widget _buildAvatar(BuildContext context, bool isDarkMode, UserController userController, bool hasProfileImg, String? profileUrl) {
    final String name = userController.user?.name ?? 'Guest';
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onEditImage,
      child: Stack(
        alignment: Alignment.center,
        children: [

          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(52),
                topRight: Radius.circular(52),
                bottomLeft: Radius.circular(52),
                bottomRight: Radius.circular(20), 
              ),
            ),
          ),
          
     
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(48),
                topRight: Radius.circular(48),
                bottomLeft: Radius.circular(48),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: isDarkMode ? colorScheme.outlineVariant : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(TUIConstants.shapeRadiusXXL),
                topRight: Radius.circular(TUIConstants.shapeRadiusXXL),
                bottomLeft: Radius.circular(TUIConstants.shapeRadiusXXL),
                bottomRight: Radius.circular(TUIConstants.shapeRadiusMedium),
              ),
              child: localImageFile != null
                  ? Image.file(localImageFile!, fit: BoxFit.cover)
                  : UserProfileImage(
                      imageUrl: profileUrl,
                      name: name,
                      size: 120,
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : colorScheme.primaryContainer,
                      textColor: isDarkMode ? Colors.white : colorScheme.onPrimaryContainer,
                      fontSize: 48,
                    ),
            ),
          ),
          
 
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium), 
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Icon(Icons.edit_outlined, color: colorScheme.onPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
