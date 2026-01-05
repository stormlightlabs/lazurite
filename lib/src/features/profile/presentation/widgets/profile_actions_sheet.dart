import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/theme_mode_controller.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';

/// Bottom sheet that exposes profile-level actions such as logout and theming.
class ProfileActionsSheet extends ConsumerWidget {
  const ProfileActionsSheet({required this.isCurrentUser, super.key});

  /// Whether the viewer is looking at their own profile.
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (enabled) {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          if (isCurrentUser)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                await ref.read(authProvider.notifier).logout();
              },
            ),
        ],
      ),
    );
  }
}
