import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/app/app_version_label.dart';
import 'package:lazurite/core/cache/local_cache_maintenance_service.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/core/theme/typography.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/account/presentation/account_switcher_sheet.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/settings/presentation/screens/recoverable_crash_test_screen.dart';
import 'package:lazurite/features/settings/presentation/widgets/atproto_connection.dart';
import 'package:lazurite/features/settings/presentation/widgets/connection_detail.dart';
import 'package:lazurite/features/settings/presentation/widgets/settings_section.dart';
import 'package:lazurite/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:lazurite/features/settings/presentation/widgets/theme_palette_row.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final l10n = context.l10n;
    final tokens = authState.tokens;
    final showAccountSettings = authState.isAuthenticated && tokens != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showAccountSettings
            ? IconButton(
                tooltip: l10n.labelBack,
                onPressed: () {
                  final router = GoRouter.of(context);
                  if (router.canPop()) {
                    router.pop();
                    return;
                  }
                  router.go('/');
                },
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: _title(context),
        actions: showAccountSettings
            ? [
                IconButton(
                  tooltip: l10n.labelLogOut,
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  },
                  icon: Icon(Icons.logout, color: context.colorScheme.error),
                ),
              ]
            : null,
      ),
      body: ListView(
        children: [
          if (showAccountSettings)
            BlocBuilder<AccountSwitcherCubit, AccountSwitcherState>(
              builder: (context, switcherState) {
                final authenticatedTokens = tokens;
                final subtitle = switcherState.accounts.length > 1
                    ? l10n.formatAccountsTapToSwitch(switcherState.accounts.length)
                    : '@${authenticatedTokens.handle}';

                return ListTile(
                  leading: ProfileAvatar(
                    size: 40,
                    fallbackText: authenticatedTokens.displayName ?? authenticatedTokens.handle,
                  ),
                  title: Text(authenticatedTokens.displayName ?? authenticatedTokens.handle),
                  subtitle: Text(subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAccountSwitcherSheet(context),
                );
              },
            ),
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.labelAppearance),
          _buildThemeSelector(context),
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.labelLayout),
          _buildLayoutSettings(context),
          if (showAccountSettings) ...[
            const SizedBox(height: 24),
            SettingsSectionHeader(l10n.labelModeration),
            const _ModerationSettingsPreview(),
          ],
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.labelSearch),
          _buildSearchSettings(context, showTypeaheadSettings: showAccountSettings),
          if (showAccountSettings) ...[
            const SizedBox(height: 24),
            SettingsSectionHeader(l10n.labelAccount),
            const AtProtoConnectionCard(),
            const SizedBox(height: 12),
            SettingsTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Account settings',
              subtitle: 'Feed display preferences and account defaults',
              onTap: () => context.push('/settings/account'),
            ),
            SettingsTile(
              icon: Icons.dynamic_feed_outlined,
              title: l10n.labelFeeds,
              subtitle: l10n.messageFeedsSubtitle,
              onTap: () => context.push('/feeds'),
            ),
            SettingsTile(
              icon: Icons.bookmark_outline,
              title: l10n.labelBookmarksAndLikes,
              subtitle: l10n.messageBookmarksAndLikesSubtitle,
              onTap: () => context.push('/bookmarks'),
            ),
            SettingsTile(
              icon: Icons.videocam_outlined,
              title: l10n.labelVideoUploadLimits,
              subtitle: l10n.messageVideoUploadLimitsSubtitle,
              onTap: () => context.push('/settings/video-limits'),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader(l10n.labelAccountMaintenance),
            SettingsTile(
              icon: Icons.cleaning_services_outlined,
              title: l10n.labelCleanFollows,
              subtitle: l10n.messageCleanFollowsSubtitle,
              onTap: () => context.push('/settings/clean-follows'),
            ),
          ],
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.labelAdvanced),
          _buildAdvancedSettings(context),
          const SizedBox(height: 24),
          SettingsSectionHeader(l10n.labelTroubleshooting),
          _buildTroubleshootingSettings(context),
          const SizedBox(height: 24),
          if (!kReleaseMode) ...[
            SettingsSectionHeader(l10n.labelDeveloper),
            _buildDeveloperSettings(context),
            const SizedBox(height: 24),
          ],
          SettingsSectionHeader(l10n.labelAbout),
          SettingsTile(
            icon: Icons.explore_outlined,
            title: l10n.labelAtExplorer,
            subtitle: 'View PDS Records',
            onTap: () => context.push('/settings/devtools'),
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: l10n.labelAbout,
            subtitle: 'Stormlight Labs',
            onTap: () => context.push('/settings/about'),
          ),
          SettingsTile(
            icon: Icons.gavel_outlined,
            title: l10n.labelTermsOfService,
            subtitle: 'Usage rules and responsibilities',
            onTap: () => context.push('/terms'),
          ),
          SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.labelPrivacyPolicy,
            subtitle: 'How Lazurite handles data',
            onTap: () => context.push('/privacy'),
          ),
          if (showAccountSettings) ...[
            const SizedBox(height: 24),
            SettingsSectionHeader(l10n.labelDangerZone),
            SettingsTile(
              icon: Icons.logout,
              title: l10n.labelLogOut,
              isDestructive: true,
              onTap: () {
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
          const SizedBox(height: 24),
          const Center(child: AppVersionLabel()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) => Text(context.l10n.labelSettings, style: context.textTheme.titleLarge);

  Widget _buildThemeSelector(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsGroup(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SegmentedButton<AppearanceMode>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: context.colorScheme.primary,
                    selectedForegroundColor: context.colorScheme.onPrimary,
                  ),
                  segments: [
                    ButtonSegment(value: AppearanceMode.system, label: Text(context.l10n.labelSystem)),
                    ButtonSegment(value: AppearanceMode.light, label: Text(context.l10n.labelLight)),
                    ButtonSegment(value: AppearanceMode.dark, label: Text(context.l10n.labelDark)),
                  ],
                  selected: {AppearanceMode.fromState(state)},
                  onSelectionChanged: (selected) {
                    switch (selected.first) {
                      case AppearanceMode.system:
                        settingsCubit.setUseSystemTheme(true);
                      case AppearanceMode.light:
                        settingsCubit.setUseSystemTheme(false);
                        settingsCubit.setThemeVariant(AppThemeVariant.light);
                      case AppearanceMode.dark:
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
                  context.l10n.labelTheme,
                  style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),
            ),
            for (final palette in AppThemePalette.values)
              ThemePaletteRow(
                palette: palette,
                isSelected: state.themePalette == palette,
                onTap: () => settingsCubit.setThemePalette(palette),
              ),
            const Divider(height: 1),
            SettingsDropdownTile<AppHeadingFontFamily>(
              title: 'Heading Font',
              value: state.headingFontFamily,
              options: AppHeadingFontFamily.values,
              labelBuilder: (fontFamily) => fontFamily.label,
              optionBuilder: _headingFontOption,
              onChanged: (value) {
                if (value != null) {
                  settingsCubit.setHeadingFontFamily(value);
                }
              },
            ),
            const Divider(height: 1),
            SettingsDropdownTile<AppContentFontFamily>(
              title: 'Content Font',
              value: state.contentFontFamily,
              options: AppContentFontFamily.values,
              labelBuilder: (fontFamily) => fontFamily.label,
              optionBuilder: _contentFontOption,
              onChanged: (value) {
                if (value != null) {
                  settingsCubit.setContentFontFamily(value);
                }
              },
            ),
            const Divider(height: 1),
            SettingsDropdownTile<AppFontSize>(
              title: 'Font Size',
              value: state.contentFontSize,
              options: AppFontSize.values,
              labelBuilder: (fontSize) => fontSize.label,
              optionBuilder: _fontSizeOption,
              onChanged: (value) {
                if (value != null) {
                  settingsCubit.setContentFontSize(value);
                }
              },
            ),
            const Divider(height: 1),
            SettingsDropdownTile<AppCodeFontFamily>(
              title: 'Code Font',
              value: state.codeFontFamily,
              options: AppCodeFontFamily.values,
              labelBuilder: (fontFamily) => fontFamily.label,
              optionBuilder: _codeFontOption,
              onChanged: (value) {
                if (value != null) {
                  settingsCubit.setCodeFontFamily(value);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _headingFontOption(BuildContext context, AppHeadingFontFamily fontFamily) => Text(
    fontFamily.label,
    textAlign: TextAlign.right,
    style: AppTypography.heading(fontFamily, color: context.colorScheme.onSurface),
  );

  Widget _contentFontOption(BuildContext context, AppContentFontFamily fontFamily) => Text(
    fontFamily.label,
    textAlign: TextAlign.right,
    style: AppTypography.content(fontFamily, color: context.colorScheme.onSurface),
  );

  Widget _fontSizeOption(BuildContext context, AppFontSize fontSize) => Text(
    '${fontSize.label} (${fontSize.value.toInt()})',
    textAlign: TextAlign.right,
    style: AppTypography.content(
      context.fontTheme.contentFontFamily,
      fontSize: fontSize.value,
      color: context.colorScheme.onSurface,
    ),
  );

  Widget _codeFontOption(BuildContext context, AppCodeFontFamily fontFamily) => Text(
    fontFamily.label,
    textAlign: TextAlign.right,
    style: AppTypography.code(fontFamily, color: context.colorScheme.onSurface),
  );

  Widget _buildLayoutSettings(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, color: theme.dividerColor),
            Material(
              color: theme.cardColor,
              child: Column(
                children: [
                  SettingsDropdownTile<FeedLayout>(
                    title: l10n.labelFeedLayout,
                    value: state.feedLayout,
                    options: FeedLayout.values,
                    labelBuilder: (layout) => switch (layout) {
                      FeedLayout.comfortable => l10n.messageFeedLayoutComfortable,
                      FeedLayout.compact => l10n.messageFeedLayoutCompact,
                    },
                    onChanged: (value) {
                      if (value != null) {
                        settingsCubit.setFeedLayout(value);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  SettingsDropdownTile<int?>(
                    title: l10n.labelThreadAutoCollapse,
                    subtitle: l10n.messageThreadAutoCollapseSubtitle,
                    value: state.threadAutoCollapseDepth,
                    options: const <int?>[null, 1, 2, 3, 4, 5, 6],
                    labelBuilder: (depth) => depth == null ? l10n.commonOff : l10n.formatDepth(depth),
                    onChanged: settingsCubit.setThreadAutoCollapseDepth,
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.motion_photos_off_outlined,
                    title: l10n.labelAnimations,
                    subtitle: l10n.messageTurnOffNonEssentialMotion,
                    trailing: Switch.adaptive(
                      value: state.animationsEnabled,
                      onChanged: settingsCubit.setAnimationsEnabled,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
          ],
        );
      },
    );
  }

  Widget _buildSearchSettings(BuildContext context, {required bool showTypeaheadSettings}) =>
      BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, color: context.theme.dividerColor),
            Material(
              color: context.theme.cardColor,
              child: Column(
                children: [
                  if (showTypeaheadSettings) ...[
                    Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        leading: const Icon(Icons.tune_outlined),
                        title: Text(context.l10n.labelTypeaheadProvider),
                        subtitle: Text(
                          settingsState.typeaheadProvider == 'community'
                              ? context.l10n.messageCommunityTypeaheadSelected
                              : context.l10n.messageBlueskyEndpointSelected,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton<String>(
                          segments: [
                            const ButtonSegment<String>(value: 'bluesky', label: Text('Bluesky')),
                            ButtonSegment<String>(value: 'community', label: Text(context.l10n.labelCommunity)),
                          ],
                          selected: {settingsState.typeaheadProvider},
                          onSelectionChanged: (selection) {
                            context.read<SettingsCubit>().setTypeaheadProvider(selection.first);
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  SettingsTile(
                    icon: Icons.manage_search_outlined,
                    title: context.l10n.labelSemanticSearch,
                    subtitle: context.l10n.messageManageSemanticSearchSubtitle,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.theme.dividerColor),
          ],
        ),
      );

  Widget _buildDeveloperSettings(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    final crashReportingService = _readCrashReportingServiceOrNull(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: context.theme.dividerColor),
          Material(
            color: context.theme.cardColor,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.cloud_off_outlined,
                  title: context.l10n.labelGoOffline,
                  subtitle: context.l10n.messageDeveloperGoOfflineSubtitle,
                  trailing: Switch.adaptive(value: state.simulateOffline, onChanged: settingsCubit.setSimulateOffline),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: context.l10n.labelCrashlyticsTestCrash,
                  subtitle: context.l10n.messageCrashlyticsTestCrashSubtitle,
                  trailing: const Icon(Icons.warning_amber_rounded),
                  onTap: crashReportingService?.crash,
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.integration_instructions_outlined,
                  title: context.l10n.labelCrashReportScreenTest,
                  subtitle: context.l10n.messageCrashReportScreenTestSubtitle,
                  trailing: const Icon(Icons.open_in_new_outlined),
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => RecoverableCrashTestScreen(title: context.l10n.labelCrashReportScreenTest),
                    ),
                  ),
                ),
                if (kDebugMode || kProfileMode) ...[
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.lock_reset_outlined,
                    title: context.l10n.labelForceNextXrpc401,
                    subtitle: context.l10n.messageForceNextXrpc401Subtitle,
                    trailing: const Icon(Icons.play_arrow_outlined),
                    onTap: () {
                      XrpcNetworkInterceptor.debugForceUnauthorizedOnce();
                      showAppSnackBar(context, context.l10n.messageAppViewDebug401Armed);
                    },
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: context.theme.dividerColor),
        ],
      ),
    );
  }

  CrashReportingService? _readCrashReportingServiceOrNull(BuildContext context) {
    try {
      return context.read<CrashReportingService>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  Widget _buildAdvancedSettings(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, color: context.colorScheme.outline),
            Material(
              color: context.colorScheme.surface,
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: context.l10n.labelLogs,
                    // TODO: l10n
                    subtitle: 'View app log files',
                    onTap: () => context.push('/settings/logs'),
                  ),
                  const Divider(height: 1),
                  ConstellationUrlTile(currentUrl: state.constellationUrl),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.route_outlined,
                    title: context.l10n.labelAppViewProvider,
                    subtitle: _appViewSubtitle(context, state.appViewProvider),
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
                  SettingsTile(
                    icon: Icons.compare_arrows_outlined,
                    title: context.l10n.labelCrossProviderFallback,
                    subtitle: context.l10n.messageCrossProviderFallbackSubtitle,
                    trailing: Switch.adaptive(
                      value: state.crossProviderFallbackEnabled,
                      onChanged: settingsCubit.setCrossProviderFallbackEnabled,
                    ),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.alt_route_outlined,
                    title: context.l10n.labelSlingshotIdentityFallback,
                    subtitle: context.l10n.messageSlingshotIdentityFallbackSubtitle,
                    trailing: Switch.adaptive(
                      value: state.slingshotIdentityFallbackEnabled,
                      onChanged: settingsCubit.setSlingshotIdentityFallbackEnabled,
                    ),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.bug_report_outlined,
                    title: context.l10n.labelCrashReporting,
                    subtitle: state.crashReportingEnabled
                        ? context.l10n.messageCrashReportingEnabled
                        : context.l10n.messageCrashReportingDisabled,
                    trailing: Switch.adaptive(
                      value: state.crashReportingEnabled,
                      onChanged: (enabled) => unawaited(_handleCrashReportingToggle(context, enabled)),
                    ),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.monitor_heart_outlined,
                    title: context.l10n.labelProviderDiagnostics,
                    subtitle: context.l10n.messageProviderDiagnosticsSubtitle,
                  ),
                  ConnectionDetailRow(
                    label: context.l10n.labelActiveProvider,
                    value: AppViewProviders.providerDisplayName(state.appViewProvider),
                  ),
                  const Divider(height: 1),
                  ConnectionDetailRow(
                    label: context.l10n.labelHealth,
                    value: state.appViewHealthSummary ?? context.l10n.commonNotCheckedYet,
                  ),
                  const Divider(height: 1),
                  ConnectionDetailRow(
                    label: context.l10n.labelLastHealthCheck,
                    value: state.appViewHealthCheckedAt == null
                        ? context.l10n.commonNever
                        : formatTimestamp(state.appViewHealthCheckedAt!.toLocal()),
                  ),
                  const Divider(height: 1),
                  ConnectionDetailRow(
                    label: context.l10n.labelLastFallback,
                    value: state.appViewLastFallback ?? context.l10n.commonNone,
                  ),
                  const Divider(height: 1),
                  ConnectionDetailRow(
                    label: context.l10n.labelLastError,
                    value: state.appViewLastError ?? context.l10n.commonNone,
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.medical_information_outlined,
                    title: context.l10n.labelRefreshProviderHealth,
                    subtitle: context.l10n.messageRefreshProviderHealthSubtitle,
                    trailing: state.appViewHealthRefreshing
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh_outlined),
                    onTap: state.appViewHealthRefreshing
                        ? null
                        : () {
                            unawaited(settingsCubit.refreshAppViewHealth());
                          },
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.theme.dividerColor),
          ],
        );
      },
    );
  }

  String _appViewSubtitle(BuildContext context, String providerKey) {
    final provider = AppViewProviders.providerDisplayName(providerKey);
    return context.l10n.formatAppViewProviderSelected(provider);
  }

  Future<void> _confirmAndApplyProviderChange(BuildContext context, String selectedProvider) async {
    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.dialogSwitchAppViewProviderTitle),
        content: Text(context.l10n.dialogSwitchAppViewProviderContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.buttonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.buttonApplyAndRestart),
          ),
        ],
      ),
    );

    if (shouldApply != true || !context.mounted) {
      return;
    }

    await context.read<SettingsCubit>().setAppViewProvider(selectedProvider);
  }

  Future<void> _handleCrashReportingToggle(BuildContext context, bool enabled) async {
    final settingsCubit = context.read<SettingsCubit>();
    final crashReportingService = context.read<CrashReportingService>();
    await settingsCubit.setCrashReportingEnabled(enabled);
    await settingsCubit.setCrashReportingConsentPrompted(true);
    await crashReportingService.setCollectionEnabled(enabled);
    if (enabled) {
      await crashReportingService.sendUnsentReports();
      return;
    }
    await crashReportingService.deleteUnsentReports();
  }

  Widget _buildTroubleshootingSettings(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Divider(height: 1, color: context.theme.dividerColor),
      Material(
        color: context.theme.cardColor,
        child: Column(
          children: [
            SettingsTile(
              icon: Icons.cached_outlined,
              title: context.l10n.labelClearCache,
              subtitle: context.l10n.messageClearCacheSubtitle,
              onTap: () => unawaited(_confirmAndClearCaches(context)),
            ),
            const Divider(height: 1),
            SettingsTile(
              icon: Icons.manage_accounts_outlined,
              title: context.l10n.labelResetSignInData,
              subtitle: context.l10n.messageResetSignInDataSubtitle,
              isDestructive: true,
              onTap: () => unawaited(_confirmAndClearLocalAuthData(context)),
            ),
          ],
        ),
      ),
      Divider(height: 1, color: context.theme.dividerColor),
    ],
  );

  Future<void> _confirmAndClearCaches(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.dialogClearCacheTitle),
        content: Text(context.l10n.dialogClearCacheContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.buttonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.buttonClearCache),
          ),
        ],
      ),
    );

    if (shouldClear != true || !context.mounted) {
      return;
    }

    try {
      await context.read<LocalCacheMaintenanceService>().clearCaches();
      if (context.mounted) {
        showAppSnackBar(context, context.l10n.labelCacheCleared);
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, context.l10n.errorFailedToClearCache(error), isError: true);
      }
    }
  }

  Future<void> _confirmAndClearLocalAuthData(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.dialogResetSignInDataTitle),
        content: Text(context.l10n.dialogResetSignInDataContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.buttonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.buttonResetSignInData),
          ),
        ],
      ),
    );

    if (shouldClear != true || !context.mounted) {
      return;
    }

    context.read<AuthBloc>().add(const LocalAuthDataClearRequested());
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
    final l10n = context.l10n;
    if (service == null) {
      return SettingsTile(
        icon: Icons.shield_outlined,
        title: l10n.labelContentModeration,
        subtitle: l10n.messageContentModerationSubtitle,
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
            SettingsTile(
              icon: Icons.visibility_outlined,
              title: l10n.labelAdultContent,
              subtitle: adultEnabled ? l10n.messageAdultContentEnabled : l10n.messageAdultContentRequired,
              trailing: Switch.adaptive(value: adultEnabled, onChanged: _isUpdating ? null : _toggleAdultContent),
            ),
            const Divider(height: 1),
            SettingsTile(
              icon: Icons.policy_outlined,
              title: l10n.labelContentModeration,
              subtitle: l10n.formatContentModerationCustomLabelers(customLabelers),
              onTap: () => context.push('/settings/moderation'),
            ),
          ],
        );
      },
    );
  }
}
