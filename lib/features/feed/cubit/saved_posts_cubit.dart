import 'dart:async';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';

class SavedPostsState extends Equatable {
  const SavedPostsState({
    this.status = SavedPostsStatus.initial,
    this.savedPosts = const [],
    this.savedUris = const {},
    this.error,
  });

  final SavedPostsStatus status;
  final List<SavedPostEntry> savedPosts;
  final Set<String> savedUris;
  final String? error;

  bool isSaved(String postUri) => savedUris.contains(postUri);

  SavedPostsState copyWith({
    SavedPostsStatus? status,
    List<SavedPostEntry>? savedPosts,
    Set<String>? savedUris,
    String? error,
  }) {
    return SavedPostsState(
      status: status ?? this.status,
      savedPosts: savedPosts ?? this.savedPosts,
      savedUris: savedUris ?? this.savedUris,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, savedPosts, savedUris, error];
}

enum SavedPostsStatus { initial, loading, loaded, error }

class SavedPostsCubit extends Cubit<SavedPostsState> {
  SavedPostsCubit({required AppDatabase database, required String accountDid})
    : _database = database,
      _accountDid = accountDid,
      super(const SavedPostsState()) {
    _init();
  }

  final AppDatabase _database;
  final String _accountDid;
  StreamSubscription<Set<String>>? _savedUrisSubscription;

  void _init() {
    _savedUrisSubscription = _database
        .watchSavedPostUris(_accountDid)
        .listen(
          (uris) {
            emit(state.copyWith(savedUris: uris));
          },
          onError: (error) {
            log.e('Error watching saved post URIs', error: error);
          },
        );
  }

  Future<void> loadSavedPosts() async {
    emit(state.copyWith(status: SavedPostsStatus.loading, error: null));

    try {
      final posts = await _database.getSavedPosts(_accountDid);
      final uris = posts.map((p) => p.postUri).toSet();

      emit(state.copyWith(status: SavedPostsStatus.loaded, savedPosts: posts, savedUris: uris));
    } catch (error) {
      log.e('Failed to load saved posts', error: error);
      emit(state.copyWith(status: SavedPostsStatus.error, error: 'Failed to load saved posts'));
    }
  }

  Future<bool> toggleSave({required String postUri, required String postJson}) async {
    final isCurrentlySaved = state.isSaved(postUri);

    try {
      if (isCurrentlySaved) {
        await _database.unsavePost(_accountDid, postUri);
      } else {
        await _database.savePost(
          SavedPostsCompanion(
            accountDid: Value(_accountDid),
            postUri: Value(postUri),
            postJson: Value(postJson),
            savedAt: Value(DateTime.now()),
          ),
        );
      }

      await loadSavedPosts();
      return true;
    } catch (error) {
      log.e('Failed to toggle save', error: error);
      emit(state.copyWith(error: 'Failed to ${isCurrentlySaved ? 'unsave' : 'save'} post'));
      return false;
    }
  }

  Future<bool> savePost({required String postUri, required String postJson}) async {
    if (state.isSaved(postUri)) return true;
    return toggleSave(postUri: postUri, postJson: postJson);
  }

  Future<bool> unsavePost(String postUri) async {
    if (!state.isSaved(postUri)) return true;
    return toggleSave(postUri: postUri, postJson: '');
  }

  Future<void> unsavePostById(int id) async {
    try {
      await _database.unsavePostById(id);
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

  Stream<bool> watchIsSaved(String postUri) {
    return _database.watchIsPostSaved(_accountDid, postUri);
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  @override
  Future<void> close() {
    _savedUrisSubscription?.cancel();
    return super.close();
  }
}
