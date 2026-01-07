import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings_providers.dart';
import '../../domain/bluesky_preferences.dart';
import '../widgets/label_visibility_selector.dart';
import '../widgets/settings_section.dart';

/// Content moderation settings screen.
///
/// Allows users to configure content label visibility preferences,
/// including adult content toggle and individual label visibility settings.
/// Changes are persisted locally and synced to the user's Bluesky account.
class ContentModerationScreen extends ConsumerWidget {
  const ContentModerationScreen({super.key});

  /// Standard Bluesky content labels grouped by category.
  static const _labelCategories = <String, List<_LabelInfo>>{
    'Sexual Content': [
      _LabelInfo(
        id: 'sexual',
        name: 'Sexually Suggestive',
        description: 'Content that is sexually suggestive',
      ),
      _LabelInfo(id: 'nudity', name: 'Nudity', description: 'Artistic or non-sexual nudity'),
      _LabelInfo(id: 'porn', name: 'Pornography', description: 'Explicit sexual content'),
    ],
    'Violence': [
      _LabelInfo(
        id: 'graphic-media',
        name: 'Graphic Media',
        description: 'Graphic or violent imagery',
      ),
      _LabelInfo(id: 'gore', name: 'Gore', description: 'Extremely graphic violence'),
    ],
    'Other': [
      _LabelInfo(id: 'spam', name: 'Spam', description: 'Unsolicited or repetitive content'),
      _LabelInfo(
        id: 'impersonation',
        name: 'Impersonation',
        description: 'Accounts impersonating others',
      ),
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adultPrefAsync = ref.watch(adultContentPrefProvider);
    final labelPrefsAsync = ref.watch(contentLabelPrefsProvider);
    final labelersPrefAsync = ref.watch(labelersPrefProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Content Moderation')),
      body: adultPrefAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (adultPref) => labelPrefsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (labelPrefs) => labelersPrefAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (labelersPref) =>
                _buildContent(context, ref, adultPref, labelPrefs, labelersPref),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AdultContentPref adultPref,
    ContentLabelPrefs labelPrefs,
    LabelersPref labelersPref,
  ) {
    return ListView(
      children: [
        _buildAdultContentSection(context, ref, adultPref),
        const Divider(),
        ..._buildLabelSections(context, ref, labelPrefs, adultPref.enabled),
        if (labelersPref.labelers.isNotEmpty) ...[
          const Divider(),
          _buildLabelersSection(context, labelersPref),
        ],
      ],
    );
  }

  Widget _buildAdultContentSection(BuildContext context, WidgetRef ref, AdultContentPref pref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSection(title: 'Adult Content'),
        SwitchListTile(
          title: const Text('Enable Adult Content'),
          subtitle: const Text('Allow adult content to be shown in feeds'),
          value: pref.enabled,
          onChanged: (value) => _updateAdultContent(ref, value),
        ),
        if (!pref.enabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Adult content is currently disabled. Enable it to configure individual label visibility.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Widget> _buildLabelSections(
    BuildContext context,
    WidgetRef ref,
    ContentLabelPrefs prefs,
    bool adultEnabled,
  ) {
    final sections = <Widget>[];
    final theme = Theme.of(context);

    for (final entry in _labelCategories.entries) {
      final categoryName = entry.key;
      final labels = entry.value;

      final isAdultCategory = categoryName == 'Sexual Content';
      final isDisabled = isAdultCategory && !adultEnabled;

      sections.add(SettingsSection(title: categoryName));

      for (final label in labels) {
        final currentVisibility = prefs.getVisibility(label.id) ?? LabelVisibility.warn;

        sections.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.name, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  label.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                IgnorePointer(
                  ignoring: isDisabled,
                  child: Opacity(
                    opacity: isDisabled ? 0.5 : 1.0,
                    child: LabelVisibilitySelector(
                      value: currentVisibility,
                      onChanged: (newVisibility) =>
                          _updateLabelVisibility(ref, prefs, label.id, newVisibility),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      sections.add(const SizedBox(height: 8));
    }

    return sections;
  }

  Widget _buildLabelersSection(BuildContext context, LabelersPref pref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSection(title: 'Subscribed Labelers'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Custom moderation services providing content labels',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),
        ...pref.labelers.map(
          (labeler) => ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(labeler.did, overflow: TextOverflow.ellipsis),
            dense: true,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _updateAdultContent(WidgetRef ref, bool enabled) async {
    final repo = ref.read(blueskyPreferencesRepositoryProvider);
    await repo.updateAdultContentPref(AdultContentPref(enabled: enabled));
  }

  Future<void> _updateLabelVisibility(
    WidgetRef ref,
    ContentLabelPrefs currentPrefs,
    String labelId,
    LabelVisibility visibility,
  ) async {
    final updatedItems = <ContentLabelPref>[];

    for (final pref in currentPrefs.items) {
      if (pref.label != labelId) {
        updatedItems.add(pref);
      }
    }

    updatedItems.add(ContentLabelPref(label: labelId, visibility: visibility));

    final repo = ref.read(blueskyPreferencesRepositoryProvider);
    await repo.updateContentLabelPrefs(ContentLabelPrefs(items: updatedItems));
  }
}

/// Information about a content label for display.
class _LabelInfo {
  const _LabelInfo({required this.id, required this.name, required this.description});

  final String id;
  final String name;
  final String description;
}
