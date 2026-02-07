import 'dart:async';
import 'dart:io';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:toastification/toastification.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';

import 'package:aaliyahs_collection_estore/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';

import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/order_history_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/my_account_screen.dart';

// Profile Feature Widgets
import 'package:aaliyahs_collection_estore/features/personalization/screens/widgets/profile_header.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/widgets/profile_menu_item.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/widgets/profile_settings_bottom_sheet.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/widgets/profile_feedback_dialog.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/widgets/profile_accessibility_feedback_dialog.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/common/widgets/bottom_sheets/aaliyah_drag_handle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  // Sensor Features
  bool _isAutoBrightnessEnabled = false;
  StreamSubscription<int>? _lightSubscription;
  final Light _light = Light();

  late NavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _initBrightness();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // M3 Behavior: Scroll to top upon re-selection
      _navigationController = Provider.of<NavigationController>(context, listen: false);
      _navigationController.addListener(_handleNavSelection);
    });
  }

  void _handleNavSelection() {
    if (_navigationController.reselectedIndex == 4 && _scrollController.hasClients) {
      _scrollController.animateTo(
        0, 
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOutQuart
      );
    }
  }

  @override
  void dispose() {
    try {
      _navigationController.removeListener(_handleNavSelection);
    } catch (_) {}
    _lightSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initBrightness() async {
    try {
      await ScreenBrightness().application;
    } catch (_) {}
  }

  void _toggleAutoBrightness(bool value) {
    setState(() => _isAutoBrightnessEnabled = value);
    if (value) {
      _enableAutoBrightness();
    } else {
      _lightSubscription?.cancel();
    }
  }

  void _enableAutoBrightness() {
    try {
      _lightSubscription = _light.lightSensorStream.listen((lux) {
        double brightness = (lux / 1000).clamp(0.0, 1.0);
        ScreenBrightness().setApplicationScreenBrightness(brightness);
      });
    } catch (e) {
      debugPrint('Light Sensor Error: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Image Error'),
          description: Text('Could not pick image: $e'),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AaliyahDragHandle(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Profile photo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: const Text('Choose from gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.photo_camera_rounded, color: Theme.of(context).colorScheme.secondary),
                    ),
                    title: const Text('Take photo', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: DeviceUtils.maxContentWidth),
          child: CustomScrollView(
            key: const PageStorageKey<String>('profile_scroll'),
            controller: _scrollController,
            slivers: [
              // M3 Compact: Small App Bar instead of Large
              SliverToBoxAdapter(
                child: AaliyahSmallAppBar(
                  title: 'Profile',
                  subtitle: 'Manage your account',
                  leading: IconButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const NavigationMenu()),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back to home',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
                  child: Column(
                    children: [
                      SizedBox(height: DeviceUtils.getVerticalSize(20)),
                      ProfileHeader(localImageFile: _imageFile, onEditImage: _showImagePickerOptions),
                      SizedBox(height: DeviceUtils.getVerticalSize(30)),
                      _buildEditProfileButton(),
                      SizedBox(height: DeviceUtils.getVerticalSize(40)),
                      _buildMenuItems(),
                      SizedBox(height: DeviceUtils.getVerticalSize(40)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: 200,
      height: 48,
      child: FilledButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen())),
        child: const Text('Edit profile'),
      ),
    );
  }

  Widget _buildMenuItems() {
    final Color iconColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Semantics(
          label: 'Your orders',
          button: true,
          child: _buildSegmentedItem(
            context,
            ProfileMenuItem(
              title: 'Your orders',
              icon: Icons.shopping_bag_outlined,
              iconColor: iconColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen())),
            ),
          ),
        ),
        SizedBox(height: DeviceUtils.m3Padding(2)),
        Semantics(
          label: 'Settings',
          button: true,
          child: _buildSegmentedItem(
            context,
            ProfileMenuItem(
              title: 'Settings',
              icon: Icons.settings_rounded,
              iconColor: iconColor,
              onTap: () => _showSettingsSheet(),
            ),
          ),
        ),
        SizedBox(height: DeviceUtils.m3Padding(2)),
        Semantics(
          label: 'Send feedback',
          button: true,
          child: _buildSegmentedItem(
            context,
            ProfileMenuItem(
              title: 'Send feedback',
              icon: Icons.feedback_rounded,
              iconColor: iconColor,
              onTap: () => _showFeedbackDialog(),
            ),
          ),
        ),
        SizedBox(height: DeviceUtils.m3Padding(4)), // Slightly larger gap before destructive action
        Semantics(
          label: 'Log out',
          button: true,
          child: _buildSegmentedItem(
            context,
            ProfileMenuItem(
              title: 'Log out',
              icon: Icons.logout_rounded,
              iconColor: Theme.of(context).colorScheme.error,
              isLogout: true,
              onTap: () => _handleLogout(),
            ),
            isDestructive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedItem(BuildContext context, Widget child, {bool isDestructive = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: isDestructive 
            ? colorScheme.errorContainer.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium),
        border: Border.all(
          color: isDestructive 
              ? colorScheme.error.withValues(alpha: 0.2)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }


  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 640),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => ProfileSettingsBottomSheet(
        isAutoBrightnessEnabled: _isAutoBrightnessEnabled,
        onToggleAutoBrightness: (val) => _toggleAutoBrightness(val),
        onShowAccessibilityFeedback: () {
          Navigator.pop(context);
          _showAccessibilityFeedbackDialog();
        },
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final authController = Provider.of<AuthController>(dialogContext, listen: false);
              final userController = Provider.of<UserController>(dialogContext, listen: false);
              Navigator.pop(dialogContext);
              await authController.logout();
              userController.clearUser();
              
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  void _showAccessibilityFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => const AccessibilityFeedbackDialog(),
    );
  }
}
