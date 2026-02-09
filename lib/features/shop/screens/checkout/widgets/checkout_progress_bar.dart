import 'package:flutter/material.dart';

import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';


class CheckoutProgressBar extends StatelessWidget {
  final int currentStep;

  const CheckoutProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> titles = ['Address', 'Payment', 'Summary'];

    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(titles.length * 2 - 1, (index) {
          final int stepIndex = index ~/ 2;
          final bool isLine = index.isOdd;

          if (isLine) {
            final bool isLineCompleted = stepIndex < currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: AMotion.durationDefault,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: isLineCompleted
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            );
          }

          final bool isCompleted = stepIndex < currentStep;
          final bool isActive = stepIndex == currentStep;
          final bool isSelected = isCompleted || isActive;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AMotion.durationStationaryStandard,
                curve: AMotion.easingEmphasized,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                      ? colorScheme.primary 
                      : isCompleted 
                          ? colorScheme.primaryContainer 
                          : colorScheme.surfaceContainerHigh,
                  border: isActive 
                      ? null 
                      : Border.all(
                          color: isSelected 
                              ? colorScheme.primary 
                              : colorScheme.outline,
                        ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check_rounded, color: colorScheme.onPrimaryContainer, size: 16)
                          .animate()
                          .scale(duration: 200.ms)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                titles[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500, 
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
