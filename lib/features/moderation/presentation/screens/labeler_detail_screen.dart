import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_labeler_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';

class LabelerDetailScreen extends StatefulWidget {
  const LabelerDetailScreen({super.key, required this.did});

  final String did;

  @override
  State<LabelerDetailScreen> createState() => _LabelerDetailScreenState();
}

class _LabelerDetailScreenState extends State<LabelerDetailScreen> {
  Future<_LabelerDetailData>? _loadFuture;
  bool _isUpdatingSubscription = false;

  ModerationService get _service => context.read<ModerationService>();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _loadFuture = _loadData();
    });
  }

  Future<_LabelerDetailData> _loadData() async {
    await _service.ensureInitialized();
    final details = await _service.getLabelerDetails(widget.did);
    if (details == null) {
      throw Exception('Labeler not found.');
    }

    final currentLabelers = _service.currentPrefs?.labelers.map((labeler) => labeler.did).toSet() ?? const <String>{};

    return _LabelerDetailData(
      labeler: details,
      adultContentEnabled: adultContentEnabledFromPreferences(_service.currentPreferences),
      currentPreferences: _service.currentPreferences,
      isSubscribed: currentLabelers.contains(widget.did),
    );
  }

  Future<void> _toggleSubscription(bool value) async {
    setState(() => _isUpdatingSubscription = true);
    try {
      if (value) {
        await _service.subscribeToLabeler(widget.did);
      } else {
        await _service.unsubscribeFromLabeler(widget.did);
      }
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingSubscription = false);
      }
    }
  }

  Future<void> _updatePreference({required String label, required KnownContentLabelPrefVisibility visibility}) async {
    try {
      await _service.setLabelPreference(label: label, labelerDid: widget.did, visibility: visibility);
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update preference: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labeler')),
      body: FutureBuilder<_LabelerDetailData>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Unable to load labeler', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _reload, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final labeler = data.labeler;
          final creator = labeler.creator;
          final definitions = labeler.policies.labelValueDefinitions ?? const [];
          final locale = Localizations.localeOf(context);
          final isOfficial = widget.did == officialBlueskyLabelerDid;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ModeratedAvatar(
                          size: 64,
                          imageUrl: creator.avatar,
                          initials: _initials(creator.displayName ?? creator.handle),
                          shape: BoxShape.circle,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                creator.displayName ?? creator.handle,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${creator.handle}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (creator.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      Text(creator.description!, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PolicyChip(label: '${definitions.length} custom labels'),
                        _PolicyChip(label: '${labeler.policies.labelValues.length} published values'),
                        if (isOfficial) const _PolicyChip(label: 'Built-in moderation'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      value: data.isSubscribed || isOfficial,
                      onChanged: isOfficial || _isUpdatingSubscription ? null : _toggleSubscription,
                      title: Text(isOfficial ? 'Built-in moderation' : 'Subscribed'),
                      subtitle: Text(
                        isOfficial
                            ? 'This labeler is always active.'
                            : 'Subscribed labelers are added to your moderation headers and preferences.',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Published policies'.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final value in labeler.policies.labelValues) _PolicyChip(label: value.toJson())],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Label preferences'.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              if (definitions.isEmpty)
                const _PreferenceCard(
                  child: ListTile(
                    title: Text('No custom label definitions'),
                    subtitle: Text('This labeler publishes values, but not localized custom definitions.'),
                  ),
                )
              else
                for (final definition in definitions) ...[
                  _PreferenceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatLocalizedLabelName(definition.locales, locale, fallback: definition.identifier),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatLocalizedLabelDescription(
                              definition.locales,
                              locale,
                              fallback: 'No description available for this label.',
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _PolicyChip(label: 'ID ${definition.identifier}'),
                              _PolicyChip(label: 'Blur ${definition.blurs.toJson()}'),
                              _PolicyChip(label: 'Severity ${definition.severity.toJson()}'),
                              _PolicyChip(
                                label: 'Default ${visibilityFromDefaultSetting(definition.defaultSetting).name}',
                              ),
                              if (definition.adultOnly ?? false) const _PolicyChip(label: '18+'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SegmentedButton<KnownContentLabelPrefVisibility>(
                            segments: const [
                              ButtonSegment(value: KnownContentLabelPrefVisibility.ignore, label: Text('Ignore')),
                              ButtonSegment(value: KnownContentLabelPrefVisibility.warn, label: Text('Warn')),
                              ButtonSegment(value: KnownContentLabelPrefVisibility.hide, label: Text('Hide')),
                            ],
                            selected: {
                              resolveLabelPreference(
                                data.currentPreferences,
                                label: definition.identifier,
                                labelerDid: widget.did,
                                fallback: visibilityFromDefaultSetting(definition.defaultSetting),
                              ),
                            },
                            onSelectionChanged: (definition.adultOnly ?? false) && !data.adultContentEnabled
                                ? null
                                : (selection) =>
                                      _updatePreference(label: definition.identifier, visibility: selection.first),
                          ),
                          if ((definition.adultOnly ?? false) && !data.adultContentEnabled) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Enable adult content to change this 18+ label.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2).toList();
    if (parts.isEmpty) {
      return '?';
    }
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

class _LabelerDetailData {
  const _LabelerDetailData({
    required this.labeler,
    required this.adultContentEnabled,
    required this.currentPreferences,
    required this.isSubscribed,
  });

  final LabelerViewDetailed labeler;
  final bool adultContentEnabled;
  final List<UPreferences> currentPreferences;
  final bool isSubscribed;
}

class _PolicyChip extends StatelessWidget {
  const _PolicyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
