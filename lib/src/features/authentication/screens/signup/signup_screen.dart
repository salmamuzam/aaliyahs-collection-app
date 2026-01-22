import 'package:aaliyahs_collection_estore/src/common_widgets/form/form_header_widget.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/signup/widgets/signup_footer_widget.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import 'package:flutter/material.dart';

// Main Sign Up Screen

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // Scrollable
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(aaliyahDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormHeaderWidget(
                  image: aaliyahWelcomeScreenImage,
                  title: aaliyahSignUpTitle,
                  subTitle: aaliyahSignUpSubTitle,
                ),
                SignUpFormWidget(),
                SignUpFooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
