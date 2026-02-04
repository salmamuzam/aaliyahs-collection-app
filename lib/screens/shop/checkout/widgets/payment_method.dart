import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:flutter/material.dart';

// Only cash on delivery option for now because card payment is out of the scope of my assignment
// Plans to implement card payment using Stripe in MAD 2 Assignment



class PaymentMethodSection extends StatelessWidget {
  final bool cashOnDelivery;
  final CheckoutColors colors;
  final Function(bool?) onChanged;

  // Controllers removed as per request

  const PaymentMethodSection({
    super.key,
    required this.cashOnDelivery,
    required this.colors,
    required this.onChanged,
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
                      color: !cashOnDelivery ? aaliyahPrimaryColor.withValues(alpha: 0.05) : Colors.transparent,
                      border: Border.all(
                        color: !cashOnDelivery ? aaliyahPrimaryColor : Colors.grey.shade300,
                        width: !cashOnDelivery ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: false, // false = Card
                          activeColor: aaliyahPrimaryColor,
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
                      color: cashOnDelivery ? aaliyahPrimaryColor.withValues(alpha: 0.05) : Colors.transparent,
                      border: Border.all(
                        color: cashOnDelivery ? aaliyahPrimaryColor : Colors.grey.shade300,
                        width: cashOnDelivery ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: true, // true = COD
                          activeColor: aaliyahPrimaryColor,
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
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: aaliyahPrimaryColor.withValues(alpha: 0.05),
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: aaliyahPrimaryColor.withValues(alpha: 0.3)),
             ),
             child: const Row(
               children: [
                 Icon(Icons.lock_outline, color: aaliyahPrimaryColor),
                 SizedBox(width: 12),
                 Expanded(child: Text("You will be redirected to Stripe's secure payment sheet to complete your purchase.")),
               ],
             ),
           )
        ] else ...[
           const SizedBox(height: 16),
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: aaliyahPrimaryColor.withValues(alpha: 0.05),
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: aaliyahPrimaryColor.withValues(alpha: 0.3)),
             ),
             child: const Row(
               children: [
                 Icon(Icons.info_outline, color: aaliyahPrimaryColor),
                 SizedBox(width: 12),
                 Expanded(child: Text("You will pay when the order arrives.")),
               ],
             ),
           )
        ],
      ],
    );
  }
}

