import 'package:aaliyahs_collection_estore/features/authentication/screens/login/widgets/login_footer_widget.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/widgets/login_form_widget.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/widgets/login_header_widget.dart';
import 'package:flutter/material.dart';

// Main Login Screen

import 'package:aaliyahs_collection_estore/common/widgets/misc/keyboard_dismisser.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return KeyboardDismisser(
      child: SafeArea(
        child: Scaffold(
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: sizingInformation.screenSize.height - 
                                  MediaQuery.of(context).padding.top - 
                                  MediaQuery.of(context).padding.bottom - 
                                  MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Padding(
                        padding: DeviceUtils.getPadding(all: DeviceUtils.m3Padding(5)), 
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              SizedBox(height: DeviceUtils.m3Padding(10)), 
                              // Header
                              LoginHeaderWidget(size: size),
                              SizedBox(height: DeviceUtils.m3Padding(3)), 
                              
                              // Form
                              const LoginForm(),
                              
                              SizedBox(height: DeviceUtils.m3Padding(5)), 
                              
                              // Footer
                              const LoginFooterWidget(),
                              SizedBox(height: DeviceUtils.m3Padding(5)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
