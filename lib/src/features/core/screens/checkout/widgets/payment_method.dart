import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:flutter/material.dart';

// Only cash on delivery option for now because card payment is out of the scope of my assignment
// Plans to implement card payment using Stripe in MAD 2 Assignment

import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/custom_text_field.dart';

class PaymentMethodSection extends StatelessWidget {
  final bool cashOnDelivery;
  final CheckoutColors colors;
  final Function(bool?) onChanged;
  final TextEditingController? cardNameController;
  final TextEditingController? cardNumberController;
  final TextEditingController? expiryController;
  final TextEditingController? cvvController;

  const PaymentMethodSection({
    super.key,
    required this.cashOnDelivery,
    required this.colors,
    required this.onChanged,
    this.cardNameController,
    this.cardNumberController,
    this.expiryController,
    this.cvvController,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 24),
        
        // Payment Types Row
        RadioGroup<bool>(
          groupValue: cashOnDelivery,
          onChanged: (val) => onChanged(val),
          child: Row(
            children: [
              // Card Option
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !cashOnDelivery ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
                      border: Border.all(
                        color: !cashOnDelivery ? Colors.blue : Colors.grey.shade300,
                        width: !cashOnDelivery ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: false, // false = Card
                          activeColor: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text("Card Payment", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // COD Option (Using Paypal design slot)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cashOnDelivery ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
                      border: Border.all(
                        color: cashOnDelivery ? Colors.blue : Colors.grey.shade300,
                        width: cashOnDelivery ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: true, // true = COD
                          activeColor: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text("Cash On Delivery", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Icons Row
        if (!cashOnDelivery) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCardIcon("assets/images/visa.png"), // Placeholder paths if assets don't exist, will fallback
              const SizedBox(width: 8),
              _buildCardIcon("assets/images/mastercard.png"),
              const SizedBox(width: 8),
              _buildCardIcon("assets/images/amex.png"),
            ],
          ),
          const SizedBox(height: 24),
          
          // Card Details Form
          CustomTextField(
            label: "Cardholder's Name", 
            placeholder: "Enter Cardholder's Name", 
            controller: cardNameController ?? TextEditingController(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: "Card Number", 
            placeholder: "Enter Card Number", 
            controller: cardNumberController ?? TextEditingController(),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "Expiry", 
                  placeholder: "MM/YY", 
                  controller: expiryController ?? TextEditingController(),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "CVV", 
                  placeholder: "CVV", 
                  controller: cvvController ?? TextEditingController(),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ] else ...[
           const SizedBox(height: 16),
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Colors.blue.withValues(alpha: 0.05),
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
             ),
             child: const Row(
               children: [
                 Icon(Icons.info_outline, color: Colors.blue),
                 SizedBox(width: 12),
                 Expanded(child: Text("You will pay when the order arrives.")),
               ],
             ),
           )
        ],
      ],
    );
  }
  
  Widget _buildCardIcon(String path) {
    // Placeholder icon widget since we don't have the assets
    return Container(
      width: 40,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.credit_card, size: 16, color: Colors.grey),
    );
  }
}

