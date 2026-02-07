import 'package:flutter/material.dart';


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
    final colorScheme = Theme.of(context).colorScheme;
    final String label = _getButtonLabel();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant)
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  String _getButtonLabel() {
    switch (currentStep) {
      case 0:
        return 'Continue to payment';
      case 1:
        return 'Review order';
      case 2:
        return selectedPaymentIndex == 0 ? 'Place order' : 'Pay now';
      default:
        return '';
    }
  }
}
