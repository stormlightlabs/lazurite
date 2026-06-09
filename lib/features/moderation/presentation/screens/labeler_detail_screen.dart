import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/moderation/data/moderation_constants.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

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
    if (!mounted) {
      return;
    }
    setState(() {
      _loadFuture = _loadData();
    });
  }

  Future<_LabelerDetailData> _loadData() async {
    await _service.ensureInitialized();
    final details = await _service.getLabelerDetails(widget.did);
    if (details == null) {
      throw const _LabelerNotFoundException();
    }

    final currentLabelers = _service.currentPrefs?.labelers.map((labeler) => labeler.did).toSet() ?? const <String>{};

    return _LabelerDetailData(
      labeler: details,
      adultContentEnabled: adultContentEnabledFromPreferences(_service.currentPreferences),
      currentPreferences: _service.currentPreferences,
      isSubscribed: widget.did == officialBlueskyLabelerDid || currentLabelers.contains(widget.did),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorFailedToUpdateLabelerSubscription(error))));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorFailedToUpdateLabelPreference(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.labelLabeler)),
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
                  Text(context.l10n.errorUnableToLoadLabeler, style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_errorMessageFor(context, snapshot.error), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _reload, child: Text(context.l10n.buttonRetry)),
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
            Material(
              color: context.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: context.colorScheme.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ModeratedAvatar(
                          size: 64,
                          imageUrl: creator.avatar,
                          initials: formatInitials(creator.displayName ?? creator.handle),
                          shape: BoxShape.circle,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                creator.displayName ?? creator.handle,
                                style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${creator.handle}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.labelLabeler,
                                style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      labeler.uri.toString(),
                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                    if (creator.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      Text(creator.description!, style: context.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PolicyChip(label: context.l10n.formatCustomLabelCount(definitions.length)),
                        _PolicyChip(label: context.l10n.formatPublishedValueCount(labeler.policies.labelValues.length)),
                        if (isOfficial) _PolicyChip(label: context.l10n.labelBuiltInModeration),
                      ],
                    ),
                    if (_hasScopeMetadata(labeler)) ...[const SizedBox(height: 16), _ScopeMetadata(labeler: labeler)],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/${Uri(pathSegments: ['profile', creator.did])}'),
                      icon: const Icon(Icons.person_outline),
                      label: Text(context.l10n.labelOpenCreatorAccountProfile),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: data.isSubscribed || isOfficial,
                      onChanged: isOfficial || _isUpdatingSubscription ? null : _toggleSubscription,
                      title: Text(isOfficial ? context.l10n.labelBuiltInModeration : context.l10n.labelSubscribed),
                      subtitle: Text(
                        isOfficial
                            ? context.l10n.messageBuiltInLabelerAlwaysActive
                            : context.l10n.messageSubscribedLabelersHeaders,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.labelPublishedPolicies.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colorScheme.outlineVariant),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final value in labeler.policies.labelValues) _PolicyChip(label: value.toJson())],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.labelLabelPreferences.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            if (definitions.isEmpty)
              _PreferenceCard(
                child: ListTile(
                  title: Text(context.l10n.labelNoCustomLabelDefinitions),
                  subtitle: Text(context.l10n.messageNoCustomLabelDefinitions),
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
                          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatLocalizedLabelDescription(
                            definition.locales,
                            locale,
                            fallback: context.l10n.messageNoLabelDescriptionAvailable,
                          ),
                          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PolicyChip(label: context.l10n.formatPolicyId(definition.identifier)),
                            _PolicyChip(label: context.l10n.formatPolicyBlur(definition.blurs.toJson())),
                            _PolicyChip(label: context.l10n.formatPolicySeverity(definition.severity.toJson())),
                            _PolicyChip(
                              label: context.l10n.formatPolicyDefault(
                                visibilityFromDefaultSetting(definition.defaultSetting).name,
                              ),
                            ),
                            if (definition.adultOnly ?? false) _PolicyChip(label: context.l10n.labelAdultOnlyShort),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<KnownContentLabelPrefVisibility>(
                          segments: [
                            ButtonSegment(
                              value: KnownContentLabelPrefVisibility.ignore,
                              label: Text(context.l10n.labelContentPreferenceIgnore),
                            ),
                            ButtonSegment(
                              value: KnownContentLabelPrefVisibility.warn,
                              label: Text(context.l10n.labelContentPreferenceWarn),
                            ),
                            ButtonSegment(
                              value: KnownContentLabelPrefVisibility.hide,
                              label: Text(context.l10n.labelContentPreferenceHide),
                            ),
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
                            context.l10n.messageEnableAdultContentForLabel,
                            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
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

class _ScopeMetadata extends StatelessWidget {
  const _ScopeMetadata({required this.labeler});

  final LabelerViewDetailed labeler;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.labelPublishedScope,
          style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...(labeler.reasonTypes ?? []).map((r) => _PolicyChip(label: context.l10n.formatReasonScope(r.toJson()))),
            ...(labeler.subjectTypes ?? const []).map(
              (s) => _PolicyChip(label: context.l10n.formatSubjectScope(s.toJson())),
            ),
            ...(labeler.subjectCollections ?? []).map((c) => _PolicyChip(label: c)),
          ],
        ),
      ],
    );
  }
}

class _PolicyChip extends StatelessWidget {
  const _PolicyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(label, style: context.textTheme.labelSmall),
  );
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colorScheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: context.colorScheme.outlineVariant),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
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

class _LabelerNotFoundException implements Exception {
  const _LabelerNotFoundException();
}

String _errorMessageFor(BuildContext context, Object? error) {
  if (error is _LabelerNotFoundException) {
    return context.l10n.errorLabelerNotFound;
  }
  return '$error';
}

bool _hasScopeMetadata(LabelerViewDetailed labeler) =>
    (labeler.reasonTypes?.isNotEmpty ?? false) ||
    (labeler.subjectTypes?.isNotEmpty ?? false) ||
    (labeler.subjectCollections?.isNotEmpty ?? false);
