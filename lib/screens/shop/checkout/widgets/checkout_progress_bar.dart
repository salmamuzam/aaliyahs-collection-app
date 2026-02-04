import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';

class CheckoutProgressBar extends StatelessWidget {
  final int currentStep;

  const CheckoutProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<String> titles = ["Address", "Payment", "Summary"];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: isDarkMode ? Colors.white12 : Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: List.generate(titles.length, (index) {
          final bool isCompleted = index < currentStep;
          final bool isActive = index == currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Circle indicator
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isActive
                              ? aaliyahPrimaryColor
                              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive ? Colors.white : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        titles[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive
                              ? aaliyahPrimaryColor
                              : (isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
                // Line connector (except for last item)
                if (index < titles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      color: isCompleted
                          ? aaliyahPrimaryColor
                          : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
