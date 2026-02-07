import 'package:flutter/material.dart';

class AccessibilityFeedbackDialog extends StatelessWidget {
  const AccessibilityFeedbackDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Accessibility feedback'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share any barriers or accessibility ideas',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: feedbackController,
            decoration: const InputDecoration(
              hintText: 'Describe the barrier or idea',
              border: OutlineInputBorder(),
              filled: true,
            ),
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                content: Text('Thanks! Your insight helps build a more inclusive app.', 
                    style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer)),
              ),
            );
          },
          child: const Text('Share insight'),
        ),
      ],
    );
  }
}
