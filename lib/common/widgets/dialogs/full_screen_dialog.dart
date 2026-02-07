import 'package:flutter/material.dart';

class AaliyahFullScreenDialog extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final Widget child;
  final bool hasChanges; // New flag to track unsaved state

  const AaliyahFullScreenDialog({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
    required this.child,
    this.hasChanges = false,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required VoidCallback onActionPressed,
    required Widget child,
    bool hasChanges = false,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AaliyahFullScreenDialog(
          title: title,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          hasChanges: hasChanges,
          child: child,
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (!hasChanges) return true;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text("If you leave now, any changes you've made will be lost."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return PopScope(
      canPop: false, // Handle pop manually to show discard dialog
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Semantics(
        scopesRoute: true, // Accessibility: Treat as a separate route
        explicitChildNodes: true,
        label: title,
        child: Scaffold(
          backgroundColor: colorScheme.surfaceContainerHigh,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56.0),
            child: AppBar(
              backgroundColor: colorScheme.surfaceContainerHigh,
              surfaceTintColor: Colors.transparent,
              leading: Semantics(
                label: 'Dismiss',
                hint: 'Discard changes and close',
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () async {
                    final shouldPop = await _onWillPop(context);
                    if (shouldPop && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  tooltip: 'Dismiss',
                ),
              ),
              centerTitle: false,
              title: Semantics(
                header: true, // Accessibility: Mark as semantic header
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              actions: [
                Semantics(
                  button: true,
                  label: actionLabel,
                  child: TextButton(
                    onPressed: onActionPressed,
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
