import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/common/widgets/bottom_sheets/aaliyah_drag_handle.dart';

class ProfileSettingsBottomSheet extends StatelessWidget {
  final bool isAutoBrightnessEnabled;
  final Function(bool) onToggleAutoBrightness;

  const ProfileSettingsBottomSheet({
    super.key,
    required this.isAutoBrightnessEnabled,
    required this.onToggleAutoBrightness,
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
          ],
        ),
      ),
    );
  }
}
