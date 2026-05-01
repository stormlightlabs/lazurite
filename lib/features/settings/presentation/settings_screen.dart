import 'dart:async';
import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/atproto_host_resolver.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/account/presentation/account_switcher_sheet.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/search/cubit/semantic_index_cubit.dart';
import 'package:lazurite/features/search/cubit/semantic_search_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

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
            icon: Icon(Icons.logout, color: context.colorScheme.error),
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
                    leading: ProfileAvatar(size: 40, fallbackText: tokens.displayName ?? tokens.handle),
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
          _buildSectionHeader(context, 'Search'),
          _buildSearchSettings(context),
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
          _buildSectionHeader(context, 'Account Maintenance'),
          _SettingsTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Clean Follows',
            subtitle: 'Audit and unfollow problematic accounts in bulk',
            onTap: () => context.push('/settings/clean-follows'),
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
            icon: Icons.explore_outlined,
            title: 'AT Explorer',
            subtitle: 'View PDS Records',
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
          _SettingsTile(
            icon: Icons.gavel_outlined,
            title: 'Terms of Service',
            subtitle: 'Usage rules and responsibilities',
            onTap: () => context.push('/terms'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How Lazurite handles data',
            onTap: () => context.push('/privacy'),
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
          Center(child: Text('Lazurite v1.0.0', style: context.textTheme.bodySmall)),
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
        style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _title(BuildContext context) => Text('Settings', style: context.textTheme.titleLarge);

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
                      selectedBackgroundColor: context.colorScheme.primary,
                      selectedForegroundColor: context.colorScheme.onPrimary,
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
                    style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
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
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.motion_photos_off_outlined,
                title: 'Animations',
                subtitle: 'Turn off non-essential motion effects',
                trailing: Switch.adaptive(
                  value: state.animationsEnabled,
                  onChanged: settingsCubit.setAnimationsEnabled,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSettings(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
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
              ListTile(
                leading: const Icon(Icons.tune_outlined),
                title: const Text('Typeahead Provider'),
                subtitle: Text(
                  settingsState.typeaheadProvider == 'community'
                      ? 'Community (waow.tech) selected. Third-party service, works before login.'
                      : 'Bluesky official endpoint selected. Requires login.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(value: 'bluesky', label: Text('Bluesky')),
                      ButtonSegment<String>(value: 'community', label: Text('Community')),
                    ],
                    selected: {settingsState.typeaheadProvider},
                    onSelectionChanged: (selection) {
                      context.read<SettingsCubit>().setTypeaheadProvider(selection.first);
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.manage_search_outlined,
                title: 'Semantic Search',
                subtitle: settingsState.semanticSearchEnabled
                    ? 'Search your liked & saved posts by meaning, not just keywords'
                    : 'Enable this to search your liked & saved posts by meaning',
                trailing: Switch.adaptive(
                  value: settingsState.semanticSearchEnabled,
                  onChanged: (value) async {
                    await context.read<SettingsCubit>().setSemanticSearchEnabled(value);
                    if (value && context.mounted) {
                      unawaited(context.read<SemanticIndexCubit>().reindex());
                    }
                  },
                ),
              ),
              if (settingsState.semanticSearchEnabled) ...[
                const Divider(height: 1),
                _SettingsDropdownTile<SearchScope>(
                  title: 'Default Scope',
                  subtitle: 'Which posts to search by default',
                  value: settingsState.searchScope,
                  options: SearchScope.values,
                  labelBuilder: (scope) => switch (scope) {
                    SearchScope.both => 'Saved + Liked',
                    SearchScope.saved => 'Saved only',
                    SearchScope.liked => 'Liked only',
                  },
                  onChanged: (scope) {
                    if (scope != null) context.read<SettingsCubit>().setSearchScope(scope);
                  },
                ),
                const Divider(height: 1),
                BlocBuilder<SemanticIndexCubit, SemanticIndexState>(
                  builder: (context, indexState) => _IndexStatusTile(indexState: indexState),
                ),
                const Divider(height: 1),
                _MaxResultsTile(
                  value: settingsState.semanticSearchMaxResults,
                  onChanged: (value) {
                    context.read<SettingsCubit>().setSemanticSearchMaxResults(value);
                    context.read<SemanticSearchCubit>().setMaxResults(value);
                  },
                ),
              ],
            ],
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
            title: 'Go Offline',
            subtitle: 'Turn off online connectivity',
            trailing: Switch.adaptive(value: state.simulateOffline, onChanged: settingsCubit.setSimulateOffline),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSettings(BuildContext context) {
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
              _ConstellationUrlTile(currentUrl: state.constellationUrl),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.route_outlined,
                title: 'AppView Provider',
                subtitle: _appViewSubtitle(state.appViewProvider),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<String>(
                    key: const Key('appview-provider-segmented'),
                    segments: const [
                      ButtonSegment<String>(value: AppViewProviders.blueskyKey, label: Text('Bluesky')),
                      ButtonSegment<String>(value: AppViewProviders.blackskyKey, label: Text('Blacksky')),
                    ],
                    selected: {state.appViewProvider},
                    onSelectionChanged: (selection) async {
                      final selectedProvider = selection.first;
                      if (selectedProvider == state.appViewProvider) {
                        return;
                      }
                      await _confirmAndApplyProviderChange(context, selectedProvider);
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.compare_arrows_outlined,
                title: 'Cross-Provider Fallback',
                subtitle: 'Retry public reads on the alternate AppView when transient errors occur',
                trailing: Switch.adaptive(
                  value: state.crossProviderFallbackEnabled,
                  onChanged: settingsCubit.setCrossProviderFallbackEnabled,
                ),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.alt_route_outlined,
                title: 'Slingshot Identity Fallback',
                subtitle: 'Use Slingshot resolveMiniDoc for degraded handle resolution',
                trailing: Switch.adaptive(
                  value: state.slingshotIdentityFallbackEnabled,
                  onChanged: settingsCubit.setSlingshotIdentityFallbackEnabled,
                ),
              ),
              const Divider(height: 1),
              const _SettingsTile(
                icon: Icons.monitor_heart_outlined,
                title: 'Provider Diagnostics',
                subtitle: 'Moderation/ranking can differ by provider. Verify health and recent fallback state.',
              ),
              _ConnectionDetailRow(label: 'Active Provider', value: _providerDisplayName(state.appViewProvider)),
              const Divider(height: 1),
              _ConnectionDetailRow(label: 'Health', value: state.appViewHealthSummary ?? 'Not checked yet'),
              const Divider(height: 1),
              _ConnectionDetailRow(
                label: 'Last Health Check',
                value: state.appViewHealthCheckedAt == null
                    ? 'Never'
                    : _formatTimestamp(state.appViewHealthCheckedAt!.toLocal()),
              ),
              const Divider(height: 1),
              _ConnectionDetailRow(label: 'Last Fallback', value: state.appViewLastFallback ?? 'None'),
              const Divider(height: 1),
              _ConnectionDetailRow(label: 'Last Error', value: state.appViewLastError ?? 'None'),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.refresh_outlined,
                title: 'Refresh Provider Health',
                subtitle: 'Probe public AppView endpoints now',
                trailing: state.appViewHealthRefreshing
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                onTap: state.appViewHealthRefreshing
                    ? null
                    : () {
                        unawaited(settingsCubit.refreshAppViewHealth());
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  String _providerDisplayName(String providerKey) {
    if (providerKey == AppViewProviders.blackskyKey) {
      return 'Blacksky';
    }
    return 'Bluesky';
  }

  String _appViewSubtitle(String providerKey) {
    final provider = _providerDisplayName(providerKey);
    return '$provider selected. Switching providers performs a soft restart.';
  }

  String _formatTimestamp(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${time.year}-$month-$day $hour:$minute';
  }

  Future<void> _confirmAndApplyProviderChange(BuildContext context, String selectedProvider) async {
    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Switch AppView provider?'),
          content: const Text(
            'Apply and restart now to rebuild network services.\n\n'
            'You will stay signed in and no local data will be deleted.\n\n'
            'Moderation labels, ranking, and trending results can differ between providers.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Apply and Restart'),
            ),
          ],
        );
      },
    );

    if (shouldApply != true || !context.mounted) {
      return;
    }

    await context.read<SettingsCubit>().setAppViewProvider(selectedProvider);
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
        showAppSnackBar(context, 'Failed to update adult content: $error', isError: true);
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
                  child: Text('AT Protocol Connection', style: context.textTheme.titleMedium),
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
            Icon(Icons.check, color: context.colorScheme.primary, size: 20),
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
  const _ConstellationUrlTile({required this.currentUrl});

  final String currentUrl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.hub_outlined),
      title: const Text('Constellation URL'),
      subtitle: Text(currentUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
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
    final color = isDestructive ? context.colorScheme.error : null;

    return ListTile(
      leading: icon != null ? Icon(icon, color: color) : null,
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}

class _IndexStatusTile extends StatelessWidget {
  const _IndexStatusTile({required this.indexState});

  final SemanticIndexState indexState;

  @override
  Widget build(BuildContext context) {
    final statusText = indexState.isBackfilling
        ? 'Indexing: ${indexState.backfillCompleted ?? 0}/${indexState.backfillTotal ?? 0} posts...'
        : '${indexState.indexedCount} posts indexed';

    return ListTile(
      leading: indexState.isBackfilling
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.data_object_outlined),
      title: const Text('Index Status'),
      subtitle: Text(statusText),
      trailing: indexState.isBackfilling
          ? null
          : TextButton(onPressed: () => context.read<SemanticIndexCubit>().reindex(), child: const Text('Re-index')),
    );
  }
}

class _MaxResultsTile extends StatelessWidget {
  const _MaxResultsTile({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.format_list_numbered_outlined),
          title: const Text('Max Results'),
          subtitle: const Text('Maximum number of search results'),
          trailing: Text(
            '$value',
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontFamily: 'JetBrains Mono'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Text('10', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 8,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
              const Text('50', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
