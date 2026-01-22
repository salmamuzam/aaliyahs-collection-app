import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:flutter/material.dart';

// This is the categories that is displayed on the home page

class CategoryButton extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? (isSelected ? aaliyahPrimaryColor : aaliyahSecondaryColor)
        : (isSelected ? aaliyahSecondaryColor : aaliyahPrimaryColor);

    final textColor = isDarkMode
        ? (isSelected ? Colors.white : Colors.black)
        : (isSelected ? Colors.black : Colors.white);

    final borderColor = isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          color: backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                height: 20,
                width: 15,
                margin: const EdgeInsets.only(right: 2),
                child: Image.asset(category.iconURL, fit: BoxFit.contain),
              ),
              // Text
              Text(
                category.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
