import 'dart:async';

import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'composer_providers.dart';

part 'composer_notifier.g.dart';

/// State for the composer screen.
class ComposerState {
  const ComposerState({required this.draft, this.isPublishing = false, this.error});

  final Draft? draft;
  final bool isPublishing;
  final String? error;

  ComposerState copyWith({Draft? draft, bool? isPublishing, String? error}) {
    return ComposerState(
      draft: draft ?? this.draft,
      isPublishing: isPublishing ?? this.isPublishing,
      error: error,
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
  Future<ComposerState> build(String? draftId) async {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    if (draftId case final id?) {
      final existing = await _repository.getDraft(id);
      return ComposerState(draft: existing);
    }

    final newDraft = await _repository.createDraft();
    return ComposerState(draft: newDraft);
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

  /// Cancel composing (saves draft if needed).
  Future<void> cancel() async {
    _debounceTimer?.cancel();
  }
}
