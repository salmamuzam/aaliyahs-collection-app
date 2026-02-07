

import 'package:flutter/material.dart';

// Sometimes, I will remove this file
// If I forgot to, please ignore this file, sir

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    required this.press,
  });

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Container(
      constraints: BoxConstraints(maxWidth: isDesktop ? 400 : double.infinity),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: isDesktop ? 32 : 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: isDesktop ? 18 : 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          button ??
              SizedBox(
                width: isDesktop ? 300 : double.infinity,
                child: FilledButton(
                  onPressed: press,
                  child: Text(
                    btnText ?? 'Retry',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
