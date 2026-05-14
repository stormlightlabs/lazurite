import 'dart:async';

import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/bookmark/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/search/data/semantic_indexer.dart';

class SavedPostsState extends Equatable {
  const SavedPostsState({
    this.status = SavedPostsStatus.initial,
    this.savedPosts = const [],
    this.savedUris = const {},
    this.saveTypeByUri = const {},
    this.error,
  });

  final SavedPostsStatus status;
  final List<SavedPostEntry> savedPosts;
  final Set<String> savedUris;

  /// Maps post URI to its save type: 'local' or 'cloud'.
  final Map<String, String> saveTypeByUri;
  final String? error;

  bool isSaved(String postUri) => savedUris.contains(postUri);

  /// Returns the save type for [postUri], or null if not saved.
  String? saveTypeForUri(String postUri) => saveTypeByUri[postUri];

  SavedPostsState copyWith({
    SavedPostsStatus? status,
    List<SavedPostEntry>? savedPosts,
    Set<String>? savedUris,
    Map<String, String>? saveTypeByUri,
    String? error,
  }) {
    return SavedPostsState(
      status: status ?? this.status,
      savedPosts: savedPosts ?? this.savedPosts,
      savedUris: savedUris ?? this.savedUris,
      saveTypeByUri: saveTypeByUri ?? this.saveTypeByUri,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, savedPosts, savedUris, saveTypeByUri, error];
}

enum SavedPostsStatus { initial, loading, loaded, error }

class SavedPostsCubit extends Cubit<SavedPostsState> {
  SavedPostsCubit({
    required AppDatabase database,
    required String accountDid,
    required PostActionRepository postActionRepository,
    SemanticIndexer? semanticIndexer,
  }) : _database = database,
       _accountDid = accountDid,
       _postActionRepository = postActionRepository,
       _semanticIndexer = semanticIndexer,
       super(const SavedPostsState()) {
    _init();
  }

  final AppDatabase _database;
  final String _accountDid;
  final PostActionRepository _postActionRepository;
  final SemanticIndexer? _semanticIndexer;
  StreamSubscription<Map<String, String>>? _savedUrisSubscription;

  void _init() {
    _savedUrisSubscription = _database
        .watchSavedPostsWithType(_accountDid)
        .listen(
          (typeByUri) {
            emit(state.copyWith(savedUris: typeByUri.keys.toSet(), saveTypeByUri: typeByUri));
          },
          onError: (error) {
            log.e('Error watching saved post URIs', error: error);
          },
        );
    unawaited(syncCloudBookmarks());
  }

  Future<void> loadSavedPosts() async {
    emit(state.copyWith(status: SavedPostsStatus.loading, error: null));

    try {
      final posts = await _database.getSavedPosts(_accountDid);
      final uris = posts.map((p) => p.postUri).toSet();
      final typeByUri = {for (final p in posts) p.postUri: p.saveType};

      emit(
        state.copyWith(status: SavedPostsStatus.loaded, savedPosts: posts, savedUris: uris, saveTypeByUri: typeByUri),
      );
    } catch (error) {
      log.e('Failed to load saved posts', error: error);
      emit(state.copyWith(status: SavedPostsStatus.error, error: 'Failed to load saved posts'));
    }
  }

  Future<bool> toggleSave(PostView post) async {
    final postUri = post.uri.toString();
    final postJson = PoptartCacheCodecs.postView.encode(post);
    final isCurrentlySaved = state.isSaved(postUri);

    try {
      if (isCurrentlySaved) {
        await _database.unsavePost(_accountDid, postUri);
        _semanticIndexer?.removePost(postUri);
      } else {
        await _database.savePost(
          SavedPostsCompanion(
            accountDid: Value(_accountDid),
            postUri: Value(postUri),
            postJson: Value(postJson),
            saveType: const Value('local'),
            savedAt: Value(DateTime.now()),
          ),
        );
        _semanticIndexer?.queueIndexPost(postUri, postJson, _accountDid, 'saved');
      }

      await loadSavedPosts();
      return true;
    } catch (error) {
      log.e('Failed to toggle save', error: error);
      emit(state.copyWith(error: 'Failed to ${isCurrentlySaved ? 'unsave' : 'save'} post'));
      return false;
    }
  }

  Future<bool> savePost(PostView post) async {
    final postUri = post.uri.toString();
    if (state.isSaved(postUri)) return true;
    return toggleSave(post);
  }

  Future<bool> unsavePost(String postUri) async {
    if (!state.isSaved(postUri)) return true;
    try {
      await _database.unsavePost(_accountDid, postUri);
      _semanticIndexer?.removePost(postUri);
      await loadSavedPosts();
      return true;
    } catch (error) {
      log.e('Failed to unsave post', error: error);
      emit(state.copyWith(error: 'Failed to unsave post'));
      return false;
    }
  }

  Future<void> unsavePostById(int id) async {
    try {
      final entry = state.savedPosts.where((p) => p.id == id).firstOrNull;
      await _database.unsavePostById(id);
      if (entry != null) _semanticIndexer?.removePost(entry.postUri);
      await loadSavedPosts();
    } catch (error) {
      log.e('Failed to unsave post', error: error);
      emit(state.copyWith(error: 'Failed to remove saved post'));
    }
  }

  Future<void> clearAllSaved() async {
    try {
      await _database.deleteAllSavedPosts(_accountDid);
      await loadSavedPosts();
    } catch (error) {
      log.e('Failed to clear saved posts', error: error);
      emit(state.copyWith(error: 'Failed to clear saved posts'));
    }
  }

  /// Clears local bookmark state only.
  ///
  /// - local -> deleted
  /// - both -> downgraded to cloud
  /// - cloud -> unchanged
  Future<void> clearLocalSaved() async {
    try {
      final posts = await _database.getSavedPosts(_accountDid);
      for (final post in posts) {
        if (post.saveType == 'local') {
          await _database.unsavePostById(post.id);
          _semanticIndexer?.removePost(post.postUri);
          continue;
        }
        if (post.saveType == 'both') {
          await _database.updateSaveType(_accountDid, post.postUri, 'cloud');
        }
      }
      await loadSavedPosts();
    } catch (error) {
      log.e('Failed to clear local saved posts', error: error);
      emit(state.copyWith(error: 'Failed to clear local bookmarks'));
    }
  }

  Stream<bool> watchIsSaved(String postUri) {
    return _database.watchIsPostSaved(_accountDid, postUri);
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<bool> cloudSave(PostView post) async {
    final postUri = post.uri.toString();
    final postJson = PoptartCacheCodecs.postView.encode(post);
    final currentType = state.saveTypeForUri(postUri);
    if (currentType == 'cloud' || currentType == 'both') return true;

    final isLocalSaved = currentType == 'local';
    try {
      if (isLocalSaved) {
        await _database.updateSaveType(_accountDid, postUri, 'both');
      } else {
        await _database.savePost(
          SavedPostsCompanion(
            accountDid: Value(_accountDid),
            postUri: Value(postUri),
            postJson: Value(postJson),
            saveType: const Value('cloud'),
            savedAt: Value(DateTime.now()),
          ),
        );
        _semanticIndexer?.queueIndexPost(postUri, postJson, _accountDid, 'saved');
      }
      await _postActionRepository.createBookmark(uri: post.uri, cid: post.cid);
      return true;
    } catch (error) {
      log.e('Failed to cloud save post', error: error);
      if (isLocalSaved) {
        await _database.updateSaveType(_accountDid, postUri, 'local');
      } else {
        await _database.unsavePost(_accountDid, postUri);
      }
      emit(state.copyWith(error: 'Failed to save post to Bluesky'));
      return false;
    }
  }

  Future<bool> cloudUnsave(String postUri) async {
    final currentType = state.saveTypeForUri(postUri);
    if (currentType == null || currentType == 'local') return true;

    final existingEntry = await _database.getSavedPost(_accountDid, postUri);
    try {
      if (currentType == 'both') {
        await _database.updateSaveType(_accountDid, postUri, 'local');
      } else {
        await _database.unsavePost(_accountDid, postUri);
        _semanticIndexer?.removePost(postUri);
      }
      await _postActionRepository.deleteBookmark(uri: AtUri.parse(postUri));
      return true;
    } catch (error) {
      log.e('Failed to cloud unsave post', error: error);
      if (currentType == 'both') {
        await _database.updateSaveType(_accountDid, postUri, 'both');
      } else if (existingEntry != null) {
        await _database.savePost(
          SavedPostsCompanion(
            accountDid: Value(_accountDid),
            postUri: Value(postUri),
            postJson: Value(existingEntry.postJson),
            saveType: const Value('cloud'),
            savedAt: Value(existingEntry.savedAt),
          ),
        );
      }
      emit(state.copyWith(error: 'Failed to remove post from Bluesky'));
      return false;
    }
  }

  Future<void> syncCloudBookmarks() async {
    try {
      String? cursor;
      do {
        final output = await _postActionRepository.getBookmarks(limit: 100, cursor: cursor);
        for (final bookmark in output.bookmarks) {
          if (!bookmark.item.isPostView) {
            log.d('Skipping cloud bookmark without PostView payload: ${bookmark.subject.uri}');
            continue;
          }

          final post = bookmark.item.postView!;
          final postUri = post.uri.toString();
          final postJson = PoptartCacheCodecs.postView.encode(post);
          final existing = await _database.getSavedPost(_accountDid, postUri);
          if (existing == null) {
            await _database.savePost(
              SavedPostsCompanion(
                accountDid: Value(_accountDid),
                postUri: Value(postUri),
                postJson: Value(postJson),
                saveType: const Value('cloud'),
                savedAt: Value(bookmark.createdAt ?? DateTime.now()),
              ),
            );
            _semanticIndexer?.queueIndexPost(postUri, postJson, _accountDid, 'saved');
          } else if (existing.saveType == 'local') {
            await _database.updateSaveType(_accountDid, postUri, 'both');
          }
        }
        cursor = output.cursor;
      } while (cursor != null);
    } catch (error) {
      log.e('Failed to sync cloud bookmarks', error: error);
    }
  }

  @override
  Future<void> close() {
    _savedUrisSubscription?.cancel();
    return super.close();
  }
}
