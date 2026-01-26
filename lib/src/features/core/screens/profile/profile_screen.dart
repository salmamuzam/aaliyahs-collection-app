import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/order_history_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/my_account_screen.dart';

// This is the profile page
// Validation works if customer needs to update profile information
// You can also click log out to go back to Login page as well

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Auto Brightness
  bool _isAutoBrightnessEnabled = false;
  StreamSubscription<int>? _lightSubscription;
  final Light _light = Light();

  @override
  void dispose() {
    _lightSubscription?.cancel();
    super.dispose();
  }

  void _toggleAutoBrightness(bool value) {
    setState(() {
      _isAutoBrightnessEnabled = value;
    });
    if (value) {
      _enableAutoBrightness();
    } else {
      _disableAutoBrightness();
    }
  }

  void _enableAutoBrightness() {
    try {
      _lightSubscription = _light.lightSensorStream.listen((lux) {
        // Adjust normalization factor (e.g. 1000 lux = full brightness)
        double brightness = (lux / 1000).clamp(0.0, 1.0);
        ScreenBrightness().setApplicationScreenBrightness(brightness);
      });
    } catch (e) {
      debugPrint("Light Sensor Error: $e");
    }
  }

  void _disableAutoBrightness() {
    _lightSubscription?.cancel();
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
         toastification.show(
            context: context,
            type: ToastificationType.error, 
            style: ToastificationStyle.fillColored,
            title: const Text("Image Error"),
            description: Text("Could not pick image: $e"),
         );
      }
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initBrightness();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize any other data if needed
    });
  }

  Future<void> _initBrightness() async {
    try {
      await ScreenBrightness().application;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          ),
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
        ),
        title: Text(
          "My Profile",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Section
              _buildProfileHeader(context, isDarkMode),
              const SizedBox(height: 30),
              
              // Edit Profile Button
              _buildEditProfileButton(context, isDarkMode),
              const SizedBox(height: 40),

              // Menu Items
              _buildProfileMenuItem(
                context,
                title: "My Orders",
                icon: Icons.shopping_bag_outlined,
                iconColor: aaliyahPrimaryColor,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildProfileMenuItem(
                context,
                title: "Settings",
                icon: Icons.settings_outlined,
                iconColor: aaliyahPrimaryColor,
                isDarkMode: isDarkMode,
                onTap: () {
                  showModalBottomSheet(context: context, builder: (ctx) => _buildSettingsSheet(ctx));
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              _buildProfileMenuItem(
                context,
                title: "Logout",
                icon: Icons.logout,
                iconColor: Colors.red,
                isDarkMode: isDarkMode,
                isLogout: true,
                onTap: () => _handleLogout(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDarkMode) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final name = user?.name ?? "Coding with T";
        final email = user?.email ?? "superadmin@codingwitht.com";
        final hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : (hasProfileImg
                            ? CachedNetworkImage(
                                imageUrl: user.profilePhotoUrl,
                                fit: BoxFit.cover,
                                httpHeaders: userProvider.token != null 
                                  ? {'Authorization': 'Bearer ${userProvider.token}'} 
                                  : null,
                              )
                            : Image.asset(aaliyahProfileImage, fit: BoxFit.cover)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showPicker(context),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: aaliyahPrimaryColor, // Using primary maroon
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditProfileButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: 200,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyAccountScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: aaliyahPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.5)),
          elevation: 0,
        ),
        child: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLogout ? Colors.red.withValues(alpha: 0.1) : iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isLogout ? Colors.red : iconColor, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLogout ? Colors.red : (isDarkMode ? Colors.white : Colors.grey.shade700),
              ),
            ),
          ),
          if (!isLogout)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Are you sure you want to logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        await authProvider.logout();
        userProvider.clearUser();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }

  // void _showDeleteConfirmation(BuildContext context, UserProvider userProvider) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Delete Account"),
  //         content: const Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("CANCEL"),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               final result = await userProvider.deleteAccount();
  //               if (!context.mounted) return;
  //               Navigator.pop(context); // Close dialog
  //
  //               if (result['status'] == 'success') {
  //                 // Logout from AuthProvider as well
  //                 Provider.of<AuthProvider>(context, listen: false).logout();
  //                 
  //                 Navigator.pushAndRemoveUntil(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => const LoginScreen()),
  //                   (route) => false,
  //                 );
  //               } else {
  //                 toastification.show(
  //                   context: context,
  //                   type: ToastificationType.error, 
  //                   style: ToastificationStyle.fillColored,
  //                   title: const Text("Error"),
  //                   description: Text(result['message']),
  //                   autoCloseDuration: const Duration(seconds: 3),
  //                 );
  //               }
  //             },
  //             child: const Text("DELETE", style: TextStyle(color: Colors.red)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  Widget _buildSettingsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aaliyahSettings,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Sensor Feature: Auto Brightness
          StatefulBuilder(
             builder: (context, setStateSheet) {
               return SwitchListTile(
                 title: Text(aaliyahAutoBrightness),
                 subtitle: Text(aaliyahAutoBrightnessSub),
                 value: _isAutoBrightnessEnabled,
                 secondary: const Icon(Icons.brightness_auto),
                 onChanged: (val) {
                   setStateSheet(() {
                      _toggleAutoBrightness(val);
                   });
                   HapticFeedback.selectionClick();
                 },
               );
             }
          ),
          const Divider(),
           ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(aaliyahDeleteAccount, style: const TextStyle(color: Colors.red)),
            onTap: () {
               Navigator.pop(context);
               final userProvider = Provider.of<UserProvider>(context, listen: false);
               _showDeleteConfirmation(context, userProvider);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserProvider userProvider) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Delete Account',
      text: 'Are you sure you want to permanently delete your account?',
      confirmBtnText: 'Yes, Delete',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        final result = await userProvider.deleteAccount();
        if (!context.mounted) return;

        if (result['status'] == 'success') {
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            title: const Text("Error"),
            description: Text(result['message']),
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
    );
  }
}
