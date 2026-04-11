import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/features/search/data/semantic_indexer.dart';

enum SemanticIndexStatus { idle, backfilling, error }

class SemanticIndexState extends Equatable {
  const SemanticIndexState({
    this.status = SemanticIndexStatus.idle,
    this.indexedCount = 0,
    this.backfillCompleted,
    this.backfillTotal,
    this.errorMessage,
  });

  final SemanticIndexStatus status;

  /// Number of posts currently in the embedding index for this account.
  final int indexedCount;

  /// Number of posts completed during the current backfill, or null when idle.
  final int? backfillCompleted;

  /// Total posts to backfill, or null when idle.
  final int? backfillTotal;

  final String? errorMessage;

  bool get isBackfilling => status == SemanticIndexStatus.backfilling;

  SemanticIndexState copyWith({
    SemanticIndexStatus? status,
    int? indexedCount,
    int? backfillCompleted,
    int? backfillTotal,
    String? errorMessage,
  }) => SemanticIndexState(
    status: status ?? this.status,
    indexedCount: indexedCount ?? this.indexedCount,
    backfillCompleted: backfillCompleted ?? this.backfillCompleted,
    backfillTotal: backfillTotal ?? this.backfillTotal,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, indexedCount, backfillCompleted, backfillTotal, errorMessage];
}

/// Cubit that manages the semantic embedding index for an account.
///
/// Exposes [loadCount] to refresh [SemanticIndexState.indexedCount] and
/// [reindex] to clear the existing index and re-embed all saved/liked posts.
/// [SemanticIndexState.backfillCompleted] and [SemanticIndexState.backfillTotal]
/// track backfill progress for display in the settings UI.
class SemanticIndexCubit extends Cubit<SemanticIndexState> {
  SemanticIndexCubit({
    required SemanticIndexer indexer,
    required EmbeddingRepository embeddingRepository,
    required String accountDid,
  }) : _indexer = indexer,
       _embeddingRepository = embeddingRepository,
       _accountDid = accountDid,
       super(const SemanticIndexState());

  final SemanticIndexer _indexer;
  final EmbeddingRepository _embeddingRepository;
  final String _accountDid;
  StreamSubscription<(int, int)>? _backfillSubscription;

  /// Refresh [SemanticIndexState.indexedCount] from the embedding store.
  void loadCount() {
    final count = _embeddingRepository.countByAccount(_accountDid);
    emit(state.copyWith(indexedCount: count));
  }

  /// Clear the existing index for this account and re-embed all posts.
  ///
  /// A no-op if a backfill is already in progress.
  Future<void> reindex() async {
    if (state.isBackfilling) return;

    final existing = _embeddingRepository.queryByAccount(_accountDid);
    for (final post in existing) {
      _embeddingRepository.deleteByUri(post.postUri);
    }

    emit(
      const SemanticIndexState(
        status: SemanticIndexStatus.backfilling,
        indexedCount: 0,
        backfillCompleted: 0,
        backfillTotal: 0,
      ),
    );

    await _backfillSubscription?.cancel();

    var hadError = false;
    _backfillSubscription = _indexer
        .backfill(_accountDid)
        .listen(
          (progress) {
            final (completed, total) = progress;
            if (!isClosed) {
              emit(
                state.copyWith(
                  status: SemanticIndexStatus.backfilling,
                  backfillCompleted: completed,
                  backfillTotal: total,
                  indexedCount: completed,
                ),
              );
            }
          },
          onDone: () {
            if (!isClosed && !hadError) {
              final count = _embeddingRepository.countByAccount(_accountDid);
              emit(SemanticIndexState(status: SemanticIndexStatus.idle, indexedCount: count));
            }
          },
          onError: (Object e) {
            hadError = true;
            if (!isClosed) {
              emit(SemanticIndexState(status: SemanticIndexStatus.error, errorMessage: 'Indexing failed: $e'));
            }
          },
        );
  }

  @override
  Future<void> close() async {
    await _backfillSubscription?.cancel();
    return super.close();
  }
}
