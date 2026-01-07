import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../auth/domain/auth_state.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// Main settings screen for the app.
///
/// Displays settings organized into sections: Account (authenticated only),
/// Appearance, App, and Account Management (authenticated only). Settings
/// that require authentication are hidden when the user is not logged in.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthStateAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (isAuthenticated) ..._buildAccountSection(context, ref),
          ..._buildAppearanceSection(context),
          ..._buildAppSection(context),
          if (isAuthenticated) ..._buildAccountManagementSection(context, ref),
        ],
      ),
    );
  }

  List<Widget> _buildAccountSection(BuildContext context, WidgetRef ref) {
    return [
      const SettingsSection(title: 'Account'),
      SettingsTile(
        leading: const Icon(Icons.label_outline),
        title: 'Content Moderation',
        subtitle: 'Manage content warnings and filters',
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Content Moderation - Coming soon')));
        },
      ),
      SettingsTile(
        leading: const Icon(Icons.view_list_outlined),
        title: 'Feed Preferences',
        subtitle: 'Customize your feed display',
        onTap: () {
          context.push('/settings/feeds');
        },
      ),
      SettingsTile(
        leading: const Icon(Icons.volume_off_outlined),
        title: 'Muted Words',
        subtitle: 'Keywords to filter from feeds',
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Muted Words - Coming soon')));
        },
      ),
      SettingsTile(
        leading: const Icon(Icons.bookmarks_outlined),
        title: 'Saved Feeds',
        subtitle: 'Manage your feed subscriptions',
        onTap: () {
          context.push('/feeds/manage');
        },
      ),
    ];
  }

  List<Widget> _buildAppearanceSection(BuildContext context) {
    return [
      const SettingsSection(title: 'Appearance'),
      SettingsTile(
        leading: const Icon(Icons.palette_outlined),
        title: 'Theme',
        subtitle: 'Light, dark, or system theme',
        onTap: () {
          context.push('/settings/appearance');
        },
      ),
    ];
  }

  List<Widget> _buildAppSection(BuildContext context) {
    return [
      const SettingsSection(title: 'App'),
      SettingsTile(
        leading: const Icon(Icons.info_outline),
        title: 'About',
        subtitle: 'App version and information',
        onTap: () {
          context.push('/settings/about');
        },
      ),
    ];
  }

  List<Widget> _buildAccountManagementSection(BuildContext context, WidgetRef ref) {
    return [
      const SettingsSection(title: 'Account Management'),
      SettingsTile(
        leading: const Icon(Icons.logout),
        title: 'Sign Out',
        subtitle: 'Log out of your account',
        trailing: null, // No chevron for action items
        onTap: () async {
          final confirmed = await _showSignOutDialog(context);
          if (confirmed == true) {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              context.go('/');
            }
          }
        },
      ),
    ];
  }

  Future<bool?> _showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
