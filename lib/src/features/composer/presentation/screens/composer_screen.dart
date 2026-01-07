import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/composer_text_field.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/media_picker_row.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/publish_button.dart';

/// Maximum character limit for posts (grapheme clusters).
const int kMaxPostLength = 300;

/// Character count at which warning styling is applied.
const int kWarningThreshold = 20;

/// Full-screen composer for creating or editing posts.
class ComposerScreen extends ConsumerStatefulWidget {
  const ComposerScreen({this.draftId, super.key});

  /// Optional draft ID for editing an existing draft.
  final String? draftId;

  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen> {
  late TextEditingController _textController;
  int _characterCount = 0;
  String? _pendingThreadText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final graphemeCount = _textController.text.characters.length;
    if (graphemeCount != _characterCount) {
      setState(() {
        _characterCount = graphemeCount;
      });
    }

    ref.read(composerProvider(widget.draftId).notifier).updateText(_textController.text);
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

    ref.read(composerProvider(widget.draftId).notifier).updateText(firstPart);
  }

  Future<void> _publish() async {
    final notifier = ref.read(composerProvider(widget.draftId).notifier);
    final currentDraft = ref.read(composerProvider(widget.draftId)).asData?.value.draft;
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
    final notifier = ref.read(composerProvider(widget.draftId).notifier);
    await notifier.cancel();

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _pickMedia() async {
    final composerState = ref.read(composerProvider(widget.draftId)).asData?.value;
    final currentCount = composerState?.draft?.media.length ?? 0;

    if (currentCount >= 4) return;

    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 4 - currentCount);

    if (images.isNotEmpty) {
      final notifier = ref.read(composerProvider(widget.draftId).notifier);
      for (final image in images) {
        final mimeType = _getMimeType(image.path);
        await notifier.addMedia(image.path, mimeType);
      }
    }
  }

  String _getMimeType(String path) {
    if (path.toLowerCase().endsWith('.png')) return 'image/png';
    if (path.toLowerCase().endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _removeMedia(int index) {
    final composerState = ref.read(composerProvider(widget.draftId)).asData?.value;
    if (composerState?.draft?.media case final media?) {
      if (index < media.length) {
        ref.read(composerProvider(widget.draftId).notifier).removeMedia(media[index].id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final composerAsync = ref.watch(composerProvider(widget.draftId));
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ComposerTextField(
                        controller: _textController,
                        maxLength: kMaxPostLength,
                        hintText: "What's on your mind?",
                      ),
                    ),
                    if (mediaPaths.isNotEmpty || state.draft?.media.length != 4)
                      MediaPickerRow(
                        mediaPaths: mediaPaths,
                        onAddMedia: _pickMedia,
                        onRemoveMedia: _removeMedia,
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
