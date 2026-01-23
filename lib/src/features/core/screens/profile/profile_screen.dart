import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/utils/validators/validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:cached_network_image/cached_network_image.dart';

// This is the profile page
// Validation works if customer needs to update profile information
// You can also click log out to go back to Login page as well

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // Removed password controllers as requested

  bool _isEditing = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _usernameController.text = user.username;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

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
          aaliyahProfileText,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(aaliyahDefaultSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.user;
                  final hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

                  return Stack(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: hasProfileImg
                            ? CachedNetworkImage(
                                imageUrl: user.profilePhotoUrl,
                                httpHeaders: userProvider.token != null
                                    ? {'Authorization': 'Bearer ${userProvider.token}'}
                                    : null,
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                  ),
                                ),
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => const Image(
                                  image: AssetImage(aaliyahProfileImage),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Image(image: AssetImage(aaliyahProfileImage), fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: isDarkMode ? aaliyahSecondaryColor : aaliyahPrimaryColor,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: isDarkMode ? aaliyahPrimaryColor : aaliyahSecondaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),

              // Profile Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      readOnly: !_isEditing,
                      decoration: const InputDecoration(
                        label: Text(aaliyahFirstName),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      validator: AaliyahValidator.validateFirstName,
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),

                    // Username Field (Added)
                    TextFormField(
                      controller: _usernameController,
                      readOnly: true, 
                      decoration: const InputDecoration(
                        label: Text(aaliyahUsername),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),

                    TextFormField(
                      controller: _lastNameController,
                      readOnly: !_isEditing,
                      decoration: const InputDecoration(
                        label: Text(aaliyahLastName),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      validator: AaliyahValidator.validateLastName,
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),

                    TextFormField(
                      controller: _emailController,
                      readOnly: !_isEditing,
                      decoration: const InputDecoration(
                        label: Text(aaliyahEmail),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: AaliyahValidator.validateEmail,
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),


                    const SizedBox(height: aaliyahFormHeight - 20),

                    // Password Field (Display only/masked)
                    TextFormField(
                      initialValue: "********", 
                      readOnly: true,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        label: const Text(aaliyahPassword),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),


                    const SizedBox(height: aaliyahFormHeight),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isEditing) {
                            if (_formKey.currentState!.validate()) {
                              // Perform update logic here
                              setState(() {
                                _isEditing = false;
                              });
                              toastification.show(
                                context: context,
                                type: ToastificationType.success,
                                style: ToastificationStyle.fillColored,
                                title: const Text("Success"),
                                description: const Text("Profile Updated Successfully!"),
                                autoCloseDuration: const Duration(seconds: 3),
                              );
                            }
                          } else {
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? aaliyahSecondaryColor : aaliyahPrimaryColor,
                          side: BorderSide.none,
                        ),
                        child: Text(
                          _isEditing ? "SAVE PROFILE" : "EDIT PROFILE",
                          style: TextStyle(
                            color: isDarkMode ? aaliyahPrimaryColor : aaliyahSecondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: aaliyahFormHeight),

                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                return ElevatedButton(
                                  onPressed: () => _showDeleteConfirmation(context, userProvider),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade900,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    aaliyahDelete.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: aaliyahLightColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Consumer2<AuthProvider, UserProvider>(
                              builder: (context, authProvider, userProvider, child) {
                                return ElevatedButton(
                                  onPressed: () async {
                                    await authProvider.logout();
                                    userProvider.clearUser();
                                    if (!context.mounted) return;
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode ? aaliyahSecondaryColor : aaliyahPrimaryColor,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    aaliyahSignOut.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? aaliyahPrimaryColor : aaliyahSecondaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: aaliyahFormHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
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
