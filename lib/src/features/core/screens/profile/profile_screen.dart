import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/signup/signup_screen.dart';
import 'package:aaliyahs_collection_estore/utils/validators/validator.dart';
import 'package:flutter/material.dart';

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

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    _firstNameController.text = aaliyahProfileFname;
    _lastNameController.text = aaliyahProfileLname;
    _emailController.text = aaliyahProfileEmail;
    _passwordController.text = aaliyahProfilePassword;
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
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(
                        image: AssetImage(aaliyahProfileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: isDarkMode
                            ? aaliyahSecondaryColor
                            : aaliyahPrimaryColor,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: isDarkMode
                            ? aaliyahPrimaryColor
                            : aaliyahSecondaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Profile Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        label: Text(aaliyahFirstName),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      validator: AaliyahValidator.validateFirstName,
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),

                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        label: Text(aaliyahLastName),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      validator: AaliyahValidator.validateLastName,
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        label: Text(aaliyahEmail),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: AaliyahValidator.validateEmail,
                    ),
                    const SizedBox(height: aaliyahFormHeight - 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        label: const Text(aaliyahPassword),
                        prefixIcon: const Icon(Icons.password_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: isDarkMode
                                ? aaliyahSecondaryColor
                                : aaliyahPrimaryColor,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: AaliyahValidator.validatePassword,
                    ),
                    const SizedBox(height: aaliyahFormHeight),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final snackBar = SnackBar(
                              content: Text(
                                "Successfully updated!",
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? aaliyahPrimaryColor
                                          : aaliyahLightColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              duration: const Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(snackBar);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? aaliyahSecondaryColor
                              : aaliyahPrimaryColor,
                          side: BorderSide.none,
                        ),
                        child: Text(
                          aaliyahEditProfileText.toUpperCase(),
                          style: TextStyle(
                            color: isDarkMode
                                ? aaliyahPrimaryColor
                                : aaliyahSecondaryColor,
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
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
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? aaliyahSecondaryColor
                                    : aaliyahPrimaryColor,
                                elevation: 0,
                              ),
                              child: Text(
                                aaliyahSignOut.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? aaliyahPrimaryColor
                                      : aaliyahSecondaryColor,
                                ),
                              ),
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
}
