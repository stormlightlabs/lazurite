import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/feed/data/liked_posts_repository.dart';

enum LikedPostsSyncStatus { idle, syncing, synced, error }

class LikedPostsSyncState extends Equatable {
  const LikedPostsSyncState({this.status = LikedPostsSyncStatus.idle, this.errorMessage});

  final LikedPostsSyncStatus status;
  final String? errorMessage;

  bool get isSyncing => status == LikedPostsSyncStatus.syncing;

  LikedPostsSyncState copyWith({LikedPostsSyncStatus? status, String? errorMessage}) => LikedPostsSyncState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, errorMessage];
}

/// Cubit that triggers a sync of the user's liked posts from the Bluesky API.
///
/// Exposes [sync] to kick off the sync operation.
/// Progress is represented as status transitions: idle → syncing → synced/error.
class LikedPostsSyncCubit extends Cubit<LikedPostsSyncState> {
  LikedPostsSyncCubit({required LikedPostsRepository repository, required String accountDid})
    : _repository = repository,
      _accountDid = accountDid,
      super(const LikedPostsSyncState());

  final LikedPostsRepository _repository;
  final String _accountDid;

  /// Sync liked posts for this account from the Bluesky API.
  ///
  /// A no-op if a sync is already in progress.
  Future<void> sync() async {
    if (state.isSyncing) return;
    emit(const LikedPostsSyncState(status: LikedPostsSyncStatus.syncing));
    try {
      await _repository.syncLikes(_accountDid);
      if (!isClosed) emit(const LikedPostsSyncState(status: LikedPostsSyncStatus.synced));
    } catch (e) {
      if (!isClosed) {
        emit(LikedPostsSyncState(status: LikedPostsSyncStatus.error, errorMessage: 'Sync failed: $e'));
      }
    }
  }
}
