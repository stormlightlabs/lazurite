import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/atproto_host_resolver.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/account/presentation/account_switcher_sheet.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppShellMenuButton(),
        title: _title(context),
        actions: [
          IconButton(
            tooltip: 'Log Out',
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
      body: ListView(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final tokens = authState.tokens;
              if (!authState.isAuthenticated || tokens == null) {
                return const SizedBox.shrink();
              }

              return BlocBuilder<AccountSwitcherCubit, AccountSwitcherState>(
                builder: (context, switcherState) {
                  final subtitle = switcherState.accounts.length > 1
                      ? '${switcherState.accounts.length} accounts — tap to switch'
                      : '@${tokens.handle}';

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text((tokens.displayName ?? tokens.handle).substring(0, 1).toUpperCase()),
                    ),
                    title: Text(tokens.displayName ?? tokens.handle),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showAccountSwitcherSheet(context),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeSelector(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Layout'),
          _buildLayoutSettings(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Moderation'),
          const _ModerationSettingsPreview(),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Account'),
          const _AtProtocolConnectionCard(),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.dynamic_feed_outlined,
            title: 'Feeds',
            subtitle: 'Manage pinned and saved feeds',
            onTap: () => context.push('/feeds'),
          ),
          _SettingsTile(
            icon: Icons.bookmark_outline,
            title: 'Saved Posts',
            subtitle: 'View your saved posts',
            onTap: () => context.push('/saved'),
          ),
          _SettingsTile(
            icon: Icons.videocam_outlined,
            title: 'Video Upload Limits',
            subtitle: 'Check your daily video quota',
            onTap: () => context.push('/settings/video-limits'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Advanced'),
          _buildAdvancedSettings(context),
          const SizedBox(height: 24),
          if (!kReleaseMode) ...[
            _buildSectionHeader(context, 'Developer'),
            _buildDeveloperSettings(context),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader(context, 'About'),
          _SettingsTile(
            icon: Icons.code_outlined,
            title: 'Dev Tools',
            subtitle: 'PDS Explorer',
            onTap: () => context.push('/settings/devtools'),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Logs',
            subtitle: 'View app log files',
            onTap: () => context.push('/settings/logs'),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Stormlight Labs',
            onTap: () => context.push('/settings/about'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Danger Zone'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            isDestructive: true,
            onTap: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
          const SizedBox(height: 24),
          Center(child: Text('Lazurite v1.0.0', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _title(BuildContext context) => Text('Settings', style: Theme.of(context).textTheme.titleLarge);

  Widget _buildThemeSelector(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SegmentedButton<_AppearanceMode>(
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                      selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    segments: const [
                      ButtonSegment(value: _AppearanceMode.system, label: Text('System')),
                      ButtonSegment(value: _AppearanceMode.light, label: Text('Light')),
                      ButtonSegment(value: _AppearanceMode.dark, label: Text('Dark')),
                    ],
                    selected: {_AppearanceMode.fromState(state)},
                    onSelectionChanged: (selected) {
                      final mode = selected.first;
                      switch (mode) {
                        case _AppearanceMode.system:
                          settingsCubit.setUseSystemTheme(true);
                        case _AppearanceMode.light:
                          settingsCubit.setUseSystemTheme(false);
                          settingsCubit.setThemeVariant(AppThemeVariant.light);
                        case _AppearanceMode.dark:
                          settingsCubit.setUseSystemTheme(false);
                          settingsCubit.setThemeVariant(AppThemeVariant.dark);
                      }
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'THEME',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                ),
              ),
              for (final palette in AppThemePalette.values)
                _ThemePaletteRow(
                  palette: palette,
                  isSelected: state.themePalette == palette,
                  onTap: () => settingsCubit.setThemePalette(palette),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayoutSettings(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              _SettingsDropdownTile<FeedLayout>(
                title: 'Feed Layout',
                value: state.feedLayout,
                options: FeedLayout.values,
                labelBuilder: (layout) => switch (layout) {
                  FeedLayout.card => 'Card',
                  FeedLayout.compact => 'Compact',
                },
                onChanged: (value) {
                  if (value != null) {
                    settingsCubit.setFeedLayout(value);
                  }
                },
              ),
              const Divider(height: 1),
              _SettingsDropdownTile<int?>(
                title: 'Thread Auto-Collapse',
                subtitle: 'Collapse reply branches deeper than the selected level',
                value: state.threadAutoCollapseDepth,
                options: const <int?>[null, 1, 2, 3, 4, 5, 6],
                labelBuilder: (depth) => depth == null ? 'Off' : 'Depth $depth',
                onChanged: settingsCubit.setThreadAutoCollapseDepth,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSettings(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: _ConstellationUrlTile(
            currentUrl: state.constellationUrl,
            onChanged: (url) => context.read<SettingsCubit>().setConstellationUrl(url),
          ),
        );
      },
    );
  }

  Widget _buildDeveloperSettings(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: _SettingsTile(
            icon: Icons.cloud_off_outlined,
            title: 'Simulate Offline',
            subtitle: 'Force offline UI for testing network resilience',
            trailing: Switch.adaptive(value: state.simulateOffline, onChanged: settingsCubit.setSimulateOffline),
          ),
        );
      },
    );
  }
}

class _ModerationSettingsPreview extends StatefulWidget {
  const _ModerationSettingsPreview();

  @override
  State<_ModerationSettingsPreview> createState() => _ModerationSettingsPreviewState();
}

class _ModerationSettingsPreviewState extends State<_ModerationSettingsPreview> {
  bool _isUpdating = false;

  ModerationService? get _service => maybeModerationService(context);

  Future<void> _toggleAdultContent(bool value) async {
    final service = _service;
    if (service == null) {
      return;
    }

    setState(() => _isUpdating = true);
    try {
      await service.setAdultContentEnabled(value);
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update adult content: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = _service;
    if (service == null) {
      return _SettingsTile(
        icon: Icons.shield_outlined,
        title: 'Content Moderation',
        subtitle: 'Manage labelers and visibility rules',
        onTap: () => context.push('/settings/moderation'),
      );
    }

    return StreamBuilder(
      stream: service.optsStream,
      initialData: service.currentOpts,
      builder: (context, snapshot) {
        final adultEnabled = adultContentEnabledFromPreferences(service.currentPreferences);
        final customLabelers =
            service.currentPrefs?.labelers.where((labeler) => labeler.did != officialBlueskyLabelerDid).length ?? 0;

        return Column(
          children: [
            _SettingsTile(
              icon: Icons.visibility_outlined,
              title: 'Adult Content',
              subtitle: adultEnabled ? '18+ labels can be configured' : 'Required before 18+ labels can be configured',
              trailing: Switch.adaptive(value: adultEnabled, onChanged: _isUpdating ? null : _toggleAdultContent),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.policy_outlined,
              title: 'Content Moderation',
              subtitle: '$customLabelers custom labeler${customLabelers == 1 ? '' : 's'} subscribed',
              onTap: () => context.push('/settings/moderation'),
            ),
          ],
        );
      },
    );
  }
}

class _AtProtocolConnectionCard extends StatelessWidget {
  const _AtProtocolConnectionCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final tokens = authState.tokens;
        if (!authState.isAuthenticated || tokens == null) {
          return const SizedBox.shrink();
        }

        final pds = resolvePdsHost(tokens);

        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text('AT Protocol Connection', style: Theme.of(context).textTheme.titleMedium),
                ),
                const Divider(height: 1),
                _ConnectionDetailRow(label: 'Handle', value: '@${tokens.handle}'),
                const Divider(height: 1),
                _ConnectionDetailRow(
                  label: 'DID',
                  value: tokens.did,
                  onTap: () => context.push('/settings/devtools?query=${Uri.encodeQueryComponent(tokens.did)}'),
                ),
                const Divider(height: 1),
                _ConnectionDetailRow(label: 'PDS', value: pds),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _AppearanceMode {
  system,
  light,
  dark;

  static _AppearanceMode fromState(SettingsState state) {
    if (state.useSystemTheme) return system;
    return state.themeVariant == AppThemeVariant.light ? light : dark;
  }
}

class _ThemePaletteRow extends StatelessWidget {
  const _ThemePaletteRow({required this.palette, required this.isSelected, required this.onTap});

  final AppThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final swatches = AppTheme.getSwatchColors(palette);

    return ListTile(
      onTap: onTap,
      title: Text(AppTheme.getPaletteName(palette)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final color in swatches)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          if (isSelected) ...[
            const SizedBox(width: 12),
            Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 20),
          ],
        ],
      ),
    );
  }
}

class _SettingsDropdownTile<T> extends StatelessWidget {
  const _SettingsDropdownTile({
    required this.title,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final T value;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          items: [for (final option in options) DropdownMenuItem<T>(value: option, child: Text(labelBuilder(option)))],
        ),
      ),
    );
  }
}

class _ConnectionDetailRow extends StatelessWidget {
  const _ConnectionDetailRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrains Mono')),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 12),
            Icon(Icons.open_in_new, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }
}

class _ConstellationUrlTile extends StatelessWidget {
  const _ConstellationUrlTile({required this.currentUrl, required this.onChanged});

  final String currentUrl;
  final ValueChanged<String> onChanged;

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: currentUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Constellation URL'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: const InputDecoration(hintText: 'https://constellation.microcosm.blue'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.hub_outlined),
      title: const Text('Constellation URL'),
      subtitle: Text(currentUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () => _showEditDialog(context),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;

    return ListTile(
      leading: icon != null ? Icon(icon, color: color) : null,
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
