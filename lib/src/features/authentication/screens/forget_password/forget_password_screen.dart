import 'package:aaliyahs_collection_estore/src/common_widgets/form/form_header_widget.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/sizes.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: aaliyahDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormHeaderWidget(
                  image: aaliyahWelcomeScreenImage,
                  title: aaliyahForgetPasswordTitle,
                  subTitle: aaliyahForgetPasswordSubTitle,
                ),
                const SizedBox(height: aaliyahFormHeight),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text(aaliyahEmail),
                          hintText: aaliyahEmail,
                          prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE5EDEF) : null),
                          border: const OutlineInputBorder(),
                          focusedBorder: Theme.of(context).brightness == Brightness.dark 
                              ? const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5EDEF), width: 2.0))
                              : null,
                        ),
                      ),
                      const SizedBox(height: aaliyahFormHeight),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Reset link sent to your email")),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text("RESET PASSWORD", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
