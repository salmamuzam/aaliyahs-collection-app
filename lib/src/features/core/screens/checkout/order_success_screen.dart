import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:aaliyahs_collection_estore/bottom_nav.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderAmount;

  const OrderSuccessScreen({super.key, required this.orderAmount});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Professional Lottie Animation
              Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_yupejt8v.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 24),
              Text(
                "Order Placed Successfully!",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Thank you for shopping with Aaliyah's Collection. Your payment of $orderAmount has been received.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const BottomNavBar()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7643),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
