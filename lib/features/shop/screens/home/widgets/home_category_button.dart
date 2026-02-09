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
    

    final Color selectedBg = colorScheme.primary;
    final Color unselectedBg = colorScheme.surfaceContainerHighest;

    return Consumer<AccessibilityController>(
      builder: (context, access, _) {
   
        const BorderRadius adaptiveRadius = BorderRadius.only(
                topLeft: Radius.circular(TUIConstants.shapeRadiusXL), 
                topRight: Radius.circular(TUIConstants.shapeRadiusMedium), 
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
                padding: EdgeInsets.symmetric(vertical: DeviceUtils.m3Padding(1)), 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: AMotion.durationStationaryEmphasized,
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
                      child: ClipRRect( 
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
                                : SmartImage(
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
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: DeviceUtils.m3Padding(1)), 
                 
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
                            fontSize: 12, 
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
