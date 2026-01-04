import 'package:flutter/material.dart';

/// Profile screen placeholder for the profile tab.
class ProfileScreen extends StatelessWidget {
  /// Creates a profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outlined, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Your Profile', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'View and edit your profile',
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
