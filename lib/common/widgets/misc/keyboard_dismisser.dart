import 'package:flutter/material.dart';


class KeyboardDismisser extends StatelessWidget {
  final Widget child;  

  const KeyboardDismisser({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
 
    return GestureDetector(
      onTap: () {
        // Get the current focus state 
        final currentFocus = FocusScope.of(context);
        

        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {

          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      
      // The actual screen content
      child: child,
    );
  }
}
