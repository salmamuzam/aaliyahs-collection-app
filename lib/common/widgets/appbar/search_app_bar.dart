import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';

// ============================================================================
// AALIYAH SEARCH APP BAR - Custom Search Bar with Voice Input
// ============================================================================
// This is a reusable search AppBar that I can use on any screen
// Features:
// - Back button to go back
// - Search text field
// - Voice search button (microphone icon)
// - Visual feedback when listening to voice
// ============================================================================

class AaliyahSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Properties that can be customized when using this widget
  final TextEditingController controller;  // Controls the text in the search field
  final String hintText;                   // Placeholder text (e.g., "Search products...")
  final VoidCallback? onBackPress;         // What happens when back button is pressed
  final List<Widget>? actions;             // Additional buttons on the right (optional)
  final ValueChanged<String>? onChanged;   // Called when user types in the search field
  final VoidCallback? onMicPress;          // What happens when mic button is pressed
  final bool isListening;                  // True when voice search is active

  const AaliyahSearchAppBar({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onBackPress,
    this.actions,
    this.onChanged,
    this.onMicPress,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if app is in dark mode to adjust colors
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 72,  // Make AppBar taller to fit the search bar nicely
      automaticallyImplyLeading: false,  // Don't show default back button (I'll add my own)
      
      // The search bar container
      title: Container(
        height: 50,
        
        // Styling for the search bar
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,  // Background color
          borderRadius: BorderRadius.circular(25),  // Rounded corners
          
          // Border changes color when listening to voice
          border: Border.all(
            color: isListening 
              ? aaliyahPrimaryColor  // Green border when listening
              : (isDarkMode ? Colors.white12 : Colors.grey.shade300),  // Normal border
            width: 1.5,
          ),
        ),
        
        // Contents of the search bar
        child: Row(
          children: [
            // Back button on the left
            IconButton(
              onPressed: onBackPress ?? () => Navigator.pop(context),  // Go back when pressed
              icon: const Icon(Icons.arrow_back, size: 20),
            ),
            
            // Search text field (takes up remaining space)
            Expanded(
              child: TextField(
                controller: controller,  // Connect to the text controller
                onChanged: onChanged,    // Call this function when user types
                
                decoration: InputDecoration(
                  // Change hint text when listening to voice
                  hintText: isListening ? "Listening..." : hintText,
                  
                  // Remove all borders (we already have border on container)
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            // Microphone button on the right (only show if onMicPress is provided)
            if (onMicPress != null)
              IconButton(
                onPressed: onMicPress,  // Start/stop voice search
                icon: Icon(
                  // Change icon based on listening state
                  isListening ? Icons.mic : Icons.mic_none,
                  
                  // Red when listening, gray when not
                  color: isListening ? Colors.red : Colors.grey.shade600,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
      
      // Additional action buttons on the right (if provided)
      actions: actions,
    );
  }

  // Required by PreferredSizeWidget - tells Flutter how tall this AppBar should be
  @override
  Size get preferredSize => const Size.fromHeight(72);
}
