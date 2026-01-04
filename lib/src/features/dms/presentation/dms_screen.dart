import 'package:flutter/material.dart';

/// DMs screen placeholder for the direct messages tab.
class DmsScreen extends StatelessWidget {
  const DmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outlined, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Direct Messages', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Your conversations will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
