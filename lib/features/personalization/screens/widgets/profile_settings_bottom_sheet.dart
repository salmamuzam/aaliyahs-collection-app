import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/common/widgets/texts/section_heading.dart';
import 'package:aaliyahs_collection_estore/data/services/notification_service.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';
import 'package:aaliyahs_collection_estore/common/widgets/menus/expressive_menu.dart';
import 'package:aaliyahs_collection_estore/common/widgets/bottom_sheets/aaliyah_drag_handle.dart';

class ProfileSettingsBottomSheet extends StatelessWidget {
  final bool isAutoBrightnessEnabled;
  final Function(bool) onToggleAutoBrightness;
  final VoidCallback onShowAccessibilityFeedback;

  const ProfileSettingsBottomSheet({
    super.key,
    required this.isAutoBrightnessEnabled,
    required this.onToggleAutoBrightness,
    required this.onShowAccessibilityFeedback,
  });

  @override
  Widget build(BuildContext context) {
    
    return StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AaliyahDragHandle(),
            Row(
              children: [
                 Icon(Icons.settings_suggest_rounded, color: Theme.of(context).colorScheme.primary),
                 const SizedBox(width: 12),
                 Text(aaliyahSettings, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: DeviceUtils.m3Padding(2)),
            
            SizedBox(height: DeviceUtils.m3Padding(6)),
            AaliyahDividerTheme.fullWidthDivider(context, height: 1),
            SizedBox(height: DeviceUtils.m3Padding(2)),
            const SectionHeading(title: 'Accessibility'),
            Consumer<AccessibilityController>(
              builder: (context, controller, _) => Column(
                children: [
                  ListTile(
                    title: const Text('Reduce Motion'),
                    subtitle: const Text('Minimizes animations for a calmer experience'),
                    trailing: Switch(
                      value: controller.reduceMotion,
                      onChanged: (value) => controller.setReduceMotion(value),
                    ),
                  ),
                  ListTile(
                    title: const Text('High Contrast'),
                    subtitle: const Text('Increases contrast for better visibility'),
                    trailing: Switch(
                      value: controller.highContrast,
                      onChanged: (value) => controller.setHighContrast(value),
                    ),
                  ),
                  ListTile(
                    title: const Text('Show narrator guidance'),
                    subtitle: const Text('Shows semantic boundaries [Debug]'),
                    trailing: Switch(
                      value: controller.showSemanticsDebugger,
                      onChanged: (value) => controller.toggleSemanticsDebugger(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium),
              ),
              child: ListTile(
                leading: Icon(Icons.campaign_rounded, color: Theme.of(context).colorScheme.tertiary),
                title: const Text('Accessibility feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Help co-design a barrier-free app', style: TextStyle(fontSize: 12)),
                onTap: onShowAccessibilityFeedback,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(header: true, child: const Text('General', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium),
              ),
              child: SwitchListTile(
                value: isAutoBrightnessEnabled,
                activeThumbColor: aaliyahPrimaryColor,
                title: const Text(aaliyahAutoBrightness, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(aaliyahAutoBrightnessSub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                secondary: const Icon(Icons.brightness_auto_rounded),
                onChanged: (val) {
                  setSheetState(() => onToggleAutoBrightness(val));
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            const SizedBox(height: 8),
            Consumer<AccessibilityController>(
              builder: (context, controller, _) {
                final String currentLang = controller.locale?.languageCode == 'ar' ? 'Arabic (RTL)' : 'English';
                final String currentVal = controller.locale?.languageCode ?? 'system';
                
                return AaliyahExpressiveMenu(
                  selectedValue: currentVal,
                  onSelected: (value) {
                    if (value == 'system') {
                      controller.setLocale(null);
                    } else {
                      controller.setLocale(Locale(value));
                    }
                  },
                  items: const [
                    AaliyahMenuItem(label: 'English', value: 'en', leadingIcon: Icons.language_rounded),
                    AaliyahMenuItem(label: 'Arabic (RTL Test)', value: 'ar', leadingIcon: Icons.translate_rounded),
                    AaliyahMenuItem(label: 'System default', value: 'system', leadingIcon: Icons.settings_rounded),
                  ],
                  child: ListTile(
                    title: const Text('App language'),
                    subtitle: Text(currentLang),
                    leading: const Icon(Icons.language_rounded),
                  ),
                );
              }
            ),
            const SizedBox(height: 16),
            Semantics(header: true, child: const Text('Developer Options', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 8),
            ListTile(
              tileColor: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium)),
              leading: Icon(Icons.notification_important_rounded, color: Theme.of(context).colorScheme.error),
              title: const Text('Test push notification', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Click to trigger a test notification', style: TextStyle(fontSize: 12)),
              onTap: () {
                NotificationService.showOrderNotification(
                  title: 'Test Shipped! \u{1F69A}',
                  body: "Aaliyah's Collection: Your order #12345 is on its way!",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
