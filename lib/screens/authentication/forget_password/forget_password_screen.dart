
import 'package:aaliyahs_collection_estore/util/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:aaliyahs_collection_estore/util/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/login/widgets/auth_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Stack(
              children: [
                // Subtle Top Background Design
                Positioned(
                  top: DeviceUtils.getVerticalSize(-50),
                  left: DeviceUtils.getHorizontalSize(-50),
                  child: Container(
                    height: DeviceUtils.getVerticalSize(200),
                    width: DeviceUtils.getHorizontalSize(200),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? aaliyahLightColor.withValues(alpha: 0.05)
                          : aaliyahPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: DeviceUtils.getVerticalSize(50),
                  right: DeviceUtils.getHorizontalSize(-30),
                  child: Container(
                    height: DeviceUtils.getVerticalSize(150),
                    width: DeviceUtils.getHorizontalSize(150),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? aaliyahLightColor.withValues(alpha: 0.05)
                          : aaliyahSecondaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AaliyahSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AaliyahSizes.appBarHeight),
                        
                        // Centered Header
                        Text(
                          aaliyahForgetPasswordTitle,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          aaliyahForgetPasswordSubTitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AaliyahSizes.spaceBtwSections),
                        
                        // Form
                        Form(
                          child: Column(
                            children: [
                              AuthTextField(
                                controller: _emailController,
                                label: aaliyahEmail,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AaliyahSizes.spaceBtwSections),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Reset link sent to your email")),
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AaliyahSizes.spaceBtwSections),
                        
                        // Footer Section
                        Text(
                          "Don't remember your email?",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Contact Us at aaliyahscollection@gmail.com",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.teal, // Optional: make email stand out
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
