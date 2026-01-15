import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/presentation/screens/gif_picker_screen.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/alt_text_editor_sheet.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/character_count_meter.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/composer_text_field.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/content_warning_button.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/content_warning_sheet.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/language_pill.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/language_selector_sheet.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/media_picker_row.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/publish_button.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/quote_post_card.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/reply_context_card.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/threading_settings_sheet.dart';

/// Maximum character limit for posts (grapheme clusters).
const int kMaxPostLength = 300;

/// Character count at which warning styling is applied.
const int kWarningThreshold = 20;

/// Duration for quick UI polish animations.
const Duration _kComposerAnimationDuration = Duration(milliseconds: 250);

enum MediaPickerOption { camera, gallery, video, videoGallery, gif }

/// Full-screen composer for creating or editing posts.
class ComposerScreen extends ConsumerStatefulWidget {
  const ComposerScreen({this.draftId, this.replyTo, this.quoteTo, super.key});

  /// Optional draft ID for editing an existing draft.
  final String? draftId;

  /// Optional URI of the post being replied to.
  final String? replyTo;

  /// Optional URI of the post being quoted.
  final String? quoteTo;

  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen> with WidgetsBindingObserver {
  late TextEditingController _textController;
  int _characterCount = 0;
  String? _pendingThreadText;

  ComposerArgs get _args =>
      ComposerArgs(draftId: widget.draftId, replyTo: widget.replyTo, quoteTo: widget.quoteTo);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_textController.text.isNotEmpty) {
        ref.read(composerProvider(_args).notifier).forceSave(_textController.text);
      }
    }
  }

  void _onTextChanged() {
    final graphemeCount = _textController.text.characters.length;
    if (graphemeCount != _characterCount) {
      setState(() {
        _characterCount = graphemeCount;
      });
    }

    ref.read(composerProvider(_args).notifier).updateText(_textController.text);
  }

  bool get _canPublish {
    return _characterCount > 0 && _characterCount <= kMaxPostLength;
  }

  bool get _isOverLimit => _characterCount > kMaxPostLength;
  void _splitText() {
    final text = _textController.text;
    final characters = text.characters;
    if (characters.length <= kMaxPostLength) return;

    var splitIndex = kMaxPostLength;

    int i = kMaxPostLength;
    for (final char in characters.take(kMaxPostLength).toList().reversed) {
      if (char.trim().isEmpty) {
        splitIndex = i;
        break;
      }
      i--;
    }

    final rangeParams = characters.getRange(0, kMaxPostLength);
    int lastSpaceIndex = -1;
    int currentIndex = 0;
    for (final char in rangeParams) {
      if (char.trim().isEmpty) {
        lastSpaceIndex = currentIndex;
      }
      currentIndex++;
    }

    if (lastSpaceIndex != -1) {
      splitIndex = lastSpaceIndex + 1;
    }

    final firstPart = characters.take(splitIndex).toString();
    final secondPart = characters.skip(splitIndex).toString();

    setState(() {
      _textController.text = firstPart;
      _pendingThreadText = secondPart;
    });

    ref.read(composerProvider(_args).notifier).updateText(firstPart);
  }

  Future<void> _publish() async {
    final notifier = ref.read(composerProvider(_args).notifier);
    final currentDraft = ref.read(composerProvider(_args)).asData?.value.draft;
    final result = await notifier.publish();

    if (result != null && mounted) {
      if (_pendingThreadText != null) {
        final repository = ref.read(draftRepositoryProvider);
        final nextRootUri = currentDraft?.replyRootUri ?? result.uri;
        final nextRootCid = currentDraft?.replyRootCid ?? result.cid;

        final nextDraft = await repository.createDraft(
          text: _pendingThreadText!,
          replyParentUri: result.uri,
          replyParentCid: result.cid,
          replyRootUri: nextRootUri,
          replyRootCid: nextRootCid,
        );

        if (mounted) {
          context.pushReplacement('/compose?draftId=${nextDraft.id}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Posted! Continuing thread...')));
        }
      } else {
        context.pop();
      }
    }
  }

  Future<void> _cancel() async {
    final notifier = ref.read(composerProvider(_args).notifier);
    final state = ref.read(composerProvider(_args)).asData?.value;
    final hasContent =
        _textController.text.isNotEmpty || (state?.draft?.media.isNotEmpty ?? false);

    if (!hasContent) {
      await notifier.deleteDraft();
      if (mounted) context.pop();
      return;
    }

    if (!mounted) return;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save this draft?'),
        content: const Text(
          'You can save this to your drafts to finish later, or discard it entirely.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Discard
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Save
            child: const Text('Save Draft'),
          ),
        ],
      ),
    );

    if (shouldSave == null) {
      return;
    }

    if (shouldSave) {
      await notifier.forceSave(_textController.text);
      if (mounted) context.pop();
    } else {
      await notifier.deleteDraft();
      if (mounted) context.pop();
    }
  }

  Future<void> _pickMedia() async {
    final composerState = ref.read(composerProvider(_args)).asData?.value;
    final currentCount = composerState?.draft?.media.length ?? 0;
    final hasExternalEmbed = composerState?.draft?.externalUri != null;

    if (currentCount >= 4) return;

    final result = await showModalBottomSheet<MediaPickerOption>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: hasExternalEmbed
                  ? null
                  : () => Navigator.pop(context, MediaPickerOption.camera),
              enabled: !hasExternalEmbed,
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: hasExternalEmbed
                  ? null
                  : () => Navigator.pop(context, MediaPickerOption.gallery),
              enabled: !hasExternalEmbed,
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Record video'),
              onTap: hasExternalEmbed
                  ? null
                  : () => Navigator.pop(context, MediaPickerOption.video),
              enabled: !hasExternalEmbed,
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Choose video from gallery'),
              onTap: hasExternalEmbed
                  ? null
                  : () => Navigator.pop(context, MediaPickerOption.videoGallery),
              enabled: !hasExternalEmbed,
            ),
            ListTile(
              leading: const Icon(Icons.gif_outlined),
              title: const Text('Search GIFs'),
              onTap: () => Navigator.pop(context, MediaPickerOption.gif),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    if (!mounted) return;

    final picker = ImagePicker();
    final notifier = ref.read(composerProvider(_args).notifier);

    switch (result) {
      case MediaPickerOption.camera:
        final image = await picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          final mimeType = _getMimeType(image.path);
          await notifier.addMedia(image.path, mimeType);
        }
        break;
      case MediaPickerOption.gallery:
        final images = await picker.pickMultiImage(limit: 4 - currentCount);
        if (images.isNotEmpty) {
          for (final image in images) {
            final mimeType = _getMimeType(image.path);
            await notifier.addMedia(image.path, mimeType);
          }
        }
        break;
      case MediaPickerOption.video:
        final video = await picker.pickVideo(source: ImageSource.camera);
        if (video != null) {
          await notifier.addMedia(video.path, 'video/mp4');
        }
        break;
      case MediaPickerOption.videoGallery:
        final video = await picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          await notifier.addMedia(video.path, 'video/mp4');
        }
        break;
      case MediaPickerOption.gif:
        final composerState = ref.read(composerProvider(_args)).asData?.value;
        final hasExternalEmbed = composerState?.draft?.externalUri != null;

        if (hasExternalEmbed && mounted) {
          final shouldReplace = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Replace link card with GIF?'),
              content: const Text(
                'This will replace the link card with a GIF. The link card will be removed.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Replace'),
                ),
              ],
            ),
          );
          if (shouldReplace != true) break;
        }

        if (!mounted) break;

        final result = await Navigator.push<GifSelectionResult>(
          context,
          MaterialPageRoute(builder: (context) => const GifPickerScreen()),
        );
        if (result != null) {
          await notifier.setGifEmbed(
            uri: result.uri,
            title: result.title,
            description: result.description,
            thumbBlobJson: result.thumbBlobJson,
          );
        }
        break;
    }
  }

  String _getMimeType(String path) {
    if (path.toLowerCase().endsWith('.png')) return 'image/png';
    if (path.toLowerCase().endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _removeMedia(int index) {
    final composerState = ref.read(composerProvider(_args)).asData?.value;
    if (composerState?.draft?.media case final media?) {
      if (index < media.length) {
        ref.read(composerProvider(_args).notifier).removeMedia(media[index].id);
      }
    }
  }

  Future<void> _openAltTextEditor(int index) async {
    final composerState = ref.read(composerProvider(_args)).asData?.value;
    if (composerState?.draft?.media case final media?) {
      if (index < media.length) {
        final attachment = media[index];
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => AltTextEditorSheet(
            initialAltText: attachment.altText,
            mediaPath: attachment.localPath,
          ),
        );

        if (result != null && mounted) {
          await ref
              .read(composerProvider(_args).notifier)
              .updateMediaAltText(attachment.id, result);
        }
      }
    }
  }

  Future<void> _openLanguageSelector() async {
    final composerState = ref.read(composerProvider(_args)).asData?.value;
    final currentLangs = composerState?.draft?.langs ?? [];

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => LanguageSelectorSheet(
        selectedLanguages: currentLangs,
        onSelectionChanged: (langs) {
          ref.read(composerProvider(_args).notifier).setLanguages(langs);
        },
      ),
    );

    if (result != null && mounted) {
      await ref.read(composerProvider(_args).notifier).setLanguages(result);
    }
  }

  Future<void> _openContentWarningSelector() async {
    final composerState = ref.read(composerProvider(_args)).asData?.value;
    final currentLabels = composerState?.draft?.labels ?? [];

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ContentWarningSheet(
        selectedLabels: currentLabels,
        onSelectionChanged: (labels) {
          ref.read(composerProvider(_args).notifier).setLabels(labels);
        },
      ),
    );

    if (result != null && mounted) {
      await ref.read(composerProvider(_args).notifier).setLabels(result);
    }
  }

  Future<void> _openThreadingSettings() async {
    final composerState = ref.read(composerProvider(_args)).asData?.value;
    final currentThreadGate = composerState?.draft?.threadGateType;
    final currentQuoteDisabled = composerState?.draft?.quoteDisabled ?? false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ThreadingSettingsSheet(
        threadGateType: currentThreadGate,
        quoteDisabled: currentQuoteDisabled,
        onThreadGateChanged: (type) {
          ref.read(composerProvider(_args).notifier).setThreadGate(type);
        },
        onQuoteDisabledChanged: (disabled) {
          ref.read(composerProvider(_args).notifier).setQuoteDisabled(disabled);
        },
      ),
    );
  }

  IconData _getThreadingIcon(Draft? draft) {
    if (draft?.quoteDisabled == true) {
      return Icons.format_quote_rounded;
    }
    switch (draft?.threadGateType) {
      case ThreadGateType.mention:
        return Icons.alternate_email;
      case ThreadGateType.following:
        return Icons.people_alt;
      case ThreadGateType.mentionAndFollowing:
        return Icons.group_work;
      case null:
        return Icons.lock_open;
    }
  }

  String _getThreadingLabel(Draft? draft) {
    if (draft?.quoteDisabled == true) {
      return 'No quotes';
    }
    switch (draft?.threadGateType) {
      case ThreadGateType.mention:
        return 'Mentions only';
      case ThreadGateType.following:
        return 'Following only';
      case ThreadGateType.mentionAndFollowing:
        return 'Limited replies';
      case null:
        return 'Post settings';
    }
  }

  @override
  Widget build(BuildContext context) {
    final composerAsync = ref.watch(composerProvider(_args));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Cancel'),
        title: const Text('Compose'),
        actions: [
          composerAsync.when(
            data: (state) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isOverLimit) TextButton(onPressed: _splitText, child: const Text('Split')),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PublishButton(
                    isLoading: state.isPublishing,
                    isDisabled: !_canPublish,
                    onPressed: _canPublish ? _publish : null,
                    label: _pendingThreadText != null ? 'Next' : 'Post',
                  ),
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 8),
              child: PublishButton(isLoading: true),
            ),
            error: (_, _) => const Padding(
              padding: EdgeInsets.only(right: 8),
              child: PublishButton(isDisabled: true),
            ),
          ),
        ],
      ),
      body: composerAsync.when(
        data: (state) {
          if (state.draft != null &&
              _textController.text.isEmpty &&
              state.draft!.text.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _textController.text = state.draft!.text;
            });
          }

          final mediaPaths = state.draft?.media.map((m) => m.localPath).toList() ?? [];
          final mediaTypes = state.draft?.media.map((m) => m.mimeType).toList() ?? [];

          return SafeArea(
            child: AnimatedPadding(
              duration: _kComposerAnimationDuration,
              padding: EdgeInsets.only(bottom: insets),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.replyPost != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: ReplyContextCard(
                              author: Author(
                                did: state.replyPost!.authorDid,
                                handle: state.replyPost!.authorHandle,
                                displayName: state.replyPost!.authorDisplayName,
                                avatar: state.replyPost!.authorAvatar,
                              ),
                              text: state.replyPost!.text,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ComposerTextField(
                            controller: _textController,
                            maxLength: kMaxPostLength,
                            hintText: state.replyPost != null
                                ? 'Write your reply...'
                                : "What's on your mind?",
                            showRemainingCounter: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Flexible(
                                child: CharacterCountMeter(
                                  currentCount: _characterCount,
                                  maxCount: kMaxPostLength,
                                  warningThreshold: kWarningThreshold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedSwitcher(
                                duration: _kComposerAnimationDuration,
                                child: _pendingThreadText != null
                                    ? const Tooltip(
                                        message: 'Continue this thread after posting',
                                        child: Chip(
                                          key: ValueKey('thread-indicator'),
                                          avatar: Icon(Icons.forum_outlined, size: 16),
                                          label: Text('Next post ready'),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (state.draft?.langs.isNotEmpty ?? false)
                                ...state.draft!.langs.map(
                                  (lang) => LanguagePill(
                                    code: lang,
                                    onRemove: () => ref
                                        .read(composerProvider(_args).notifier)
                                        .setLanguages(
                                          state.draft!.langs.where((l) => l != lang).toList(),
                                        ),
                                  ),
                                ),
                              InkWell(
                                onTap: _openLanguageSelector,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorScheme.outlineVariant),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.language,
                                        size: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        state.draft?.langs.isEmpty ?? true
                                            ? 'Add language'
                                            : 'Add',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ContentWarningButton(
                                labels: state.draft?.labels ?? [],
                                onTap: _openContentWarningSelector,
                              ),
                              InkWell(
                                onTap: _openThreadingSettings,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color:
                                        state.draft?.threadGateType != null ||
                                            state.draft?.quoteDisabled == true
                                        ? colorScheme.secondaryContainer
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getThreadingIcon(state.draft),
                                        size: 16,
                                        color:
                                            state.draft?.threadGateType != null ||
                                                state.draft?.quoteDisabled == true
                                            ? colorScheme.onSecondaryContainer
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getThreadingLabel(state.draft),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color:
                                              state.draft?.threadGateType != null ||
                                                  state.draft?.quoteDisabled == true
                                              ? colorScheme.onSecondaryContainer
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: MediaPickerRow(
                              mediaPaths: mediaPaths,
                              mediaTypes: mediaTypes,
                              onAddMedia: _pickMedia,
                              onRemoveMedia: _removeMedia,
                              onTapMedia: _openAltTextEditor,
                              altTextIndicators:
                                  state.draft?.media
                                      .map((m) => m.altText != null && m.altText!.isNotEmpty)
                                      .toList() ??
                                  [],
                            ),
                          ),
                        ),
                        if (state.quotePost != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: QuotePostCard(
                              author: Author(
                                did: state.quotePost!.authorDid,
                                handle: state.quotePost!.authorHandle,
                                displayName: state.quotePost!.authorDisplayName,
                                avatar: state.quotePost!.authorAvatar,
                              ),
                              text: state.quotePost!.text,
                              imageCount: state.quotePost!.hasImages ? 1 : 0,
                            ),
                          ),
                        AnimatedSwitcher(
                          duration: _kComposerAnimationDuration,
                          child: state.error != null
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: colorScheme.error),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            state.error!,
                                            style: TextStyle(color: colorScheme.onErrorContainer),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  if (state.isPublishing)
                    Container(
                      color: colorScheme.surface.withAlpha(200),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load composer', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(
                errorMessage(error),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
