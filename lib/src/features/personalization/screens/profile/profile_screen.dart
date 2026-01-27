import 'dart:async';
import 'dart:io';
import 'package:aaliyahs_collection_estore/src/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:toastification/toastification.dart';
import 'package:quickalert/quickalert.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/providers/auth_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/order_history_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/my_account_screen.dart';

// Profile Feature Widgets
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/widgets/profile_header.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Sensor Features
  bool _isAutoBrightnessEnabled = false;
  StreamSubscription<int>? _lightSubscription;
  final Light _light = Light();

  @override
  void initState() {
    super.initState();
    _initBrightness();
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
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
      debugPrint("Light Sensor Error: $e");
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
          title: const Text("Image Error"),
          description: Text("Could not pick image: $e"),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NavigationMenu()),
          ),
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
        ),
        title: Text(
          "My Profile",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
             fontWeight: FontWeight.bold,
             fontSize: DeviceUtils.getFontSize(24),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: DeviceUtils.getPadding(horizontal: 25.0),
        child: Column(
          children: [
            SizedBox(height: DeviceUtils.getVerticalSize(20)),
            ProfileHeader(localImageFile: _imageFile, onEditImage: _showImagePickerOptions),
            SizedBox(height: DeviceUtils.getVerticalSize(30)),
            _buildEditProfileButton(),
            SizedBox(height: DeviceUtils.getVerticalSize(40)),
            _buildMenuItems(isDarkMode),
            SizedBox(height: DeviceUtils.getVerticalSize(40)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: 200,
      height: 45,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen())),
        style: ElevatedButton.styleFrom(
          backgroundColor: aaliyahPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.5)),
          elevation: 0,
        ),
        child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMenuItems(bool isDarkMode) {
    final Color iconColor = isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor;

    return Column(
      children: [
        ProfileMenuItem(
          title: "My Orders",
          icon: Icons.shopping_bag_outlined,
          iconColor: iconColor,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen())),
        ),
        const SizedBox(height: 20),
        ProfileMenuItem(
          title: "Settings",
          icon: Icons.settings_outlined,
          iconColor: iconColor,
          onTap: () => _showSettingsSheet(),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        ProfileMenuItem(
          title: "Logout",
          icon: Icons.logout,
          iconColor: Colors.red,
          isLogout: true,
          onTap: () => _handleLogout(),
        ),
      ],
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(aaliyahSettings, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(),
              SwitchListTile(
                value: _isAutoBrightnessEnabled,
                title: Text(aaliyahAutoBrightness),
                subtitle: Text(aaliyahAutoBrightnessSub),
                secondary: const Icon(Icons.brightness_auto),
                onChanged: (val) {
                  setSheetState(() => _toggleAutoBrightness(val));
                  HapticFeedback.selectionClick();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Are you sure you want to logout?',
      onConfirmBtnTap: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        Navigator.pop(context);
        await authProvider.logout();
        userProvider.clearUser();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
    );
  }
}
