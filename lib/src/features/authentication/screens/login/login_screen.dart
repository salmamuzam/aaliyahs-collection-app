import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_footer_widget.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_form_widget.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/login_header_widget.dart';
import 'package:flutter/material.dart';

// Main Login Screen

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        // Scrollable
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(aaliyahDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 01
                LoginHeaderWidget(size: size),
                // Section 02
                LoginForm(),
                // Section 03
                LoginFooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
