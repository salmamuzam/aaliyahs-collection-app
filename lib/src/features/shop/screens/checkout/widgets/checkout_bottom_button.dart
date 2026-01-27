import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';

class CheckoutBottomButton extends StatelessWidget {
  final int currentStep;
  final int selectedPaymentIndex;
  final VoidCallback onPressed;

  const CheckoutBottomButton({
    super.key,
    required this.currentStep,
    required this.selectedPaymentIndex,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String label = _getButtonLabel();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? aaliyahDarkColor : Colors.white,
        border: Border(
          top: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: aaliyahPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TUIConstants.buttonRadius)
              ),
              elevation: 0,
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  String _getButtonLabel() {
    switch (currentStep) {
      case 0:
        return "Next: Payment";
      case 1:
        return "Next: Summary";
      case 2:
        return selectedPaymentIndex == 0 ? "Place Order" : "Pay Now";
      default:
        return "";
    }
  }
}
