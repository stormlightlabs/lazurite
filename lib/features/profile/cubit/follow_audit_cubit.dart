import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';

enum FollowAuditStatus { initial, fetching, classifying, ready, unfollowing, complete, error }

class FollowAuditState extends Equatable {
  const FollowAuditState({
    this.status = FollowAuditStatus.initial,
    this.results = const [],
    this.totalFollows = 0,
    this.progress = 0,
    this.failedProfiles = 0,
    this.unfollowedCount = 0,
    this.errorMessage,
    this.visibleStatuses = const {},
  });

  final FollowAuditStatus status;
  final List<ClassifiedFollow> results;
  final int totalFollows;
  final int progress;
  final int failedProfiles;
  final int unfollowedCount;
  final String? errorMessage;
  final Set<FollowStatus> visibleStatuses;

  List<ClassifiedFollow> get selectedResults => results.where((r) => r.selected).toList();

  FollowAuditState copyWith({
    FollowAuditStatus? status,
    List<ClassifiedFollow>? results,
    int? totalFollows,
    int? progress,
    int? failedProfiles,
    int? unfollowedCount,
    String? errorMessage,
    Set<FollowStatus>? visibleStatuses,
    bool clearError = false,
  }) {
    return FollowAuditState(
      status: status ?? this.status,
      results: results ?? this.results,
      totalFollows: totalFollows ?? this.totalFollows,
      progress: progress ?? this.progress,
      failedProfiles: failedProfiles ?? this.failedProfiles,
      unfollowedCount: unfollowedCount ?? this.unfollowedCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      visibleStatuses: visibleStatuses ?? this.visibleStatuses,
    );
  }

  @override
  List<Object?> get props => [
    status,
    results,
    results.map((r) => r.selected).toList(),
    totalFollows,
    progress,
    failedProfiles,
    unfollowedCount,
    errorMessage,
    visibleStatuses,
  ];
}

class FollowAuditCubit extends Cubit<FollowAuditState> {
  FollowAuditCubit({required FollowAuditRepository repository, required String ownDid})
    : _repository = repository,
      _ownDid = ownDid,
      super(const FollowAuditState());

  final FollowAuditRepository _repository;
  final String _ownDid;

  /// Fetches all follows then classifies them, emitting progress states along the way.
  Future<void> audit() async {
    emit(state.copyWith(status: FollowAuditStatus.fetching, progress: 0, clearError: true));

    List<FollowRecord> records;
    try {
      records = await _repository.fetchAllFollows(
        _ownDid,
        onProgress: (fetched) {
          emit(state.copyWith(status: FollowAuditStatus.fetching, progress: fetched));
        },
      );
    } catch (error, stackTrace) {
      log.e('FollowAuditCubit: fetch failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(status: FollowAuditStatus.error, errorMessage: error.toString()));
      return;
    }

    emit(state.copyWith(status: FollowAuditStatus.classifying, totalFollows: records.length, progress: 0));

    try {
      final (:results, :failedCount) = await _repository.classifyFollows(
        records,
        _ownDid,
        onProgress: (classified) {
          emit(state.copyWith(status: FollowAuditStatus.classifying, progress: classified));
        },
      );

      emit(
        state.copyWith(
          status: FollowAuditStatus.ready,
          results: results,
          failedProfiles: failedCount,
          progress: records.length,
          visibleStatuses: FollowStatus.values.toSet(),
        ),
      );
    } catch (error, stackTrace) {
      log.e('FollowAuditCubit: classify failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(status: FollowAuditStatus.error, errorMessage: error.toString()));
    }
  }

  /// Toggles the selection of the result at [index].
  void toggleSelection(int index) {
    if (index < 0 || index >= state.results.length) return;
    final updated = List<ClassifiedFollow>.from(state.results);
    updated[index] = updated[index].copyWith(selected: !updated[index].selected);
    emit(state.copyWith(results: updated));
  }

  /// Selects all results with the given [status].
  void selectAllByStatus(FollowStatus status) {
    final updated = state.results.map((r) => r.status == status ? r.copyWith(selected: true) : r).toList();
    emit(state.copyWith(results: updated));
  }

  /// Deselects all results with the given [status].
  void deselectAllByStatus(FollowStatus status) {
    final updated = state.results.map((r) => r.status == status ? r.copyWith(selected: false) : r).toList();
    emit(state.copyWith(results: updated));
  }

  /// Toggles visibility of [status] in the results list.
  void toggleVisibility(FollowStatus status) {
    final current = Set<FollowStatus>.from(state.visibleStatuses);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    emit(state.copyWith(visibleStatuses: current));
  }

  /// Batch-deletes selected follows, transitioning to complete on success.
  Future<void> confirmUnfollow() async {
    final selected = state.selectedResults;
    if (selected.isEmpty) return;

    emit(state.copyWith(status: FollowAuditStatus.unfollowing));

    try {
      final count = await _repository.batchUnfollow(selected, _ownDid);
      final selectedUris = selected.map((r) => r.record.uri).toSet();
      final remaining = state.results.where((r) => !selectedUris.contains(r.record.uri)).toList();

      emit(state.copyWith(status: FollowAuditStatus.complete, results: remaining, unfollowedCount: count));
    } catch (error, stackTrace) {
      log.e('FollowAuditCubit: unfollow failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(status: FollowAuditStatus.error, errorMessage: error.toString()));
    }
  }
}
