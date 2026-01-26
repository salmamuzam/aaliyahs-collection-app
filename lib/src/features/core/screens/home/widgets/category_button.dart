import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Premium color palette based on app's theme
    final Color selectedBg = aaliyahSecondaryColor;
    final Color unselectedBg = isDarkMode ? Colors.grey.shade800 : aaliyahLightColor;
    
    return Semantics(
      button: true,
      label: 'Category ${category.name}',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 85, // Slightly wider for better spacing
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Icon Container with premium styling
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? selectedBg : unselectedBg,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? aaliyahSecondaryColor.withValues(alpha: 0.4) 
                        : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: isSelected ? aaliyahPrimaryColor.withValues(alpha: 0.2) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0), // Remove padding to cover full
                    child: category.iconURL.isEmpty
                        ? Container(
                            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                            child: Icon(
                              Icons.category_outlined,
                              size: 24,
                              color: isSelected ? aaliyahPrimaryColor : Colors.grey,
                            ),
                          )
                        : category.iconURL.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: category.iconURL,
                                placeholder: (context, url) => FadeShimmer(
                                  height: 68,
                                  width: 68,
                                  radius: 34,
                                  highlightColor: isDarkMode
                                      ? const Color(0xff3a3e3f)
                                      : const Color(0xfff9f9f9),
                                  baseColor: isDarkMode
                                      ? const Color(0xff2d2f30)
                                      : const Color(0xffe6e6e6),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.category_outlined, 
                                  size: 24,
                                  color: isSelected ? aaliyahPrimaryColor : Colors.grey,
                                ),
                                fit: BoxFit.cover, // Cover full circle
                              )
                            : Image.asset(
                                category.iconURL,
                                fit: BoxFit.cover, // Cover full circle
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Category Name with dynamic styling
              Text(
                category.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                      letterSpacing: 0.2,
                        color: isSelected 
                           ? (isDarkMode ? aaliyahSecondaryColor : aaliyahPrimaryColor) 
                           : (isDarkMode ? aaliyahLightColor.withValues(alpha: 0.7) : aaliyahDarkColor.withValues(alpha: 0.87)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
