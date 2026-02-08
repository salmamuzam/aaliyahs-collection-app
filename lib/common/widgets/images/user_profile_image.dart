import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';

class UserProfileImage extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;

  const UserProfileImage({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 50,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.primaryContainer;
    final txtColor = textColor ?? colorScheme.onPrimaryContainer;

    // 1. If no image URL, show Initials
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildIniticon(bgColor, txtColor);
    }

    // 2. Try loading image with SmartImage
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: SmartImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          errorWidget: _buildIniticon(bgColor, txtColor),
          placeholder: _buildIniticon(bgColor, txtColor),
        ),
      ),
    );
  }

  Widget _buildIniticon(Color bgColor, Color txtColor) {
    return Initicon(
      text: name.isNotEmpty ? name : 'User',
      size: size,
      backgroundColor: bgColor,
      style: TextStyle(color: txtColor, fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}
