import 'dart:async';
import 'dart:io';
import 'package:aaliyahs_collection_estore/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:toastification/toastification.dart';
import 'package:quickalert/quickalert.dart';

import 'package:aaliyahs_collection_estore/screens/navigation/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/util/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/screens/profile/order_history_screen.dart';
import 'package:aaliyahs_collection_estore/screens/profile/my_account_screen.dart';

// Profile Feature Widgets
import 'package:aaliyahs_collection_estore/screens/profile/widgets/profile_header.dart';
import 'package:aaliyahs_collection_estore/screens/profile/widgets/profile_menu_item.dart';

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Profile Photo", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_camera, color: Colors.green),
                ),
                title: const Text('Capture from Camera', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 120,
            leading: IconButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavigationMenu()),
              ),
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text("Profile"), // "My Profile" -> "Profile" (Neutral/clean)
            scrolledUnderElevation: 3,
            backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
            surfaceTintColor: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
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
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: 200,
      height: 48,
      child: FilledButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen())),
        child: const Text("Edit profile"), // Sentence case
      ),
    );
  }

  Widget _buildMenuItems(bool isDarkMode) {
    final Color iconColor = isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor;

    return Card(
      elevation: 0,
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            title: "Your orders", // "My Orders" -> "Your orders" (User-centric)
            icon: Icons.shopping_bag_outlined,
            iconColor: iconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen())),
          ),
          Divider(height: 1, indent: 20, endIndent: 20, color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
          ProfileMenuItem(
            title: "Settings",
            icon: Icons.settings_outlined,
            iconColor: iconColor,
            onTap: () => _showSettingsSheet(),
          ),
          Divider(height: 1, indent: 20, endIndent: 20, color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
          ProfileMenuItem(
            title: "Send feedback", // Sentence case
            icon: Icons.feedback_outlined,
            iconColor: iconColor,
            onTap: () => _showFeedbackDialog(),
          ),
          Divider(height: 1, indent: 20, endIndent: 20, color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
          ProfileMenuItem(
            title: "Log out", // "Logout" -> "Log out" (Verb phrase)
            icon: Icons.logout,
            iconColor: Colors.red,
            isLogout: true,
            onTap: () => _handleLogout(),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   const Icon(Icons.settings_suggest_outlined, color: aaliyahPrimaryColor),
                   const SizedBox(width: 12),
                   Text(aaliyahSettings, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black26 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  value: _isAutoBrightnessEnabled,
                  activeThumbColor: aaliyahPrimaryColor,
                  title: Text(aaliyahAutoBrightness, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(aaliyahAutoBrightnessSub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  secondary: const Icon(Icons.brightness_auto),
                  onChanged: (val) {
                    setSheetState(() => _toggleAutoBrightness(val));
                    HapticFeedback.selectionClick();
                  },
                ),
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
      text: 'Are you sure you want to log out?',
      onConfirmBtnTap: () async {
        final authController = Provider.of<AuthController>(context, listen: false);
        final userController = Provider.of<UserController>(context, listen: false);
        Navigator.pop(context);
        await authController.logout();
        userController.clearUser();
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

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Your feedback matters"), // "We value your voice" -> User-centric header
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Help improve this experience. Share your thoughts, ideas, or report issues."), // Removed "us/we"
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: "Type your feedback here...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Simulate submission
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Thank you! Your feedback helps us build for everyone.")),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
