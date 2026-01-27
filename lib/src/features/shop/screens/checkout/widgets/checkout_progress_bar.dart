import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class CheckoutProgressBar extends StatelessWidget {
  final int currentStep;

  const CheckoutProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color inactiveColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final Color activeColor = isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        children: [
          _buildNode(0, Icons.location_on_outlined, "Address", activeColor, inactiveColor),
          _buildLine(0, activeColor, inactiveColor),
          _buildNode(1, Icons.credit_card_outlined, "Payment", activeColor, inactiveColor),
          _buildLine(1, activeColor, inactiveColor),
          _buildNode(2, Icons.assignment_outlined, "Summary", activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildNode(int index, IconData icon, String label, Color active, Color inactive) {
    final bool isActive = currentStep >= index;
    final Color color = isActive ? active : inactive;

    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10, 
            color: color, 
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int index, Color active, Color inactive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          height: 2,
          color: currentStep > index ? active : inactive,
        ),
      ),
    );
  }
}
