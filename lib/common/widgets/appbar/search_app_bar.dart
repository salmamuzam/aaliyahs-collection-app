import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';

import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ============================================================================
// AALIYAH SEARCH APP BAR - M3 Expressive (May 2025)
// ============================================================================
// This is a reusable search AppBar that can be used on any screen
// M3 Expressive Features:
// - Height: 72dp (search app bar standard)
// - Supports icons inside and outside the search bar
// - Can have centered text option
// - Opens search view component when selected
// - Visual feedback when listening to voice
// - Dynamic shape morphing during voice input
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
    this.hintText = 'Search...',
    this.onBackPress,
    this.actions,
    this.onChanged,
    this.onMicPress,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final access = Provider.of<AccessibilityController>(context);
    final bool reduceMotion = access.reduceMotion;

    return AppBar(
      toolbarHeight: 72,  // Make AppBar taller to fit the search bar nicely
      automaticallyImplyLeading: false,  // Don't show default back button (I'll add my own)
      titleSpacing: 8, // Give a small bit of breathing room
      centerTitle: false,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      
      // The search bar container with M3 Shape Morphing
      title: AnimatedContainer(
        duration: AMotion.durationStationaryEmphasized,
        curve: AMotion.easingEmphasized,
        height: 50,
        
        // M3 Expressive: Dynamic shape to indicate listening state
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: isListening 
              ? const BorderRadius.only(
                  topLeft: Radius.circular(TUIConstants.shapeRadiusXL), // 28
                  topRight: Radius.circular(TUIConstants.shapeRadiusSmall), // 8 (Tension)
                  bottomLeft: Radius.circular(TUIConstants.shapeRadiusSmall), 
                  bottomRight: Radius.circular(TUIConstants.shapeRadiusXL),
                )
              : BorderRadius.circular(25), // Standard pill
          
          border: Border.all(
            color: isListening 
              ? colorScheme.primary  
              : colorScheme.outlineVariant,
            width: isListening ? 2.0 : 1.5,
          ),
          boxShadow: [
            if (isListening)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 2,
              )
          ],
        ),
        
        // Contents of the search bar
        child: Row(
          children: [
            // Back button on the left
            IconButton(
              onPressed: onBackPress ?? () => Navigator.pop(context),  // Go back when pressed
              icon: Icon(Icons.arrow_back_rounded, size: 20, color: colorScheme.onSurface),
              tooltip: 'Back',
            ),
            
            // Search text field (takes up remaining space)
            Expanded(
              child: TextField(
                controller: controller,  // Connect to the text controller
                onChanged: onChanged,    // Call this function when user types
                
                decoration: InputDecoration(
                  // Change hint text when listening to voice
                  hintText: isListening ? 'Listening...' : hintText,
                  
                  // Remove all borders (we already have border on container)
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  
                  contentPadding: const EdgeInsets.symmetric(),
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                ),
                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
              ),
            ),
            
            // Microphone button on the right (only show if onMicPress is provided)
            if (onMicPress != null)
              Semantics(
                label: isListening ? 'Stop voice search' : 'Start voice search',
                button: true,
                child: IconButton(
                  onPressed: onMicPress,  // Start/stop voice search
                  tooltip: isListening ? 'Stop listening' : 'Voice search',
                  icon: Icon(
                    // Change icon based on listening state
                    isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    
                    // Error color when listening, standard variant when not
                    color: isListening ? colorScheme.error : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(
          duration: reduceMotion ? AMotion.durationShort4 : AMotion.durationEnterStandard,
          curve: AMotion.effects
        ).slideY(
          begin: reduceMotion ? 0 : -0.2, 
          end: 0,
          duration: reduceMotion ? Duration.zero : AMotion.durationEnterEmphasized,
          curve: AMotion.easingEmphasizedDecelerate,
        ),
      
      // Additional action buttons on the right (if provided)
      actions: actions,
    );
  }

  // Required by PreferredSizeWidget - tells Flutter how tall this AppBar should be
  @override
  Size get preferredSize => const Size.fromHeight(72);
}
