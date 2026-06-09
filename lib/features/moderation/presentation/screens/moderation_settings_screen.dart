import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/get_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/moderation/data/moderation_constants.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/labeler_navigation.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class ModerationSettingsScreen extends StatefulWidget {
  const ModerationSettingsScreen({super.key});

  @override
  State<ModerationSettingsScreen> createState() => _ModerationSettingsScreenState();
}

class _ModerationSettingsScreenState extends State<ModerationSettingsScreen> {
  Future<_ModerationSettingsData>? _loadFuture;
  bool _isUpdatingAdultContent = false;

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

  Future<_ModerationSettingsData> _loadData() async {
    await _service.ensureInitialized();

    final labelers = await _service.getSubscribedLabelers();
    LabelerViewDetailed? officialLabeler;
    try {
      officialLabeler = await _service.getLabelerDetails(officialBlueskyLabelerDid);
    } catch (_) {
      officialLabeler = null;
    }

    return _ModerationSettingsData(
      adultContentEnabled: adultContentEnabledFromPreferences(_service.currentPreferences),
      subscribedLabelers: labelers
          .where((view) => view.isLabelerViewDetailed)
          .map((view) => view.labelerViewDetailed!)
          .toList(),
      officialLabeler: officialLabeler,
    );
  }

  Future<void> _toggleAdultContent(bool enabled) async {
    setState(() => _isUpdatingAdultContent = true);
    try {
      await _service.setAdultContentEnabled(enabled);
      _reload();
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, context.l10n.errorFailedToUpdateAdultContent(error), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAdultContent = false);
      }
    }
  }

  Future<void> _unsubscribe(String did) async {
    try {
      await _service.unsubscribeFromLabeler(did);
      _reload();
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, context.l10n.errorFailedToUnsubscribeLabeler(error), isError: true);
      }
    }
  }

  Future<void> _showAddLabelerDialog() async {
    final controller = TextEditingController();
    final rootContext = context;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            Future<void> submit() async {
              final did = controller.text.trim();
              if (did.isEmpty) {
                setDialogState(() => errorText = builderContext.l10n.errorLabelerDidRequired);
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                errorText = null;
              });

              try {
                final details = await _service.getLabelerDetails(did);
                if (details == null) {
                  setDialogState(() => errorText = builderContext.l10n.errorNoLabelerFoundForDid);
                  return;
                }

                await _service.subscribeToLabeler(details.creator.did);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  _reload();

                  if (rootContext.mounted) {
                    final name = details.creator.displayName ?? details.creator.handle;
                    showAppSnackBar(rootContext, rootContext.l10n.formatSubscribedToLabeler(name));
                  }
                }
              } catch (error) {
                if (dialogContext.mounted) {
                  setDialogState(() => errorText = '$error');
                }
              } finally {
                if (dialogContext.mounted) {
                  setDialogState(() => isSubmitting = false);
                }
              }
            }

            return ConfirmationDialog(
              title: Text(builderContext.l10n.dialogAddLabelerTitle),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: builderContext.l10n.labelLabelerDid,
                        hintText: builderContext.l10n.placeholderLabelerDid,
                        errorText: errorText,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => isSubmitting ? null : submit(),
                    ),
                    const SizedBox(height: 12),
                    Text(builderContext.l10n.messageAddLabelerDidHelper, style: builderContext.textTheme.bodySmall),
                  ],
                ),
              ),
              confirmLabel: isSubmitting ? builderContext.l10n.buttonAdding : builderContext.l10n.buttonAdd,
              confirmEnabled: !isSubmitting,
              onCancel: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
              onConfirm: submit,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.labelModeration),
      actions: [IconButton(tooltip: context.l10n.labelRefresh, onPressed: _reload, icon: const Icon(Icons.refresh))],
    ),
    body: FutureBuilder<_ModerationSettingsData>(
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
                  Text(context.l10n.errorFailedToLoadModerationSettings, style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _reload, child: Text(context.l10n.buttonRetry)),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final labelers = data.subscribedLabelers;

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SettingsHero(
                title: context.l10n.labelLabelersAndContentModeration,
                subtitle: context.l10n.messageModerationSettingsHeroSubtitle,
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                child: SwitchListTile.adaptive(
                  value: data.adultContentEnabled,
                  onChanged: _isUpdatingAdultContent ? null : _toggleAdultContent,
                  title: Text(context.l10n.labelAdultContentSetting),
                  subtitle: Text(context.l10n.messageAdultContentRequiredForLabels),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: context.l10n.labelBuiltInLabeler,
                trailing: Text(
                  context.l10n.labelAlwaysOn,
                  style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              if (data.officialLabeler != null)
                _LabelerCard(
                  labeler: data.officialLabeler!,
                  isSubscribed: true,
                  isOfficial: true,
                  onTap: () => openLabelerProfile(context, data.officialLabeler!.creator.did),
                )
              else
                _SettingsCard(
                  child: ListTile(
                    title: Text(context.l10n.labelBlueskyModeration),
                    subtitle: Text(context.l10n.messageBuiltInLabelerActiveWhenUnavailable),
                  ),
                ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: context.l10n.labelCustomLabelers,
                trailing: FilledButton.tonalIcon(
                  onPressed: _showAddLabelerDialog,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.formatAddLabelerLimit(labelers.length, 20)),
                ),
              ),
              const SizedBox(height: 8),
              if (labelers.isEmpty)
                _SettingsCard(
                  child: ListTile(
                    title: Text(context.l10n.labelNoCustomLabelers),
                    subtitle: Text(context.l10n.messageNoCustomLabelers),
                  ),
                )
              else
                for (final labeler in labelers) ...[
                  _LabelerCard(
                    labeler: labeler,
                    isSubscribed: true,
                    onTap: () => openLabelerProfile(context, labeler.creator.did),
                    onUnsubscribe: () => _unsubscribe(labeler.creator.did),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    ),
  );
}

class _ModerationSettingsData {
  const _ModerationSettingsData({
    required this.adultContentEnabled,
    required this.subscribedLabelers,
    required this.officialLabeler,
  });

  final bool adultContentEnabled;
  final List<LabelerViewDetailed> subscribedLabelers;
  final LabelerViewDetailed? officialLabeler;
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: context.colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: context.textTheme.labelLarge?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(title, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(subtitle, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
      ),
      ?trailing,
    ],
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

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

class _LabelerCard extends StatelessWidget {
  const _LabelerCard({
    required this.labeler,
    required this.isSubscribed,
    required this.onTap,
    this.isOfficial = false,
    this.onUnsubscribe,
  });

  final LabelerViewDetailed labeler;
  final bool isSubscribed;
  final bool isOfficial;
  final VoidCallback onTap;
  final VoidCallback? onUnsubscribe;

  @override
  Widget build(BuildContext context) => _SettingsCard(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModeratedAvatar(
              size: 52,
              imageUrl: labeler.creator.avatar,
              initials: formatInitials(labeler.creator.displayName ?? labeler.creator.handle),
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          labeler.creator.displayName ?? labeler.creator.handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (isOfficial)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            context.l10n.labelBuiltIn,
                            style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${labeler.creator.handle}',
                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                  if (labeler.creator.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Text(
                      labeler.creator.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: context.l10n.formatDefinitionCount(
                          (labeler.policies.labelValueDefinitions ?? const []).length,
                        ),
                      ),
                      _MetaChip(label: context.l10n.formatPublishedValueCount(labeler.policies.labelValues.length)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Icon(isSubscribed ? Icons.chevron_right : Icons.add_circle_outline),
                if (!isOfficial && onUnsubscribe != null)
                  TextButton(onPressed: onUnsubscribe, child: Text(context.l10n.buttonUnsubscribe)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

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
