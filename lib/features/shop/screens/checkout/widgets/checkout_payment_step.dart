import 'package:flutter/material.dart';


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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment methods',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentCard(
            context: context,
            index: 0,
            title: 'Cash on delivery', // Sentence case
            subtitle: 'Pay when you receive',
            icon: Icons.payments_rounded,
          ),
          _buildPaymentCard(
            context: context,
            index: 1,
            title: 'Stripe',
            subtitle: 'Pay securely with Stripe',
            icon: Icons.credit_card_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = selectedPaymentIndex == index;
    final Color highlightColor = Theme.of(context).colorScheme.primary;

    return Semantics(
      label: "Payment method: $title. ${isSelected ? 'Selected' : 'Not selected'}.",
      button: true,
      selected: isSelected,
      onTap: () => onPaymentSelected(index),
      child: Card.outlined(
        margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? highlightColor : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onPaymentSelected(index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isSelected ? highlightColor : Theme.of(context).colorScheme.onSurfaceVariant),
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                color: isSelected ? highlightColor : Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
