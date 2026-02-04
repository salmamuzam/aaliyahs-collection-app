import 'package:flutter/material.dart';

// ============================================================================
// KEYBOARD DISMISSER - Automatically Hide Keyboard When Tapping Outside
// ============================================================================
// This widget wraps around screens with text fields
// When user taps anywhere outside a text field, the keyboard closes
// This improves user experience - no need to manually close keyboard
//
// USAGE: Wrap your screen with this widget
// KeyboardDismisser(
//   child: YourScreen(),
// )
// ============================================================================

class KeyboardDismisser extends StatelessWidget {
  final Widget child;  // The screen/widget to wrap

  const KeyboardDismisser({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // GestureDetector detects taps anywhere on the screen
    return GestureDetector(
      onTap: () {
        // Get the current focus state (what widget is focused/active)
        final currentFocus = FocusScope.of(context);
        
        // Check if something is focused (like a text field)
        // hasPrimaryFocus = false means we're not on the main screen focus
        // focusedChild != null means a text field is currently active
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          // Remove focus from the text field (this closes the keyboard)
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      
      // The actual screen content
      child: child,
    );
  }
}
