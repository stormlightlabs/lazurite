import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/alt_text_editor_sheet.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/composer_text_field.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/media_picker_row.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/publish_button.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/quote_post_card.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/reply_context_card.dart';

/// Maximum character limit for posts (grapheme clusters).
const int kMaxPostLength = 300;

/// Character count at which warning styling is applied.
const int kWarningThreshold = 20;

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
  bool get _isNearLimit => _characterCount > kMaxPostLength - kWarningThreshold && !_isOverLimit;

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

    if (currentCount >= 4) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (!mounted) return;

    final picker = ImagePicker();
    final notifier = ref.read(composerProvider(_args).notifier);

    if (source == ImageSource.camera) {
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final mimeType = _getMimeType(image.path);
        await notifier.addMedia(image.path, mimeType);
      }
    } else {
      final images = await picker.pickMultiImage(limit: 4 - currentCount);
      if (images.isNotEmpty) {
        for (final image in images) {
          final mimeType = _getMimeType(image.path);
          await notifier.addMedia(image.path, mimeType);
        }
      }
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

  @override
  Widget build(BuildContext context) {
    final composerAsync = ref.watch(composerProvider(_args));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

          return Stack(
            children: [
              SingleChildScrollView(
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
                      ),
                    ),
                    if (mediaPaths.isNotEmpty || state.draft?.media.length != 4)
                      MediaPickerRow(
                        mediaPaths: mediaPaths,
                        onAddMedia: _pickMedia,
                        onRemoveMedia: _removeMedia,
                        onTapMedia: _openAltTextEditor,
                        altTextIndicators:
                            state.draft?.media
                                .map((m) => m.altText != null && m.altText!.isNotEmpty)
                                .toList() ??
                            [],
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        '${kMaxPostLength - _characterCount}',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isOverLimit
                              ? colorScheme.error
                              : _isNearLimit
                              ? colorScheme.tertiary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    if (state.error != null)
                      Padding(
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
                error.toString(),
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
