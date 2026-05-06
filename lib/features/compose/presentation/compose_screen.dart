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
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/data/link_preview_service.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/external_link_preview_card.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:video_player/video_player.dart';

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
  String? _composerAvatarDid;
  Future<String?>? _composerAvatarFuture;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncComposerAvatarFuture();
  }

  void _syncComposerAvatarFuture() {
    AuthState? authState;
    try {
      authState = context.read<AuthBloc>().state;
    } catch (_) {
      debugPrint('ComposeScreen: auth provider unavailable for composer avatar.');
    }

    final did = authState?.tokens?.did.trim();
    if (did == null || did.isEmpty) {
      _composerAvatarDid = null;
      _composerAvatarFuture = null;
      return;
    }

    if (_composerAvatarDid == did && _composerAvatarFuture != null) {
      return;
    }

    _composerAvatarDid = did;
    _composerAvatarFuture = _loadComposerAvatarUrl(did);
  }

  Future<String?> _loadComposerAvatarUrl(String did) async {
    ProfileRepository repository;
    try {
      repository = context.read<ProfileRepository>();
    } catch (_) {
      debugPrint('ComposeScreen: profile repository unavailable for composer avatar.');
      return null;
    }

    try {
      final profile = await repository.getProfile(did);
      return profile.avatar;
    } catch (error, stackTrace) {
      debugPrint('ComposeScreen: failed to load composer avatar for $did: $error\n$stackTrace');
      return null;
    }
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

  Future<void> _showVideoAltTextDialog(VideoAttachment video) async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _VideoAltTextDialog(
        video: video,
        onCancel: () => Navigator.pop(dialogContext),
        onSave: (altText) => Navigator.pop(dialogContext, altText),
      ),
    );

    if (result != null && mounted) {
      context.read<ComposeBloc>().add(VideoAltTextUpdated(result));
    }
  }

  Future<void> _showAltTextDialog(int index, MediaAttachment attachment) async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _ImageAltTextDialog(
        imagePath: attachment.localPath,
        initialAltText: attachment.altText,
        onCancel: () => Navigator.pop(dialogContext),
        onSave: (altText) => Navigator.pop(dialogContext, altText),
      ),
    );

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
        final colorScheme = theme.colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                  bottom: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 292),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Drafts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${state.drafts.length} draft${state.drafts.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoadingDrafts)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 26),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.drafts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      child: Center(
                        child: Text(
                          'No drafts saved',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.drafts.length,
                        separatorBuilder: (_, _) => Divider(height: 1, color: colorScheme.outlineVariant),
                        itemBuilder: (context, index) {
                          final draft = state.drafts[index];
                          return _DraftListItem(
                            draft: draft,
                            formattedTime: _formatDraftTime(draft.updatedAt),
                            onTap: () {
                              setState(() => _showDrafts = false);
                              context.read<ComposeBloc>().add(DraftLoaded(draft.id));
                            },
                            onDelete: () {
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
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(68, 0, 16, 8),
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

  String _composerAvatarFallbackText() {
    try {
      final tokens = context.read<AuthBloc>().state.tokens;
      final displayName = tokens?.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }

      final handle = tokens?.handle.trim();
      if (handle != null && handle.isNotEmpty) {
        return handle;
      }
    } catch (_) {
      debugPrint('ComposeScreen: auth provider unavailable for avatar fallback.');
    }

    return 'Lazurite';
  }

  Widget _buildComposerAvatar() {
    final avatar = ProfileAvatar(
      key: const ValueKey('compose_author_avatar'),
      size: 40,
      imageUrl: null,
      fallbackText: _composerAvatarFallbackText(),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      placeholderTextStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );

    final avatarFuture = _composerAvatarFuture;
    if (avatarFuture == null) {
      return avatar;
    }

    return FutureBuilder<String?>(
      future: avatarFuture,
      builder: (context, snapshot) {
        return ProfileAvatar(
          key: const ValueKey('compose_author_avatar'),
          size: 40,
          imageUrl: snapshot.data,
          fallbackText: _composerAvatarFallbackText(),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          placeholderTextStyle: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }

  Widget _buildComposerTextArea() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildComposerAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledPill(ComposeState state) {
    if (!state.hasScheduledTime) {
      return const SizedBox.shrink();
    }

    final colorScheme = theme.colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(68, 4, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colorScheme.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 15, color: colorScheme.onPrimary),
            const SizedBox(width: 7),
            Text(
              'Scheduled for ${DateFormat('MMM d, h:mm a').format(state.scheduledAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.read<ComposeBloc>().add(const ScheduleCleared()),
              child: Icon(Icons.close, size: 16, color: colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    final colorScheme = theme.colorScheme;
    final foregroundColor = onPressed == null
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
        : colorScheme.primary;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: foregroundColor),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: const Size(40, 40),
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        backgroundColor: isActive ? colorScheme.surfaceContainerLow : Colors.transparent,
        shape: const CircleBorder(),
      ),
    );
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
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
            leading: TextButton(onPressed: () => _handleBackNavigation(context), child: const Text('Cancel')),
            leadingWidth: 80,
            title: BlocBuilder<ComposeBloc, ComposeState>(
              builder: (context, state) => Text(
                state.isEditing ? 'Edit Post' : 'New Post',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<ComposeBloc, ComposeState>(
                builder: (context, state) {
                  final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
                  final button = FilledButton(
                    onPressed: !isOffline && state.canSubmit && !state.isSubmitting ? _submitPost : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
                _buildComposerTextArea(),
                _buildMentionAutocompletePanel(),
                BlocBuilder<ComposeBloc, ComposeState>(builder: (context, state) => _buildComposerLinkPreview(state)),
                if (_isLoadingLinkPreview)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                BlocBuilder<ComposeBloc, ComposeState>(builder: (context, state) => _buildScheduledPill(state)),

                BlocBuilder<ComposeBloc, ComposeState>(
                  builder: (context, state) {
                    if (state.isEditing) {
                      return const SizedBox.shrink();
                    }
                    if (state.mediaAttachments.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(68, 0, 16, 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.mediaAttachments.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 4 / 3,
                        ),
                        itemBuilder: (context, index) {
                          final attachment = state.mediaAttachments[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(attachment.localPath), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                left: 6,
                                bottom: 6,
                                child: Material(
                                  color: attachment.altText.isNotEmpty ? theme.colorScheme.primary : Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () => _showAltTextDialog(index, attachment),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 40, minHeight: 30),
                                      child: Center(
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
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                    onPressed: () => context.read<ComposeBloc>().add(MediaRemoved(index)),
                                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                    tooltip: 'Remove image',
                                  ),
                                ),
                              ),
                            ],
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
                      margin: const EdgeInsets.fromLTRB(68, 0, 16, 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                              onPressed: () => _showVideoAltTextDialog(video),
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
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return _buildToolbarIconButton(
                              icon: Icons.image_outlined,
                              tooltip: 'Add image',
                              onPressed: state.canAddMoreMedia ? _pickImage : null,
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return _buildToolbarIconButton(
                              icon: Icons.videocam_outlined,
                              tooltip: 'Add video',
                              onPressed: state.canAddVideo ? _pickVideo : null,
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            final hasDraftableContent =
                                state.text.trim().isNotEmpty ||
                                state.hasMedia ||
                                state.hasVideo ||
                                state.hasScheduledTime;
                            return _buildToolbarIconButton(
                              icon: Icons.save_outlined,
                              tooltip: 'Save draft',
                              onPressed: hasDraftableContent ? _saveDraft : null,
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return _buildToolbarIconButton(
                              icon: Icons.drive_file_rename_outline,
                              tooltip: 'Drafts',
                              onPressed: _toggleDrafts,
                              isActive: _showDrafts,
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            if (state.isEditing) return const SizedBox.shrink();
                            return _buildToolbarIconButton(
                              icon: Icons.schedule,
                              tooltip: 'Schedule',
                              onPressed: _showSchedulePicker,
                              isActive: state.hasScheduledTime,
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

class _DraftListItem extends StatelessWidget {
  const _DraftListItem({required this.draft, required this.formattedTime, required this.onTap, required this.onDelete});

  final DraftEntry draft;
  final String formattedTime;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 11, 8, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.content.isEmpty ? '(No text)' : draft.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        formattedTime,
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      if (draft.scheduledAt != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            'Scheduled',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Delete draft',
              visualDensity: VisualDensity.compact,
            ),
          ],
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

class _ImageAltTextDialog extends StatefulWidget {
  const _ImageAltTextDialog({
    required this.imagePath,
    required this.initialAltText,
    required this.onCancel,
    required this.onSave,
  });

  final String imagePath;
  final String initialAltText;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<_ImageAltTextDialog> createState() => _ImageAltTextDialogState();
}

class _ImageAltTextDialogState extends State<_ImageAltTextDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialAltText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final imageHeight = (size.height * 0.32).clamp(140.0, 280.0).toDouble();

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: size.height * 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Alt text', style: theme.textTheme.titleLarge)),
                  IconButton(tooltip: 'Close', onPressed: widget.onCancel, icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: imageHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Image.file(
                  key: const ValueKey('alt-text-image-preview'),
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.broken_image_outlined, size: 40, color: colorScheme.onSurfaceVariant)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('alt-text-field'),
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(hintText: 'Describe the image', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => widget.onSave(_controller.text), child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoAltTextDialog extends StatefulWidget {
  const _VideoAltTextDialog({required this.video, required this.onCancel, required this.onSave});

  final VideoAttachment video;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<_VideoAltTextDialog> createState() => _VideoAltTextDialogState();
}

class _VideoAltTextDialogState extends State<_VideoAltTextDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.video.altText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final previewHeight = (size.height * 0.32).clamp(140.0, 280.0).toDouble();

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: size.height * 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Video alt text', style: theme.textTheme.titleLarge)),
                  IconButton(tooltip: 'Close', onPressed: widget.onCancel, icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              _LocalVideoPreview(videoPath: widget.video.localPath, height: previewHeight),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('video-alt-text-field'),
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(hintText: 'Describe the video', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => widget.onSave(_controller.text), child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalVideoPreview extends StatefulWidget {
  const _LocalVideoPreview({required this.videoPath, required this.height});

  final String videoPath;
  final double height;

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  VideoPlayerController? _controller;
  Object? _error;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = _controller;
    final filename = widget.videoPath.split('/').last;

    return Container(
      key: const ValueKey('video-alt-preview'),
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: GestureDetector(
        onTap: controller != null && controller.value.isInitialized ? _togglePlayback : null,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (controller != null && controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            else
              _VideoPreviewFallback(filename: filename, isLoading: _isInitializing, error: _error),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.62), shape: BoxShape.circle),
                child: Icon(
                  controller?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initialize() async {
    final file = File(widget.videoPath);
    if (!file.existsSync()) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      await controller.setLooping(true);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _isInitializing = false;
      });
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }
}

class _VideoPreviewFallback extends StatelessWidget {
  const _VideoPreviewFallback({required this.filename, required this.isLoading, required this.error});

  final String filename;
  final bool isLoading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4))
            else
              Icon(Icons.videocam_outlined, size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              filename.isEmpty ? 'Video' : filename,
              key: const ValueKey('video-alt-preview-filename'),
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                'Preview unavailable',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
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
