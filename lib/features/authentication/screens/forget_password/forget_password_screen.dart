import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/common/widgets/form/auth_text_field.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/login_screen.dart';


class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            return Stack(
              children: [
                // Content
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: sizingInformation.screenSize.height - 
                                MediaQuery.of(context).padding.top - 
                                MediaQuery.of(context).padding.bottom - 
                                MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Padding(
                      padding: DeviceUtils.getPadding(all: 20),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 150), 
                            
                            // Group 01: Header
                            Column(
                              children: [
                                Text(
                                  aaliyahForgetPasswordTitle,
                                  style: (Theme.of(context).extension<AaliyahTypography>()?.editorialLarge ?? 
                                          Theme.of(context).textTheme.headlineLarge)?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20), 
                                Text(
                                  aaliyahForgetPasswordSubTitle,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 35), 
                            
                            // Group 02: Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AuthTextField(
                                    controller: _emailController,
                                    label: aaliyahEmail,
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email address.';
                                      }
                                      // Check for valid email format
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return aaliyahInvalidEmailSubTitle; 
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 25), 
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Reset link sent to your email')),
                                          );
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                                          );
                                        }
                                      },
                                      child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 35), 
                            
                            // Group 03: Footer
                            const Column(
                              children: [
                                Text(
                                  "Don't Remember Your Email?",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10), 
                             
                              ],
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                              child: const Text(
                                '$aaliyahSignup for a New Account',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 10, 
                  left: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ),
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
