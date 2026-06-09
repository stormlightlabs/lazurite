import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/moderation/data/label_detail_models.dart';
import 'package:lazurite/features/moderation/data/label_detail_repository.dart';
import 'package:lazurite/features/moderation/data/moderation_constants.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/labeler_navigation.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

ValueChanged<LabelContext>? labelDetailTapHandler(BuildContext context) {
  if (maybeModerationService(context) == null) {
    return null;
  }
  return (labelContext) => showLabelDetailBottomSheet(context, labelContext);
}

Future<void> showLabelDetailBottomSheet(BuildContext context, LabelContext labelContext) {
  final moderationService = maybeModerationService(context);
  if (moderationService == null) {
    return Future<void>.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ModerationService>.value(value: moderationService),
        if (_maybeRead<AppDatabase>(context) case final database?)
          RepositoryProvider<AppDatabase>.value(value: database),
      ],
      child: LabelDetailSheet(labelContext: labelContext),
    ),
  );
}

class LabelDetailSheet extends StatefulWidget {
  const LabelDetailSheet({super.key, required this.labelContext, this.loadLabelDetail});

  final LabelContext labelContext;
  final Future<LabelDetailData> Function(LabelContext context, Iterable<String> preferredLanguages)? loadLabelDetail;

  @override
  State<LabelDetailSheet> createState() => _LabelDetailSheetState();
}

class _LabelDetailSheetState extends State<LabelDetailSheet> {
  Future<LabelDetailData>? _future;
  bool _isUpdatingSubscription = false;
  bool _isUpdatingPreference = false;
  bool _didStartLoad = false;

  ModerationService get _service => context.read<ModerationService>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _didStartLoad = true;
      _reload();
    }
  }

  void _reload() => setState(() {
    final locale = Localizations.localeOf(context);
    final languages = [locale.toLanguageTag(), locale.languageCode];
    final loader = widget.loadLabelDetail ?? _defaultLoader;
    _future = loader(widget.labelContext, languages);
  });

  Future<LabelDetailData> _defaultLoader(LabelContext context, Iterable<String> preferredLangs) {
    return LabelDetailRepository(
      moderationService: _service,
      database: _maybeRead<AppDatabase>(this.context),
    ).getLabelDetail(context, preferredLanguages: preferredLangs);
  }

  Future<void> _toggleSubscription(LabelDetailData data) async {
    setState(() => _isUpdatingSubscription = true);
    try {
      if (data.isSubscribed) {
        await _service.unsubscribeFromLabeler(data.context.labelerDid);
      } else {
        await _service.subscribeToLabeler(data.context.labelerDid);
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

  Future<void> _updatePreference(LabelDetailData data, KnownContentLabelPrefVisibility visibility) async {
    setState(() => _isUpdatingPreference = true);
    try {
      await _service.setLabelPreference(
        label: data.context.identifier,
        labelerDid: data.context.labelerDid,
        visibility: visibility,
      );
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorFailedToUpdateLabelPreference(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPreference = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FutureBuilder<LabelDetailData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.errorUnableToLoadLabelDetails, style: context.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: _reload, child: Text(context.l10n.buttonRetry)),
              ],
            ),
          );
        }

        return _LabelDetailContent(
          data: snapshot.data!,
          isUpdatingSubscription: _isUpdatingSubscription,
          isUpdatingPreference: _isUpdatingPreference,
          onToggleSubscription: _toggleSubscription,
          onUpdatePreference: _updatePreference,
        );
      },
    ),
  );
}

class _LabelDetailContent extends StatelessWidget {
  const _LabelDetailContent({
    required this.data,
    required this.isUpdatingSubscription,
    required this.isUpdatingPreference,
    required this.onToggleSubscription,
    required this.onUpdatePreference,
  });

  final LabelDetailData data;
  final bool isUpdatingSubscription;
  final bool isUpdatingPreference;
  final ValueChanged<LabelDetailData> onToggleSubscription;
  final void Function(LabelDetailData data, KnownContentLabelPrefVisibility visibility) onUpdatePreference;

  @override
  Widget build(BuildContext context) {
    final definition = data.definition;
    final labeler = data.labeler;
    final creator = labeler?.creator;
    final description = data.description?.isNotEmpty == true
        ? data.description!
        : definition == null
        ? context.l10n.messageNoDescriptionForRawLabel
        : context.l10n.messageNoLabelDescriptionAvailable;

    final isOfficial = data.context.labelerDid == officialBlueskyLabelerDid;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            data.displayName ?? humanizeModerationLabel(data.context.identifier),
            style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            definition == null ? context.l10n.formatRawLabelValue(data.context.identifier) : description,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          if (definition == null || data.description?.isNotEmpty != true) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          _Notice(text: context.l10n.messageThirdPartyLabelerDefinitionNotice),
          const SizedBox(height: 20),
          _LabelerIdentity(creator: creator, labelerDid: data.context.labelerDid, serviceUri: labeler?.uri.toString()),
          if (data.isPartial) ...[
            const SizedBox(height: 12),
            _Notice(
              text: labeler == null
                  ? context.l10n.messageLabelerDetailsUnavailableCached
                  : context.l10n.messageNoMatchingLabelDefinition,
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (definition != null) ...[
                _Chip(context.l10n.formatPolicySeverity(definition.severity.toJson())),
                _Chip(context.l10n.formatPolicyBlur(definition.blurs.toJson())),
                _Chip(context.l10n.formatPolicyDefault(visibilityFromDefaultSetting(definition.defaultSetting).name)),
                if (definition.adultOnly ?? false) _Chip(context.l10n.labelAdultOnlyShort),
              ],
              _Chip(context.l10n.formatActiveLabelPreference(data.effectivePreference.name)),
              if (data.context.isNegation) _Chip(context.l10n.labelLabelNegation),
              if (data.context.expiresAt != null) _Chip(_expiryLabel(context, data.context.expiresAt!)),
            ],
          ),
          const SizedBox(height: 18),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(context.l10n.labelProtocolDetails),
            children: [_ProtocolDetails(data.context)],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.push(labelerProfileLocation(data.context.labelerDid));
            },
            icon: const Icon(Icons.open_in_new),
            label: Text(context.l10n.labelOpenLabelerProfile),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isOfficial || isUpdatingSubscription ? null : () => onToggleSubscription(data),
            icon: Icon(data.isSubscribed || isOfficial ? Icons.remove_circle_outline : Icons.add_circle_outline),
            label: Text(
              isOfficial
                  ? context.l10n.labelBuiltInModeration
                  : data.isSubscribed
                  ? context.l10n.labelUnsubscribeFromLabeler
                  : context.l10n.labelSubscribeToLabeler,
            ),
          ),
          if (definition != null) ...[
            const SizedBox(height: 12),
            Text(
              context.l10n.labelLabelPreference,
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
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
              selected: {data.effectivePreference},
              onSelectionChanged: !data.canConfigurePreference || isUpdatingPreference
                  ? null
                  : (selection) => onUpdatePreference(data, selection.first),
            ),
            if (!data.canConfigurePreference) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.messageEnableAdultContentForLabel,
                style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _LabelerIdentity extends StatelessWidget {
  const _LabelerIdentity({required this.creator, required this.labelerDid, this.serviceUri});

  final ProfileView? creator;
  final String labelerDid;
  final String? serviceUri;

  @override
  Widget build(BuildContext context) {
    final title = creator?.displayName ?? creator?.handle ?? labelerDid;
    return Material(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ModeratedAvatar(
              size: 44,
              imageUrl: creator?.avatar,
              initials: formatInitials(title),
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  if (creator?.handle != null) Text('@${creator!.handle}', style: context.textTheme.bodySmall),
                  Text(
                    labelerDid,
                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                  if (serviceUri != null)
                    Text(
                      serviceUri!,
                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtocolDetails extends StatelessWidget {
  const _ProtocolDetails(this.context);

  final LabelContext context;

  @override
  Widget build(BuildContext buildContext) {
    final rows = <(String, String?)>[
      ('src', context.labelerDid),
      ('uri', context.subjectUri),
      ('cid', context.subjectCid),
      ('val', context.identifier),
      ('cts', context.createdAt?.toIso8601String()),
      ('exp', context.expiresAt?.toIso8601String()),
      ('neg', context.isNegation.toString()),
      ('ver', context.version?.toString()),
    ];
    return Column(
      children: [
        for (final row in rows)
          if (row.$2?.isNotEmpty ?? false) _ProtocolRow(name: row.$1, value: row.$2!),
      ],
    );
  }
}

class _ProtocolRow extends StatelessWidget {
  const _ProtocolRow({required this.name, required this.value});

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Text(name, style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Expanded(child: SelectableText(value, style: context.textTheme.bodySmall)),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

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

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colorScheme.secondaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(text, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSecondaryContainer)),
  );
}

T? _maybeRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } catch (_) {
    return null;
  }
}

String _expiryLabel(BuildContext context, DateTime expiry) {
  final value = expiry.toLocal().toString();
  return expiry.isBefore(DateTime.now())
      ? context.l10n.formatExpiredLabel(value)
      : context.l10n.formatExpiresLabel(value);
}
