import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';

class CheckoutBottomButton extends StatelessWidget {
  final int currentStep;
  final int selectedPaymentIndex;
  final bool isLoading;
  final VoidCallback onPressed;

  const CheckoutBottomButton({
    super.key,
    required this.currentStep,
    required this.selectedPaymentIndex,
    required this.isLoading,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : onPressed,
                child: isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : Text(
                      label,
                      style: const TextStyle(fontSize: 16),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Provider.of<NavigationController>(context, listen: false).setIndex(1);
                },
                child: const Text('Back to Shop'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonLabel() {
    switch (currentStep) {
      case 0:
        return 'Continue to Payment';
      case 1:
        return 'Review Order';
      case 2:
        return selectedPaymentIndex == 0 ? 'Place Order' : 'Pay Now';
      default:
        return '';
    }
  }
}
