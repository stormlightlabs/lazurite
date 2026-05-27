import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/settings/bloc/account_settings_cubit.dart';
import 'package:lazurite/features/settings/presentation/widgets/settings_section.dart';
import 'package:lazurite/features/settings/presentation/widgets/settings_tiles.dart';

class AccountFeedDisplayPreferences extends StatelessWidget {
  const AccountFeedDisplayPreferences({
    super.key,
    this.padding = const EdgeInsets.only(bottom: 24),
    this.scrollController,
    this.providerDisplayName = 'Bluesky',
    this.showThreadSettings = true,
  });

  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;
  final String providerDisplayName;
  final bool showThreadSettings;

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
    builder: (context, state) {
      final preference = state.feedViewPref;
      final hideReplies = preference?.hideReplies ?? false;
      final hideRepliesByUnfollowed = preference?.hideRepliesByUnfollowed ?? true;
      final likeThreshold = preference?.hideRepliesByLikeCount;
      final hideReposts = preference?.hideReposts ?? false;
      final hideQuotePosts = preference?.hideQuotePosts ?? false;
      final threadSort = state.threadViewPref?.sort;
      final blackskyAiPreferences = state.blackskyAiPreferences;

      return ListView(
        controller: scrollController,
        padding: padding,
        shrinkWrap: true,
        children: [
          if (state.status == AccountSettingsStatus.loading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              '$providerDisplayName Settings',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Synced with $providerDisplayName via app.bsky.actor.getPreferences and putPreferences.',
              style: context.textTheme.bodySmall,
            ),
          ),
          SettingsSectionHeader('${state.feedDisplayName} feed display'),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.reply_outlined,
                title: 'Hide replies',
                subtitle: 'Only show top-level posts in this feed.',
                trailing: Switch.adaptive(
                  value: hideReplies,
                  onChanged: state.isBusy
                      ? null
                      : (value) => context.read<AccountSettingsCubit>().setHideReplies(value),
                ),
              ),
              const Divider(height: 1),
              SettingsTile(
                icon: Icons.people_outline,
                title: 'Hide replies from unfollowed accounts',
                subtitle: 'Keep replies from people you follow or yourself.',
                trailing: Switch.adaptive(
                  value: hideRepliesByUnfollowed,
                  onChanged: state.isBusy
                      ? null
                      : (value) => context.read<AccountSettingsCubit>().setHideRepliesByUnfollowed(value),
                ),
              ),
              const Divider(height: 1),
              _ReplyLikeThresholdTile(
                value: likeThreshold,
                enabled: !state.isBusy,
                onChanged: (value) => context.read<AccountSettingsCubit>().setHideRepliesByLikeCount(value),
              ),
              const Divider(height: 1),
              SettingsTile(
                icon: Icons.repeat_outlined,
                title: 'Hide reposts',
                subtitle: 'Hide posts shown because someone reposted them.',
                trailing: Switch.adaptive(
                  value: hideReposts,
                  onChanged: state.isBusy
                      ? null
                      : (value) => context.read<AccountSettingsCubit>().setHideReposts(value),
                ),
              ),
              const Divider(height: 1),
              SettingsTile(
                icon: Icons.format_quote_outlined,
                title: 'Hide quote posts',
                subtitle: 'Hide posts that quote another post.',
                trailing: Switch.adaptive(
                  value: hideQuotePosts,
                  onChanged: state.isBusy
                      ? null
                      : (value) => context.read<AccountSettingsCubit>().setHideQuotePosts(value),
                ),
              ),
            ],
          ),
          if (showThreadSettings) ...[
            const SizedBox(height: 24),
            const SettingsSectionHeader('Thread display'),
            SettingsGroup(
              children: [
                _ThreadSortTile(
                  value: threadSort,
                  enabled: !state.isBusy,
                  onChanged: (value) => context.read<AccountSettingsCubit>().setThreadSort(value),
                ),
              ],
            ),
          ],
          if (blackskyAiPreferences != null) ...[
            const SizedBox(height: 24),
            const SettingsSectionHeader('BlackSky AI preferences'),
            SettingsGroup(
              children: [
                _BlackskyAiPreferenceTile(
                  title: 'Training',
                  subtitle: 'Preference for AI model training uses.',
                  value: blackskyAiPreferences.training,
                  enabled: !state.isBusy,
                  onChanged: (value) => context.read<AccountSettingsCubit>().setBlackskyAiPreference(
                    BlackskyAiPreferenceCategory.training,
                    value,
                  ),
                ),
                const Divider(height: 1),
                _BlackskyAiPreferenceTile(
                  title: 'Inference',
                  subtitle: 'Preference for AI inference uses.',
                  value: blackskyAiPreferences.inference,
                  enabled: !state.isBusy,
                  onChanged: (value) => context.read<AccountSettingsCubit>().setBlackskyAiPreference(
                    BlackskyAiPreferenceCategory.inference,
                    value,
                  ),
                ),
                const Divider(height: 1),
                _BlackskyAiPreferenceTile(
                  title: 'Synthetic content',
                  subtitle: 'Preference for synthetic content generation uses.',
                  value: blackskyAiPreferences.syntheticContent,
                  enabled: !state.isBusy,
                  onChanged: (value) => context.read<AccountSettingsCubit>().setBlackskyAiPreference(
                    BlackskyAiPreferenceCategory.syntheticContent,
                    value,
                  ),
                ),
                const Divider(height: 1),
                _BlackskyAiPreferenceTile(
                  title: 'Embedding',
                  subtitle: 'Preference for embedding/vectorization uses.',
                  value: blackskyAiPreferences.embedding,
                  enabled: !state.isBusy,
                  onChanged: (value) => context.read<AccountSettingsCubit>().setBlackskyAiPreference(
                    BlackskyAiPreferenceCategory.embedding,
                    value,
                  ),
                ),
              ],
            ),
          ],
          if (state.status == AccountSettingsStatus.saving)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text('Saving...', style: context.textTheme.bodySmall),
            ),
          if (state.status == AccountSettingsStatus.error || state.status == AccountSettingsStatus.saveError)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Could not sync feed display preferences: ${state.message}',
                style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error),
              ),
            ),
        ],
      );
    },
  );
}

class _BlackskyAiPreferenceTile extends StatelessWidget {
  const _BlackskyAiPreferenceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final BlackskyAiPreferenceValue value;
  final bool enabled;
  final ValueChanged<BlackskyAiPreferenceValue> onChanged;

  @override
  Widget build(BuildContext context) => SettingsDropdownTile<BlackskyAiPreferenceValue>(
    title: title,
    subtitle: subtitle,
    value: value,
    options: BlackskyAiPreferenceValue.values,
    labelBuilder: _labelFor,
    onChanged: enabled ? (value) => onChanged(value ?? BlackskyAiPreferenceValue.unset) : null,
  );

  static String _labelFor(BlackskyAiPreferenceValue value) => switch (value) {
    BlackskyAiPreferenceValue.unset => 'Not Set',
    BlackskyAiPreferenceValue.allow => 'Allow',
    BlackskyAiPreferenceValue.deny => 'Deny',
  };
}

class _ThreadSortTile extends StatelessWidget {
  const _ThreadSortTile({required this.value, required this.enabled, required this.onChanged});

  final ThreadViewPrefSort? value;
  final bool enabled;
  final ValueChanged<ThreadViewPrefSort?> onChanged;

  @override
  Widget build(BuildContext context) => SettingsDropdownTile<_ThreadSortOption>(
    title: 'Thread reply sort',
    subtitle: 'Choose the default order for replies in post threads.',
    value: _ThreadSortOption.fromPreference(value),
    options: _ThreadSortOption.values,
    labelBuilder: (option) => option.label,
    onChanged: enabled ? (option) => onChanged(option?.preferenceValue) : null,
  );
}

enum _ThreadSortOption {
  defaultSort(null, 'Default'),
  oldest(KnownThreadViewPrefSort.oldest, 'Oldest first'),
  newest(KnownThreadViewPrefSort.newest, 'Newest first'),
  mostLikes(KnownThreadViewPrefSort.mostLikes, 'Most likes'),
  random(KnownThreadViewPrefSort.random, 'Random'),
  hotness(KnownThreadViewPrefSort.hotness, 'Hotness');

  const _ThreadSortOption(this.knownValue, this.label);

  final KnownThreadViewPrefSort? knownValue;
  final String label;

  ThreadViewPrefSort? get preferenceValue =>
      knownValue == null ? null : ThreadViewPrefSort.knownValue(data: knownValue!);

  static _ThreadSortOption fromPreference(ThreadViewPrefSort? sort) {
    final knownValue = sort?.knownValue;
    if (knownValue == null) {
      return _ThreadSortOption.defaultSort;
    }
    return _ThreadSortOption.values.firstWhere(
      (option) => option.knownValue == knownValue,
      orElse: () => _ThreadSortOption.defaultSort,
    );
  }
}

class _ReplyLikeThresholdTile extends StatelessWidget {
  const _ReplyLikeThresholdTile({required this.value, required this.enabled, required this.onChanged});

  static const int _off = -1;
  static const List<int> _options = [_off, 1, 2, 5, 10, 25, 50];

  final int? value;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => SettingsDropdownTile<int>(
    title: 'Hide replies below likes',
    subtitle: 'Replies with fewer likes are hidden.',
    value: _options.contains(value) ? value! : _off,
    options: _options,
    labelBuilder: (threshold) => threshold == _off ? 'Off' : threshold.toString(),
    onChanged: enabled ? (threshold) => onChanged(threshold == _off ? null : threshold) : null,
  );
}
