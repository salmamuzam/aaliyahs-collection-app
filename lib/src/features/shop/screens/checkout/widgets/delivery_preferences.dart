import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:flutter/material.dart';

// Android Time Picker
// Aligns with Material 3 Design

class DeliveryPreferencesSection extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final CheckoutColors colors;
  final VoidCallback onTimeSelected;

  const DeliveryPreferencesSection({
    super.key,
    required this.selectedTime,
    required this.colors,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTimeSelected,
            icon: const Icon(Icons.access_time, color: Colors.white),
            label: Text(
              selectedTime != null
                  ? "Delivery Time: ${selectedTime!.format(context)}"
                  : "Select Delivery Time",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Selected time display
        if (selectedTime != null) _buildTimeConfirmation(context),
      ],
    );
  }

  Widget _buildTimeConfirmation(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.secondaryColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: colors.secondaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            "Delivery time set to ${selectedTime!.format(context)}",
            style: TextStyle(
              color: colors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
