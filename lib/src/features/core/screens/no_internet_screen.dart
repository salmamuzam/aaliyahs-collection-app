import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
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
            // Loading indicator implies "waiting for connection"
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
