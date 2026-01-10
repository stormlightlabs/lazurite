import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/domain/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'composer_providers.dart';

part 'composer_notifier.g.dart';

/// Arguments for initializing the composer.
class ComposerArgs extends Equatable {
  const ComposerArgs({this.draftId, this.replyTo, this.quoteTo});

  final String? draftId;
  final String? replyTo;
  final String? quoteTo;

  @override
  List<Object?> get props => [draftId, replyTo, quoteTo];
}

/// State for the composer screen.
class ComposerState {
  const ComposerState({
    required this.draft,
    this.isPublishing = false,
    this.error,
    this.replyPost,
    this.quotePost,
  });

  final Draft? draft;
  final bool isPublishing;
  final String? error;

  /// The parent post being replied to (for displaying ReplyContextCard).
  final FeedItem? replyPost;

  /// The quoted post (for displaying QuotePostCard).
  final FeedItem? quotePost;

  ComposerState copyWith({
    Draft? draft,
    bool? isPublishing,
    String? error,
    FeedItem? replyPost,
    FeedItem? quotePost,
  }) {
    return ComposerState(
      draft: draft ?? this.draft,
      isPublishing: isPublishing ?? this.isPublishing,
      error: error,
      replyPost: replyPost ?? this.replyPost,
      quotePost: quotePost ?? this.quotePost,
    );
  }
}

/// Notifier for managing composer screen state.
///
/// Handles draft creation, autosave, media management, and publishing.
@riverpod
class ComposerNotifier extends _$ComposerNotifier {
  Timer? _debounceTimer;

  DraftRepository get _repository => ref.read(draftRepositoryProvider);

  @override
  Future<ComposerState> build(ComposerArgs? args) async {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    if (args?.draftId case final id?) {
      final existing = await _repository.getDraft(id);
      FeedItem? replyPost;
      FeedItem? quotePost;
      if (existing.replyParentUri != null) {
        replyPost = await _fetchPost(existing.replyParentUri!);
      }
      if (existing.quoteUri != null) {
        quotePost = await _fetchPost(existing.quoteUri!);
      }
      return ComposerState(draft: existing, replyPost: replyPost, quotePost: quotePost);
    }

    FeedItem? replyPost;
    String? replyParentUri;
    String? replyParentCid;
    String? replyRootUri;
    String? replyRootCid;

    if (args?.replyTo case final replyToUri?) {
      replyPost = await _fetchPost(replyToUri);
      if (replyPost != null) {
        replyParentUri = replyPost.uri;
        replyParentCid = replyPost.cid;

        final parentReply = replyPost.record?['reply'] as Map<String, dynamic>?;
        if (parentReply != null) {
          final root = parentReply['root'] as Map<String, dynamic>?;
          replyRootUri = root?['uri'] as String?;
          replyRootCid = root?['cid'] as String?;
        }

        replyRootUri ??= replyParentUri;
        replyRootCid ??= replyParentCid;
      }
    }

    FeedItem? quotePost;
    String? quoteUri;
    String? quoteCid;

    if (args?.quoteTo case final quoteToUri?) {
      quotePost = await _fetchPost(quoteToUri);
      if (quotePost != null) {
        quoteUri = quotePost.uri;
        quoteCid = quotePost.cid;
      }
    }

    final newDraft = await _repository.createDraft(
      replyParentUri: replyParentUri,
      replyParentCid: replyParentCid,
      replyRootUri: replyRootUri,
      replyRootCid: replyRootCid,
      quoteUri: quoteUri,
      quoteCid: quoteCid,
    );
    return ComposerState(draft: newDraft, replyPost: replyPost, quotePost: quotePost);
  }

  /// Fetches a post by URI for reply/quote context.
  Future<FeedItem?> _fetchPost(String uri) async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      return await repository.getPost(uri);
    } catch (_) {
      return null;
    }
  }

  /// Update draft text with debounced autosave.
  void updateText(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.asData?.value;
      final currentDraft = currentState?.draft;
      if (currentDraft == null) return;

      await _repository.updateDraftContent(currentDraft.id, text: text);
      final updated = await _repository.getDraft(currentDraft.id);
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(draft: updated));
      }
    });
  }

  /// Add media to draft (immediate save).
  Future<void> addMedia(String path, String mimeType) async {
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null) return;

    await _repository.addMedia(
      currentDraft.id,
      DraftMediaInput(localPath: path, mimeType: mimeType),
    );
    final updated = await _repository.getDraft(currentDraft.id);
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(draft: updated));
    }
  }

  /// Remove media from draft (immediate save).
  Future<void> removeMedia(int mediaId) async {
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null) return;

    await _repository.removeMedia(currentDraft.id, mediaId);
    final updated = await _repository.getDraft(currentDraft.id);
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(draft: updated));
    }
  }

  /// Update alt text for a media attachment.
  Future<void> updateMediaAltText(int mediaId, String altText) async {
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null) return;

    await _repository.updateMediaAltText(currentDraft.id, mediaId, altText);
    final updated = await _repository.getDraft(currentDraft.id);
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(draft: updated));
    }
  }

  /// Publish the draft.
  ///
  /// Returns true on success, false on failure.
  Future<({String uri, String cid})?> publish() async {
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null || currentState == null) return null;

    state = AsyncValue.data(currentState.copyWith(isPublishing: true, error: null));

    try {
      final result = await _repository.publishDraft(currentDraft.id);
      return result;
    } catch (e) {
      final updatedState = state.asData?.value;
      if (updatedState != null) {
        state = AsyncValue.data(updatedState.copyWith(isPublishing: false, error: e.toString()));
      }
      return null;
    }
  }

  /// Force save the current text immediately (cancels debounce).
  Future<void> forceSave(String text) async {
    _debounceTimer?.cancel();
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null) return;

    await _repository.updateDraftContent(currentDraft.id, text: text);
    final updated = await _repository.getDraft(currentDraft.id);
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(draft: updated));
    }
  }

  /// Delete the current draft.
  Future<void> deleteDraft() async {
    _debounceTimer?.cancel();
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null) return;

    await _repository.deleteDraft(currentDraft.id);
  }

  /// Cancel composing (saves draft if needed).
  Future<void> cancel() async {
    _debounceTimer?.cancel();
  }

  /// Retry a failed media upload.
  Future<void> retryUpload(int mediaId) async {
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null) return;

    try {
      await _repository.retryMediaUpload(currentDraft.id, mediaId);
      final updated = await _repository.getDraft(currentDraft.id);
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(draft: updated));
      }
    } catch (e) {
      final updated = await _repository.getDraft(currentDraft.id);
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(draft: updated));
      }
    }
  }

  /// Cancel an in-progress upload.
  Future<void> cancelUpload(int mediaId) async {
    final currentState = state.asData?.value;
    final currentDraft = currentState?.draft;
    if (currentDraft == null) return;

    _repository.cancelUpload(mediaId);
    final updated = await _repository.getDraft(currentDraft.id);
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(draft: updated));
    }
  }
}
