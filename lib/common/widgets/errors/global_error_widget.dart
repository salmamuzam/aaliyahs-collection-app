import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

class GlobalErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const GlobalErrorWidget({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1416) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DeviceUtils.m3Margin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.terminal_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Something Unravelled',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Aaliyah\'s Collection encountered an unexpected error. We\'ve logged the details and are working to stitch it back together.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
       
                    HapticFeedback.mediumImpact();
                    SystemNavigator.pop(); 
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restart Application'),
                ),
              ),
              const SizedBox(height: 12),
              
              OutlinedButton.icon(
                onPressed: () {
                   Clipboard.setData(ClipboardData(text: errorDetails.toString()));
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Error details copied to clipboard')),
                   );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy Error Details'),
              ),
              
              if (DeviceUtils.isTabletOrLarger) ...[
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        errorDetails.toString(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
