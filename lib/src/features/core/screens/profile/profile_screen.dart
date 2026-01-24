import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
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
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/addresses_screen.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "My Profile",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: EdgeInsets.all(Responsive.getPadding(context)),
            child: Column(
              children: [
                // Profile Image
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.user;
                    final hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (hasProfileImg
                                    ? CachedNetworkImageProvider(
                                        user.profilePhotoUrl,
                                        headers: userProvider.token != null 
                                          ? {'Authorization': 'Bearer ${userProvider.token}'} 
                                          : null
                                      )
                                    : const AssetImage(aaliyahProfileImage) as ImageProvider),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _showPicker(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black12, blurRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_outlined, color: Colors.black54, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Menu Items
                _buildProfileMenuItem(
                  context,
                  title: aaliyahMyAccount,
                  icon: Icons.person_outline,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildProfileMenuItem(
                  context,
                  title: aaliyahNotifications,
                  icon: Icons.notifications_none_outlined,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildProfileMenuItem(
                  context,
                  title: "My Orders",
                  icon: Icons.shopping_bag_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileMenuItem(
                  context,
                  title: "My Addresses",
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddressesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileMenuItem(
                  context,
                  title: aaliyahSettings,
                  icon: Icons.settings_outlined,
                  onTap: () {
                    showModalBottomSheet(context: context, builder: (ctx) => _buildSettingsSheet(ctx));
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileMenuItem(
                  context,
                  title: aaliyahHelpCenter,
                  icon: Icons.help_outline,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildProfileMenuItem(
                  context,
                  title: aaliyahSignOut,
                  icon: Icons.logout,
                  onTap: () {
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
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF7643), size: 22),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF757575),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(aaliyahDeleteAccount),
          content: Text(aaliyahDeleteAccountConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () async {
                final result = await userProvider.deleteAccount();
                if (!context.mounted) return;
                Navigator.pop(context); // Close dialog

                if (result['status'] == 'success') {
                  // Logout from AuthProvider as well
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
              child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
