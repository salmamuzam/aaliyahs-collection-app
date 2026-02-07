import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/category_model.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CategoryButton extends StatelessWidget {
  final CategoryModel category;
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isHighContrast = colorScheme.outline == Colors.black87 || colorScheme.outline == Colors.white;
    
    // Theme-driven colors with accessibility fallbacks
    final Color selectedBg = colorScheme.primary;
    final Color unselectedBg = colorScheme.surfaceContainerHighest;

    return Consumer<AccessibilityController>(
      builder: (context, access, _) {
        // M3 Expressive: Shape Morphing configuration
        // Tension: Asymmetrical shape for unselected, morphs to circular when selected
        const BorderRadius adaptiveRadius = BorderRadius.only(
                topLeft: Radius.circular(TUIConstants.shapeRadiusXL), // 28
                topRight: Radius.circular(TUIConstants.shapeRadiusMedium), // 12
                bottomLeft: Radius.circular(TUIConstants.shapeRadiusMedium),
                bottomRight: Radius.circular(TUIConstants.shapeRadiusXL),
              );

        return Semantics(
          button: true,
          label: 'Category ${category.name}',
          selected: isSelected,
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: DeviceUtils.m3Padding(1)), // Reduced to 4dp
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: AMotion.durationStationaryEmphasized, // 500ms
                      curve: AMotion.easingEmphasized,
                      height: 68,
                      width: 68,
                      decoration: BoxDecoration(
                        borderRadius: adaptiveRadius,
                        color: isSelected ? selectedBg : unselectedBg,
                        boxShadow: [
                          if (!isHighContrast)
                            BoxShadow(
                              color: isSelected 
                                ? colorScheme.primary.withValues(alpha: 0.3) 
                                : Colors.black.withValues(alpha: 0.05),
                              blurRadius: isSelected ? 12 : 8,
                              offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
                            )
                        ],
                        border: Border.all(
                          color: isSelected 
                              ? (isHighContrast ? colorScheme.onSurface : colorScheme.primary.withValues(alpha: 0.2)) 
                              : (isHighContrast ? colorScheme.outline : Colors.transparent),
                          width: isHighContrast ? 2.0 : 1.5,
                        ),
                      ),
                      child: ClipRRect( // M3: Support shape morph clipping
                        borderRadius: adaptiveRadius,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTap, 
                            borderRadius: adaptiveRadius,
                            child: category.iconURL.isEmpty
                                ? Container(
                                    color: Colors.transparent,
                                    child: Icon(
                                      Icons.category_outlined,
                                      size: 24,
                                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : category.iconURL.startsWith('http')
                                    ? SmartImage(
                                        imageUrl: category.iconURL,
                                        placeholder: Shimmer.fromColors(
                                          baseColor: colorScheme.surfaceContainerHighest,
                                          highlightColor: colorScheme.surfaceContainer,
                                          child: Container(
                                            height: 68,
                                            width: 68,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: adaptiveRadius,
                                            ),
                                          ),
                                        ),
                                        errorWidget: Icon(
                                          Icons.category_rounded, 
                                          size: 24,
                                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                        ),
                                      )
                                    : Image.asset(
                                        category.iconURL,
                                        fit: BoxFit.cover,
                                        cacheWidth: 200,
                                      ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: DeviceUtils.m3Padding(1)), // 4dp (Reduced from 8dp)
                    // Category Name with dynamic styling
                    AutoSizeText(
                      category.displayName,
                      maxLines: 1,
                      minFontSize: 8,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: isSelected 
                        ? (Theme.of(context).extension<AaliyahTypography>()?.labelLargeEmphasized ?? 
                           Theme.of(context).textTheme.labelLarge)?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 12, // Maintain design size but use emphasized weight
                          )
                        : Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
