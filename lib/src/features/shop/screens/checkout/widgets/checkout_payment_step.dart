import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class CheckoutPaymentStep extends StatelessWidget {
  final int selectedPaymentIndex;
  final Function(int) onPaymentSelected;

  const CheckoutPaymentStep({
    super.key,
    required this.selectedPaymentIndex,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Methods",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentCard(
            index: 0,
            title: "Cash on Delivery",
            subtitle: "Pay when you receive",
            icon: Icons.payments_outlined,
            isDarkMode: isDarkMode,
          ),
          _buildPaymentCard(
            index: 1,
            title: "Stripe",
            subtitle: "Pay securely with Stripe",
            icon: Icons.credit_card_outlined,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final bool isSelected = selectedPaymentIndex == index;
    final Color highlightColor = isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor;

    return GestureDetector(
      onTap: () => onPaymentSelected(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? highlightColor : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? highlightColor : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? highlightColor : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
