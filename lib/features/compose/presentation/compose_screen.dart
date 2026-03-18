import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bluesky_text/bluesky_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';

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
    this.draftId,
    this.initialText,
  });

  final String? replyParentUri;
  final String? replyParentCid;
  final String? replyRootUri;
  final String? replyRootCid;
  final String? replyAuthorHandle;
  final String? quoteUri;
  final String? quoteCid;
  final String? quoteAuthorHandle;
  final int? draftId;
  final String? initialText;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  late final _FacetHighlightController _textController;
  final ImagePicker _imagePicker = ImagePicker();
  bool _showDrafts = false;

  @override
  void initState() {
    super.initState();
    _textController = _FacetHighlightController();
    if (widget.initialText?.isNotEmpty ?? false) {
      _textController.text = widget.initialText!;
    }

    if (widget.draftId != null) {
      context.read<ComposeBloc>().add(DraftLoaded(widget.draftId!));
    }

    if (widget.replyParentUri != null && widget.replyParentCid != null) {
      context.read<ComposeBloc>().add(
        ReplyContextSet(
          parentUri: widget.replyParentUri!,
          parentCid: widget.replyParentCid!,
          rootUri: widget.replyRootUri ?? widget.replyParentUri!,
          rootCid: widget.replyRootCid ?? widget.replyParentCid!,
        ),
      );
    }

    if (widget.quoteUri != null && widget.quoteCid != null) {
      context.read<ComposeBloc>().add(QuoteContextSet(quoteUri: widget.quoteUri!, quoteCid: widget.quoteCid!));
    }

    _textController.addListener(_onTextChanged);
    if (widget.initialText?.isNotEmpty ?? false) {
      context.read<ComposeBloc>().add(TextChanged(widget.initialText!));
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    context.read<ComposeBloc>().add(TextChanged(_textController.text));
  }

  Future<void> _pickImage() async {
    final state = context.read<ComposeBloc>().state;
    final theme = Theme.of(context);
    if (!state.canAddMoreMedia) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum 4 images allowed', style: TextStyle(color: theme.colorScheme.error)),
          ),
        );
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image must be smaller than 1MB')));
          }
          return;
        }

        final extension = image.path.toLowerCase().split('.').last;
        const validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
        if (!validExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Image must be JPEG, PNG, or WebP')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _pickVideo() async {
    final state = context.read<ComposeBloc>().state;
    if (!state.canAddVideo) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Remove existing media before adding a video')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick video: $e')));
      }
    }
  }

  Future<void> _showVideoAltTextDialog(String currentAltText) async {
    final TextEditingController altController = TextEditingController(text: currentAltText);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, altController.text), child: const Text('Save')),
        ],
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
      builder: (context) => AlertDialog(
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, altController.text), child: const Text('Save')),
        ],
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
            border: Border(top: BorderSide(color: _theme.dividerColor)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Drafts', style: _theme.textTheme.titleMedium),
                    if (state.drafts.isNotEmpty)
                      Text(
                        '${state.drafts.length} draft${state.drafts.length != 1 ? 's' : ''}',
                        style: _theme.textTheme.bodySmall?.copyWith(color: _theme.colorScheme.onSurfaceVariant),
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
                      style: _theme.textTheme.bodyMedium?.copyWith(color: _theme.colorScheme.onSurfaceVariant),
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
                            Text(_formatDraftTime(draft.updatedAt), style: _theme.textTheme.bodySmall),
                            if (draft.scheduledAt != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Scheduled',
                                  style: _theme.textTheme.bodySmall?.copyWith(
                                    color: _theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: _theme.colorScheme.error),
                          onPressed: () {
                            final bloc = context.read<ComposeBloc>();
                            final theme = _theme;
                            showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete Draft?'),
                                content: const Text('This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                                  ),
                                ],
                              ),
                            ).then((confirmed) {
                              if (confirmed == true && mounted) {
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

  ThemeData get _theme => Theme.of(context);

  void _submitPost() {
    context.read<ComposeBloc>().add(const PostSubmitted());
  }

  void _saveDraft() {
    context.read<ComposeBloc>().add(const DraftSaved());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Draft saved', style: TextStyle(color: _theme.colorScheme.onPrimary)),
          backgroundColor: _theme.colorScheme.primary,
        ),
      );
    }
  }

  void _handleBackNavigation(BuildContext context) {
    final state = context.read<ComposeBloc>().state;
    final navigator = Navigator.of(context);

    final hasContent = state.text.trim().isNotEmpty || state.mediaAttachments.isNotEmpty;

    if (hasContent && state.isDraftDirty) {
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Save Draft?'),
          content: const Text('You have unsaved content. Would you like to save it as a draft?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ).then((shouldSave) {
        if (shouldSave == true) {
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
        final theme = Theme.of(context);

        if (state.text != _textController.text) {
          _textController.text = state.text;
          _textController.selection = TextSelection.collapsed(offset: state.text.length);
        }

        if (state.isSuccess) {
          Navigator.of(context).pop();
        }

        if (state.hasError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
            ),
          );
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
            title: const Text('New Post'),
            centerTitle: true,
            actions: [
              TextButton(onPressed: _saveDraft, child: const Text('Save Draft')),
              BlocBuilder<ComposeBloc, ComposeState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: state.canSubmit && !state.isSubmitting ? _submitPost : null,
                      child: state.isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Post'),
                    ),
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
                    if (!state.isReply || widget.replyAuthorHandle == null) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _theme.colorScheme.surfaceContainerHighest,
                        border: Border(bottom: BorderSide(color: _theme.dividerColor)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 16, color: _theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'Replying to ',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: _theme.colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            '@${widget.replyAuthorHandle}',
                            style: _theme.textTheme.bodySmall?.copyWith(
                              color: _theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: _theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                ),
                BlocBuilder<ComposeBloc, ComposeState>(
                  builder: (context, state) {
                    if (!state.hasScheduledTime) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 16, color: _theme.colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Scheduled for ${DateFormat('MMM d, h:mm a').format(state.scheduledAt!)}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: _theme.colorScheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              context.read<ComposeBloc>().add(const ScheduleCleared());
                            },
                            child: Icon(Icons.close, size: 16, color: _theme.colorScheme.onPrimaryContainer),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                BlocBuilder<ComposeBloc, ComposeState>(
                  builder: (context, state) {
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
                                            ? _theme.colorScheme.primary
                                            : Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'ALT',
                                        style: _theme.textTheme.labelSmall?.copyWith(
                                          color: attachment.altText.isNotEmpty
                                              ? _theme.colorScheme.onPrimary
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
                    final video = state.videoAttachment;
                    if (video == null) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: video.hasError ? _theme.colorScheme.error : _theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _theme.colorScheme.primaryContainer,
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
                                        ? _theme.colorScheme.error
                                        : _theme.colorScheme.onPrimaryContainer,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.localPath.split('/').last,
                                  style: _theme.textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _videoStatusLabel(video),
                                  style: _theme.textTheme.bodySmall?.copyWith(
                                    color: video.hasError
                                        ? _theme.colorScheme.error
                                        : _theme.colorScheme.onSurfaceVariant,
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
                                  ? _theme.colorScheme.primary
                                  : _theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => context.read<ComposeBloc>().add(const VideoRemoved()),
                            color: _theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: _showDrafts ? _buildDraftsPanel() : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: _theme.dividerColor)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: SafeArea(
                    child: Row(
                      children: [
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            return IconButton(
                              onPressed: state.canAddMoreMedia ? _pickImage : null,
                              icon: Icon(
                                Icons.image_outlined,
                                color: state.canAddMoreMedia
                                    ? _theme.colorScheme.primary
                                    : _theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              tooltip: 'Add image',
                            );
                          },
                        ),
                        BlocBuilder<ComposeBloc, ComposeState>(
                          builder: (context, state) {
                            return IconButton(
                              onPressed: state.canAddVideo ? _pickVideo : null,
                              icon: Icon(
                                Icons.videocam_outlined,
                                color: state.canAddVideo
                                    ? _theme.colorScheme.primary
                                    : _theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              tooltip: 'Add video',
                            );
                          },
                        ),
                        IconButton(
                          onPressed: _toggleDrafts,
                          icon: Icon(Icons.drive_file_rename_outline, color: _theme.colorScheme.primary),
                          tooltip: 'Drafts',
                        ),
                        IconButton(
                          onPressed: _showSchedulePicker,
                          icon: Icon(Icons.schedule, color: _theme.colorScheme.primary),
                          tooltip: 'Schedule',
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

    final colorScheme = Theme.of(context).colorScheme;
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
