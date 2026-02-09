import 'package:flutter/material.dart';

class FeedbackDialog extends StatelessWidget {
  const FeedbackDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Your feedback matters'), 
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Share your thoughts, ideas, or report issues'), 
          const SizedBox(height: 16),
          TextField(
            controller: feedbackController,
            decoration: const InputDecoration(
              hintText: 'Type your feedback here',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
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
            Navigator.pop(context); // Close dialog
   
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thanks! Your feedback improves the app for everyone.')),
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
