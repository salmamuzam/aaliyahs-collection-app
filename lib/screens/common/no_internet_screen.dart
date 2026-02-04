import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/util/helpers/responsive_helper.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Responsive.buildByOrientation(
            context: context,
            portrait: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  "No Internet Connection",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("Please check your internet settings."),
                const SizedBox(height: 30),
                const CircularProgressIndicator(),
              ],
            ),
            landscape: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                const SizedBox(width: 40),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "No Internet Connection",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text("Please check your internet settings."),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
