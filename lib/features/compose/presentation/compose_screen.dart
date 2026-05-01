import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:bluesky_text/bluesky_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/data/link_preview_service.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/external_link_preview_card.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({
    super.key,
    this.replyParentUri,
    this.replyParentCid,
    this.replyRootUri,
    this.replyRootCid,
    this.replyAuthorHandle,
    this.quoteUri,
    this.quoteCid,
    this.quoteAuthorHandle,
    this.quoteText,
    this.draftId,
    this.initialText,
    this.editPostUri,
    this.editPostCid,
    this.editRecord,
    this.typeaheadRepository,
    this.linkPreviewService,
  });

  final String? replyParentUri;
  final String? replyParentCid;
  final String? replyRootUri;
  final String? replyRootCid;
  final String? replyAuthorHandle;
  final String? quoteUri;
  final String? quoteCid;
  final String? quoteAuthorHandle;
  final String? quoteText;
  final int? draftId;
  final String? initialText;
  final String? editPostUri;
  final String? editPostCid;
  final Map<String, dynamic>? editRecord;
  final TypeaheadRepository? typeaheadRepository;
  final LinkPreviewService? linkPreviewService;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  late final _FacetHighlightController _textController;
  final FocusNode _textFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _mentionDebounce;
  Timer? _linkPreviewDebounce;
  int _mentionQueryStart = -1;
  int _mentionQueryEnd = -1;
  int _mentionSearchGeneration = 0;
  int _linkPreviewGeneration = 0;
  List<TypeaheadResult> _mentionSuggestions = const [];
  bool _isSearchingMentions = false;
  TypeaheadRepository? _typeaheadRepository;
  late final LinkPreviewService _linkPreviewService;
  LinkPreviewData? _linkPreview;
  bool _isLoadingLinkPreview = false;
  String? _hiddenPreviewUrl;
  bool _showDrafts = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.editPostUri != null && widget.editPostCid != null && widget.editRecord != null;
    _textController = _FacetHighlightController();
    _typeaheadRepository = widget.typeaheadRepository;
    if (_typeaheadRepository == null) {
      try {
        _typeaheadRepository = context.read<TypeaheadRepository>();
      } catch (_) {
        _typeaheadRepository = null;
      }
    }
    _linkPreviewService = widget.linkPreviewService ?? LinkPreviewService();
    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus) {
        _clearMentionSuggestions();
      }
    });
    if (widget.initialText?.isNotEmpty ?? false) {
      _textController.text = widget.initialText!;
    }

    if (isEditing) {
      context.read<ComposeBloc>().add(
        EditContextSet(
          postUri: widget.editPostUri!,
          postCid: widget.editPostCid!,
          record: Map<String, dynamic>.from(widget.editRecord!),
          initialText: widget.initialText,
        ),
      );
    }

    if (!isEditing && widget.draftId != null) {
      context.read<ComposeBloc>().add(DraftLoaded(widget.draftId!));
    }

    if (!isEditing && widget.replyParentUri != null && widget.replyParentCid != null) {
      context.read<ComposeBloc>().add(
        ReplyContextSet(
          parentUri: widget.replyParentUri!,
          parentCid: widget.replyParentCid!,
          rootUri: widget.replyRootUri ?? widget.replyParentUri!,
          rootCid: widget.replyRootCid ?? widget.replyParentCid!,
        ),
      );
    }

    if (!isEditing && widget.quoteUri != null && widget.quoteCid != null) {
      context.read<ComposeBloc>().add(QuoteContextSet(quoteUri: widget.quoteUri!, quoteCid: widget.quoteCid!));
    }

    _textController.addListener(_onTextChanged);
    if (!isEditing && widget.initialText?.isNotEmpty == true) {
      context.read<ComposeBloc>().add(TextChanged(widget.initialText!));
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _textFocusNode.dispose();
    _mentionDebounce?.cancel();
    _linkPreviewDebounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final bloc = context.read<ComposeBloc>();
    final text = _textController.text;
    _scheduleMentionLookup(text);
    _scheduleLinkPreviewLookup(text);
    if (bloc.state.text == text) {
      return;
    }
    bloc.add(TextChanged(text));
  }

  void _scheduleMentionLookup(String text) {
    final repository = _typeaheadRepository;
    if (repository == null || !_textFocusNode.hasFocus) {
      _clearMentionSuggestions();
      return;
    }

    final activeMention = _activeMentionQuery(text, _textController.selection);
    if (activeMention == null || activeMention.query.length < 2) {
      _clearMentionSuggestions();
      return;
    }

    _mentionQueryStart = activeMention.start;
    _mentionQueryEnd = activeMention.end;
    _mentionDebounce?.cancel();
    _mentionDebounce = Timer(const Duration(milliseconds: 220), () async {
      final generation = ++_mentionSearchGeneration;
      if (!mounted) {
        return;
      }
      setState(() => _isSearchingMentions = true);
      try {
        final results = await repository.search(query: activeMention.query, limit: 6);
        if (!mounted || generation != _mentionSearchGeneration) {
          return;
        }
        setState(() {
          _mentionSuggestions = results;
          _isSearchingMentions = false;
        });
      } catch (_) {
        if (!mounted || generation != _mentionSearchGeneration) {
          return;
        }
        setState(() {
          _mentionSuggestions = const [];
          _isSearchingMentions = false;
        });
      }
    });
  }

  void _scheduleLinkPreviewLookup(String text) {
    if (context.read<ComposeBloc>().state.isEditing) {
      _clearLinkPreview();
      return;
    }

    if (_hiddenPreviewUrl != null && !text.contains(_hiddenPreviewUrl!)) {
      _hiddenPreviewUrl = null;
    }

    final firstLink = LinkPreviewService.firstLink(text);
    if (firstLink == null) {
      _clearLinkPreview();
      return;
    }

    if (_hiddenPreviewUrl != null && _hiddenPreviewUrl == firstLink) {
      _clearLinkPreview();
      return;
    }

    if (_linkPreview?.uri == firstLink) {
      return;
    }

    _linkPreviewDebounce?.cancel();
    _linkPreviewDebounce = Timer(const Duration(milliseconds: 320), () async {
      final generation = ++_linkPreviewGeneration;
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingLinkPreview = true);
      try {
        final preview = await _linkPreviewService.fetch(firstLink);
        if (!mounted || generation != _linkPreviewGeneration) {
          return;
        }
        setState(() {
          _linkPreview = preview;
          _isLoadingLinkPreview = false;
        });
      } catch (_) {
        if (!mounted || generation != _linkPreviewGeneration) {
          return;
        }
        setState(() {
          _linkPreview = null;
          _isLoadingLinkPreview = false;
        });
      }
    });
  }

  void _clearMentionSuggestions() {
    _mentionDebounce?.cancel();
    _mentionQueryStart = -1;
    _mentionQueryEnd = -1;
    _mentionSearchGeneration++;
    if (_mentionSuggestions.isNotEmpty || _isSearchingMentions) {
      setState(() {
        _mentionSuggestions = const [];
        _isSearchingMentions = false;
      });
    }
  }

  void _clearLinkPreview() {
    _linkPreviewDebounce?.cancel();
    _linkPreviewGeneration++;
    if (_linkPreview != null || _isLoadingLinkPreview) {
      setState(() {
        _linkPreview = null;
        _isLoadingLinkPreview = false;
      });
    }
  }

  void _applyMention(TypeaheadResult result) {
    final start = _mentionQueryStart;
    final end = _mentionQueryEnd;
    if (start < 0 || end < start || end > _textController.text.length) {
      return;
    }

    final currentText = _textController.text;
    final replacement = '@${result.handle} ';
    final nextText = '${currentText.substring(0, start)}$replacement${currentText.substring(end)}';
    final cursorOffset = start + replacement.length;
    _textController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
    _clearMentionSuggestions();
  }

  ({int start, int end, String query})? _activeMentionQuery(String text, TextSelection selection) {
    if (!selection.isValid || !selection.isCollapsed) {
      return null;
    }

    final cursor = selection.baseOffset;
    if (cursor <= 0 || cursor > text.length) {
      return null;
    }

    final left = text.substring(0, cursor);
    final mentionStart = left.lastIndexOf('@');
    if (mentionStart < 0) {
      return null;
    }

    if (mentionStart > 0) {
      final prefixChar = text[mentionStart - 1];
      const allowedPrefix = '([{"\'';
      if (!RegExp(r'\s').hasMatch(prefixChar) && !allowedPrefix.contains(prefixChar)) {
        return null;
      }
    }

    final candidate = text.substring(mentionStart + 1, cursor);
    if (candidate.isEmpty || candidate.contains(RegExp(r'\s'))) {
      return null;
    }

    final suffix = cursor < text.length ? text[cursor] : '';
    if (suffix.isNotEmpty && RegExp(r'[A-Za-z0-9._-]').hasMatch(suffix)) {
      return null;
    }

    return (start: mentionStart, end: cursor, query: candidate);
  }

  Future<void> _pickImage() async {
    final state = context.read<ComposeBloc>().state;
    if (!state.canAddMoreMedia) {
      if (mounted) {
        showAppSnackBar(context, 'Maximum 4 images allowed', isError: true);
      }
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        final fileSize = await file.length();
        const maxSize = 1 * 1024 * 1024;
        if (fileSize > maxSize) {
          if (mounted) {
            showAppSnackBar(context, 'Image must be smaller than 1MB', isError: true);
          }
          return;
        }

        final extension = image.path.toLowerCase().split('.').last;
        const validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
        if (!validExtensions.contains(extension)) {
          if (mounted) {
            showAppSnackBar(context, 'Image must be JPEG, PNG, or WebP', isError: true);
          }
          return;
        }

        final bytes = await file.readAsBytes();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final int width = frameInfo.image.width;
        final int height = frameInfo.image.height;

        if (mounted) {
          context.read<ComposeBloc>().add(MediaAttached(image.path, width: width, height: height));
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to pick image: $e', isError: true);
      }
    }
  }

  Future<void> _pickVideo() async {
    final state = context.read<ComposeBloc>().state;
    if (!state.canAddVideo) {
      if (mounted) {
        showAppSnackBar(context, 'Remove existing media before adding a video', isError: true);
      }
      return;
    }

    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null && mounted) {
        context.read<ComposeBloc>().add(VideoAttached(video.path));
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to pick video: $e', isError: true);
      }
    }
  }

  Future<void> _showVideoAltTextDialog(String currentAltText) async {
    final TextEditingController altController = TextEditingController(text: currentAltText);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: const Text('Add video alt text'),
        content: TextField(
          controller: altController,
          maxLines: 3,
          maxLength: 1000,
          decoration: const InputDecoration(
            hintText: 'Describe the video for accessibility',
            border: OutlineInputBorder(),
          ),
        ),
        confirmLabel: 'Save',
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () => Navigator.pop(dialogContext, altController.text),
      ),
    );

    altController.dispose();

    if (result != null && mounted) {
      context.read<ComposeBloc>().add(VideoAltTextUpdated(result));
    }
  }

  Future<void> _showAltTextDialog(int index, String currentAltText) async {
    final TextEditingController altController = TextEditingController(text: currentAltText);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: const Text('Add alt text'),
        content: TextField(
          controller: altController,
          maxLines: 3,
          maxLength: 1000,
          decoration: const InputDecoration(
            hintText: 'Describe the image for visually impaired users',
            border: OutlineInputBorder(),
          ),
        ),
        confirmLabel: 'Save',
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () => Navigator.pop(dialogContext, altController.text),
      ),
    );

    altController.dispose();

    if (result != null && mounted) {
      context.read<ComposeBloc>().add(AltTextUpdated(index: index, altText: result));
    }
  }

  Future<void> _showSchedulePicker() async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(minutes: 5));

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) return;

    if (!mounted) return;
    final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initialDate));

    if (time == null) return;

    if (!mounted) return;
    final scheduledDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    if (scheduledDateTime.isAfter(now)) {
      context.read<ComposeBloc>().add(PostScheduled(scheduledDateTime));
    }
  }

  void _toggleDrafts() {
    if (context.read<ComposeBloc>().state.isEditing) return;
    final willShow = !_showDrafts;
    setState(() => _showDrafts = willShow);
    if (willShow) {
      context.read<ComposeBloc>().add(const DraftsRequested());
    }
  }

  String _formatDraftTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  String _videoStatusLabel(VideoAttachment video) {
    return switch (video.status) {
      VideoUploadStatus.idle => 'Ready to upload',
      VideoUploadStatus.checkingLimits => 'Checking upload limits…',
      VideoUploadStatus.uploading => video.uploadProgress > 0 ? 'Uploading… ${video.uploadProgress}%' : 'Uploading…',
      VideoUploadStatus.processing => video.uploadProgress > 0 ? 'Processing… ${video.uploadProgress}%' : 'Processing…',
      VideoUploadStatus.ready => video.altText.isNotEmpty ? 'Ready · "${video.altText}"' : 'Ready',
      VideoUploadStatus.error => video.errorMessage ?? 'Upload failed',
    };
  }

  Widget _buildDraftsPanel() {
    return BlocBuilder<ComposeBloc, ComposeState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Drafts', style: theme.textTheme.titleMedium),
                    if (state.drafts.isNotEmpty)
                      Text(
                        '${state.drafts.length} draft${state.drafts.length != 1 ? 's' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              if (state.isLoadingDrafts)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.drafts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No drafts saved',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.drafts.length,
                    itemBuilder: (context, index) {
                      final draft = state.drafts[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          draft.content.isEmpty ? '(No text)' : draft.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Text(_formatDraftTime(draft.updatedAt), style: theme.textTheme.bodySmall),
                            if (draft.scheduledAt != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Scheduled',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                          onPressed: () {
                            final bloc = context.read<ComposeBloc>();
                            showConfirmationDialog(
                              context: context,
                              title: const Text('Delete Draft?'),
                              content: const Text('This action cannot be undone.'),
                              confirmLabel: 'Delete',
                              confirmDestructive: true,
                            ).then((confirmed) {
                              if (confirmed && mounted) {
                                bloc.add(DraftDeleted(draft.id));
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() => _showDrafts = false);
                          context.read<ComposeBloc>().add(DraftLoaded(draft.id));
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMentionAutocompletePanel() {
    if (!_textFocusNode.hasFocus) {
      return const SizedBox.shrink();
    }
    if (!_isSearchingMentions && _mentionSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      constraints: const BoxConstraints(maxHeight: 220),
      child: _isSearchingMentions
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _mentionSuggestions.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: theme.colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                final actor = _mentionSuggestions[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundImage: actor.avatarUrl != null ? NetworkImage(actor.avatarUrl!) : null,
                    child: actor.avatarUrl == null
                        ? Text((actor.displayName ?? actor.handle).substring(0, 1).toUpperCase())
                        : null,
                  ),
                  title: Text(
                    actor.displayName ?? actor.handle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text('@${actor.handle}', style: theme.textTheme.bodySmall),
                  onTap: () => _applyMention(actor),
                );
              },
            ),
    );
  }

  Widget _buildQuotePreview(ComposeState state) {
    if (!state.isQuote) {
      return const SizedBox.shrink();
    }

    final quotedHandle = widget.quoteAuthorHandle?.trim();
    final quotedText = widget.quoteText?.trim() ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quotedHandle != null && quotedHandle.isNotEmpty ? 'Quoting @$quotedHandle' : 'Quoting post',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (quotedText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    quotedText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<ComposeBloc>().add(const QuoteContextCleared()),
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
            tooltip: 'Remove quoted post',
          ),
        ],
      ),
    );
  }

  Widget _buildComposerLinkPreview(ComposeState state) {
    if (_linkPreview == null || state.isQuote || state.hasMedia || state.hasVideo || state.isEditing) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ExternalLinkPreviewCard(
        uri: _linkPreview!.uri,
        title: _linkPreview!.title,
        description: _linkPreview!.description,
        thumbUrl: _linkPreview!.thumbnailUrl,
        compact: true,
        onRemove: () {
          setState(() {
            _hiddenPreviewUrl = _linkPreview!.uri;
            _linkPreview = null;
          });
        },
      ),
    );
  }

  ThemeData get theme => Theme.of(context);

  void _submitPost() {
    context.read<ComposeBloc>().add(PostSubmitted(suppressedLinkUri: _hiddenPreviewUrl));
  }

  void _saveDraft() {
    if (context.read<ComposeBloc>().state.isEditing) return;
    context.read<ComposeBloc>().add(const DraftSaved());
    if (mounted) {
      showAppSnackBar(context, 'Draft saved');
    }
  }

  Future<void> _showEditAlgorithmInfo() async {
    await showConfirmationDialog(
      context: context,
      title: const Text('How Post Editing Works'),
      content: const Text(
        'Lazurite saves edits by deleting and recreating the post record with the same URI. During re-indexing, '
        'ranking, counters, and search visibility can shift, and updates may take time to appear everywhere.',
      ),
      confirmLabel: 'OK',
      showCancel: false,
    );
  }

  void _handleBackNavigation(BuildContext context) {
    final state = context.read<ComposeBloc>().state;
    final navigator = Navigator.of(context);

    final hasContent = state.text.trim().isNotEmpty || state.mediaAttachments.isNotEmpty;

    if (state.isEditing) {
      if (state.isDraftDirty) {
        showConfirmationDialog(
          context: context,
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved edits. Discard them and leave?'),
          confirmLabel: 'Discard',
        ).then((shouldDiscard) {
          if (shouldDiscard && mounted) {
            navigator.pop(false);
          }
        });
      } else {
        navigator.pop(false);
      }
      return;
    }

    if (hasContent && state.isDraftDirty) {
      showConfirmationDialog(
        context: context,
        title: const Text('Save Draft?'),
        content: const Text('You have unsaved content. Would you like to save it as a draft?'),
        cancelLabel: 'Discard',
        confirmLabel: 'Save',
      ).then((shouldSave) {
        if (shouldSave) {
          _saveDraft();
        }
        if (mounted) {
          navigator.pop();
        }
      });
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComposeBloc, ComposeState>(
      listener: (context, state) {
        if (state.text != _textController.text) {
          _textController.text = state.text;
          _textController.selection = TextSelection.collapsed(offset: state.text.length);
        }

        if (state.isSuccess) {
          if (state.isEditing) {
            showAppSnackBar(context, 'Changes saved.', behavior: SnackBarBehavior.floating);
          }
          Navigator.of(context).pop(
            state.isEditing
                ? {'editedText': state.text}
                : {
                    'status': state.hasScheduledTime ? 'scheduled' : 'posted',
                    'isReply': state.isReply,
                    'replyParentUri': state.replyParentUri,
                    'replyRootUri': state.replyRootUri,
                  },
          );
        }

        if (state.hasError && state.errorMessage != null) {
          showAppSnackBar(context, state.errorMessage!, behavior: SnackBarBehavior.floating, isError: true);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          _handleBackNavigation(context);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: TextButton(onPressed: () => _handleBackNavigation(context), child: const Text('Cancel')),
            leadingWidth: 80,
            title: BlocBuilder<ComposeBloc, ComposeState>(
              builder: (context, state) => Text(state.isEditing ? 'Edit Post' : 'New Post'),
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<ComposeBloc, ComposeState>(
                builder: (context, state) => state.isEditing
                    ? const SizedBox.shrink()
                    : TextButton(onPressed: _saveDraft, child: const Text('Save Draft')),
              ),
              BlocBuilder<ComposeBloc, ComposeState>(
                builder: (context, state) {
                  final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
                  final button = TextButton(
                    onPressed: !isOffline && state.canSubmit && !state.isSubmitting ? _submitPost : null,
                    child: state.isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(state.isEditing ? 'Save Changes' : 'Post'),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: isOffline
                        ? Tooltip(message: offlineActionMessage('publish your post'), child: button)
                        : button,
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                BlocBuilder<ComposeBloc, ComposeState>(
                  builder: (context, state) {
                    if (state.isEditing) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Edits are saved by replacing the record while keeping this post URI. Ranking, '
                                'counts, and visibility may shift while networks re-index.',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                            IconButton(
                              onPressed: _showEditAlgorithmInfo,
                              icon: const Icon(Icons.help_outline),
                              tooltip: 'More info',
                            ),
                          ],
                        ),
                      );
                    }

                    if (!state.isReply || widget.replyAuthorHandle == null) {
                      return _buildQuotePreview(state);
                    }
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            border: Border(bottom: BorderSide(color: theme.dividerColor)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.reply, size: 16, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                'Replying to ',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              Text(
                                '@${widget.replyAuthorHandle}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildQuotePreview(state),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _textController,
                      focusNode: _textFocusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, fontSize: 17),
                    ),
                  ),
                ),
                _buildMentionAutocompletePanel(),
                BlocBuilder<ComposeBloc, ComposeState>(builder: (context, state) => _buildComposerLinkPreview(state)),
                if (_isLoadingLinkPreview)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                BlocBuilder<ComposeBloc, ComposeState>(
                  builder: (context, state) {
                    if (!state.hasScheduledTime) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 16, color: theme.colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Scheduled for ${DateFormat('MMM d, h:mm a').format(state.scheduledAt!)}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              context.read<ComposeBloc>().add(const ScheduleCleared());
                            },
                            child: Icon(Icons.close, size: 16, color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                BlocBuilder<ComposeBloc, ComposeState>(
                  builder: (context, state) {
                    if (state.isEditing) {
                      return const SizedBox.shrink();
                    }
                    if (state.mediaAttachments.isEmpty) return const SizedBox.shrink();

                    return Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.mediaAttachments.length,
                        itemBuilder: (context, index) {
                          final attachment = state.mediaAttachments[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(attachment.localPath),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  bottom: 8,
                                  child: GestureDetector(
                                    onTap: () => _showAltTextDialog(index, attachment.altText),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: attachment.altText.isNotEmpty
                                            ? theme.colorScheme.primary
                                            : Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'ALT',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: attachment.altText.isNotEmpty
                                              ? theme.colorScheme.onPrimary
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<ComposeBloc>().add(MediaRemoved(index));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                BlocBuilder<ComposeBloc, ComposeState>(
                  builder: (context, state) {
                    if (state.isEditing) {
                      return const SizedBox.shrink();
                    }
                    final video = state.videoAttachment;
                    if (video == null) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: video.hasError ? theme.colorScheme.error : theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: video.isActive
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: video.isActive && video.uploadProgress > 0
                                          ? video.uploadProgress / 100
                                          : null,
                                    ),
                                  )
                                : Icon(
                                    video.hasError ? Icons.error_outline : Icons.videocam_outlined,
                                    color: video.hasError
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onPrimaryContainer,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.localPath.split('/').last,
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _videoStatusLabel(video),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: video.hasError
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (video.isActive && video.uploadProgress > 0) ...[
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: video.uploadProgress / 100,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (video.isReady) ...[
                            IconButton(
                              icon: const Icon(Icons.subtitles_outlined),
                              tooltip: 'Add alt text',
                              onPressed: () => _showVideoAltTextDialog(video.altText),
                              color: video.altText.isNotEmpty
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => context.read<ComposeBloc>().add(const VideoRemoved()),
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: context.select<ComposeBloc, bool>((bloc) => bloc.state.isEditing)
                      ? const SizedBox.shrink()
                      : (_showDrafts ? _buildDraftsPanel() : const SizedBox.shrink()),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: SafeArea(
                    child: Row(
                      children: [
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return IconButton(
                              onPressed: state.canAddMoreMedia ? _pickImage : null,
                              icon: Icon(
                                Icons.image_outlined,
                                color: state.canAddMoreMedia
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              tooltip: 'Add image',
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return IconButton(
                              onPressed: state.canAddVideo ? _pickVideo : null,
                              icon: Icon(
                                Icons.videocam_outlined,
                                color: state.canAddVideo
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              tooltip: 'Add video',
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return IconButton(
                              onPressed: _toggleDrafts,
                              icon: Icon(Icons.drive_file_rename_outline, color: theme.colorScheme.primary),
                              tooltip: 'Drafts',
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return IconButton(
                              onPressed: _showSchedulePicker,
                              icon: Icon(Icons.schedule, color: theme.colorScheme.primary),
                              tooltip: 'Schedule',
                            );
                          },
                        ),
                        const Spacer(),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            return _CharCounter(count: state.graphemeCount, maxCount: kMaxGraphemes);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A [TextEditingController] that highlights AT Protocol facets (mentions,
/// links, hashtags) inline as the user types.
///
/// Byte-offset → code-unit conversion is done via UTF-8 re-encode so that
/// multi-byte characters (emoji, CJK, etc.) are handled correctly.
class _FacetHighlightController extends TextEditingController {
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final text = value.text;
    if (text.isEmpty) return TextSpan(style: style);

    final entities = BlueskyText(text).entities.where((e) => e.type != EntityType.markdownLink).toList();
    if (entities.isEmpty) return TextSpan(style: style, text: text);

    final colorScheme = context.colorScheme;
    final textBytes = utf8.encode(text);
    final spans = <InlineSpan>[];
    int lastCharEnd = 0;

    for (final entity in entities) {
      final charStart = _byteToCharOffset(textBytes, entity.indices.start);
      final charEnd = _byteToCharOffset(textBytes, entity.indices.end);

      if (charStart < lastCharEnd || charStart >= charEnd) continue;

      if (charStart > lastCharEnd) {
        spans.add(TextSpan(style: style, text: text.substring(lastCharEnd, charStart)));
      }

      final Color entityColor;
      if (entity.isHandle) {
        entityColor = colorScheme.primary;
      } else if (entity.isLink) {
        entityColor = colorScheme.tertiary;
      } else {
        entityColor = colorScheme.secondary;
      }

      spans.add(
        TextSpan(
          style: style?.copyWith(color: entityColor),
          text: text.substring(charStart, charEnd),
        ),
      );
      lastCharEnd = charEnd;
    }

    if (lastCharEnd < text.length) {
      spans.add(TextSpan(style: style, text: text.substring(lastCharEnd)));
    }

    return TextSpan(children: spans);
  }

  /// Converts a UTF-8 byte offset into a Dart [String] code-unit offset.
  static int _byteToCharOffset(List<int> textBytes, int byteOffset) {
    if (byteOffset <= 0) return 0;
    if (byteOffset >= textBytes.length) return utf8.decode(textBytes, allowMalformed: true).length;
    return utf8.decode(textBytes.sublist(0, byteOffset), allowMalformed: true).length;
  }
}

class _CharCounter extends StatelessWidget {
  const _CharCounter({required this.count, required this.maxCount});

  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final remaining = maxCount - count;
    final progress = count / maxCount;
    final theme = Theme.of(context);
    Color color;
    if (progress < 0.8) {
      color = theme.colorScheme.primary;
    } else if (progress < 0.95) {
      color = theme.colorScheme.error.withValues(alpha: 0.7);
    } else {
      color = theme.colorScheme.error;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$remaining',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _ProgressRingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({required this.progress, required this.color, required this.backgroundColor});

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14159 / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
