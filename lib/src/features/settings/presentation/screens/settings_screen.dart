import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/developer_tools/application/dev_settings_providers.dart';
import 'package:lazurite/src/features/scheduling/application/scheduling_providers.dart';
import 'package:lazurite/src/features/settings/presentation/widgets/settings_section.dart';
import 'package:lazurite/src/features/settings/presentation/widgets/settings_tile.dart';

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
          if (isAuthenticated) ..._buildSchedulingSection(context, ref),
          ..._buildAppearanceSection(context),
          ..._buildAppSection(context),
          ..._buildDeveloperSection(context, ref),
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
          context.push('/settings/moderation');
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
          context.push('/settings/muted-words');
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

  List<Widget> _buildSchedulingSection(BuildContext context, WidgetRef ref) {
    final autoPostEnabled = ref.watch(autoPostEnabledProvider).value ?? false;

    return [
      const SettingsSection(title: 'Scheduling'),
      SettingsTile(
        leading: const Icon(Icons.schedule_send_outlined),
        title: 'Auto-post scheduled drafts',
        subtitle: 'Automatically publish posts even when the app is closed',
        trailing: Switch(
          value: autoPostEnabled,
          onChanged: (value) async {
            final oldScheduler = ref.read(schedulerProvider);
            await ref.read(autoPostEnabledProvider.notifier).toggle();
            final newScheduler = ref.read(schedulerProvider);

            await oldScheduler.cancelAll();
            await newScheduler.resyncAll();
          },
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          'Note: Background auto-post may be delayed by operating system power management. '
          'Notification mode (default) is more reliable on some devices.',
          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
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
        leading: const Icon(Icons.accessibility_new),
        title: 'Accessibility',
        subtitle: 'Animation controls and preferences',
        onTap: () {
          context.push('/settings/accessibility');
        },
      ),
      SettingsTile(
        leading: const Icon(Icons.developer_mode),
        title: 'Developer Tools',
        subtitle: 'Repository inspector and debug tools',
        onTap: () {
          context.push('/devtools');
        },
      ),
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

  List<Widget> _buildDeveloperSection(BuildContext context, WidgetRef ref) {
    final devToolsEnabled = ref.watch(devToolsEnabledProvider).value ?? false;
    final allowOtherRepos = ref.watch(allowOtherReposProvider).value ?? false;
    final recordEditing = ref.watch(enableRecordEditingProvider).value ?? false;

    if (!kDebugMode && !devToolsEnabled) return [];

    return [
      const SettingsSection(title: 'Developer Options'),
      SettingsTile(
        leading: const Icon(Icons.settings_applications_outlined),
        title: 'Enable Developer Tools',
        subtitle: 'Show dev tools in production (gate with caution)',
        trailing: Switch(
          value: devToolsEnabled,
          onChanged: (_) => ref.read(devToolsEnabledProvider.notifier).toggle(),
        ),
      ),
      if (devToolsEnabled || kDebugMode) ...[
        SettingsTile(
          leading: const Icon(Icons.public_outlined),
          title: 'Browse Other Repositories',
          subtitle: 'Allow inspecting public DIDs/handles',
          trailing: Switch(
            value: allowOtherRepos,
            onChanged: (_) => ref.read(allowOtherReposProvider.notifier).toggle(),
          ),
        ),
        SettingsTile(
          leading: const Icon(Icons.edit_note_outlined),
          title: 'Enable Record Editing',
          subtitle: 'EXPERIMENTAL: Edit records directly (biometric gate)',
          trailing: Switch(
            value: recordEditing,
            onChanged: (value) async {
              await ref.read(enableRecordEditingProvider.notifier).toggle();
            },
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildAccountManagementSection(BuildContext context, WidgetRef ref) {
    return [
      const SettingsSection(title: 'Account Management'),
      SettingsTile(
        leading: const Icon(Icons.logout),
        title: 'Sign Out',
        subtitle: 'Log out of your account',
        trailing: null,
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
