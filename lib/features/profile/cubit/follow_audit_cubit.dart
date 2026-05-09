import 'dart:async';

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
  StreamSubscription<FollowAuditBatch>? _scanSubscription;
  Completer<void>? _scanCompleter;
  int _auditGeneration = 0;

  @override
  Future<void> close() {
    _auditGeneration++;
    unawaited(_scanSubscription?.cancel());
    _scanSubscription = null;
    if (_scanCompleter?.isCompleted == false) {
      _scanCompleter?.complete();
    }
    _scanCompleter = null;
    return super.close();
  }

  /// Scans follows and appends classified results as each page is processed.
  Future<void> audit() async {
    unawaited(_scanSubscription?.cancel());
    if (_scanCompleter?.isCompleted == false) {
      _scanCompleter?.complete();
    }
    final generation = ++_auditGeneration;
    final completer = Completer<void>();
    _scanCompleter = completer;

    emit(
      state.copyWith(
        status: FollowAuditStatus.fetching,
        results: const [],
        totalFollows: 0,
        progress: 0,
        failedProfiles: 0,
        unfollowedCount: 0,
        visibleStatuses: FollowStatus.values.toSet(),
        clearError: true,
      ),
    );

    _scanSubscription = _repository
        .scanFollows(_ownDid)
        .listen(
          (batch) {
            if (!_isActiveAudit(generation)) {
              return;
            }
            emit(
              state.copyWith(
                status: batch.isComplete ? FollowAuditStatus.ready : FollowAuditStatus.classifying,
                results: [...state.results, ...batch.results],
                totalFollows: _displayTotalFor(batch),
                progress: batch.classifiedCount,
                failedProfiles: batch.failedCount,
                visibleStatuses: FollowStatus.values.toSet(),
              ),
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            log.e('FollowAuditCubit: scan failed', error: error, stackTrace: stackTrace);
            if (_isActiveAudit(generation)) {
              emit(state.copyWith(status: FollowAuditStatus.error, errorMessage: error.toString()));
            }
            if (!completer.isCompleted) {
              completer.complete();
            }
            if (identical(_scanCompleter, completer)) {
              _scanCompleter = null;
            }
          },
          onDone: () {
            if (_isActiveAudit(generation) &&
                (state.status == FollowAuditStatus.fetching || state.status == FollowAuditStatus.classifying)) {
              emit(state.copyWith(status: FollowAuditStatus.ready));
            }
            if (_isActiveAudit(generation)) {
              _scanSubscription = null;
            }
            if (!completer.isCompleted) {
              completer.complete();
            }
            if (identical(_scanCompleter, completer)) {
              _scanCompleter = null;
            }
          },
          cancelOnError: true,
        );

    await completer.future;
  }

  Future<void> cancelAudit() async {
    final subscription = _scanSubscription;
    if (subscription == null ||
        (state.status != FollowAuditStatus.fetching && state.status != FollowAuditStatus.classifying)) {
      return;
    }

    _auditGeneration++;
    unawaited(subscription.cancel());
    if (identical(_scanSubscription, subscription)) {
      _scanSubscription = null;
    }
    if (_scanCompleter?.isCompleted == false) {
      _scanCompleter?.complete();
    }
    _scanCompleter = null;
    emit(state.copyWith(status: FollowAuditStatus.ready));
  }

  bool _isActiveAudit(int generation) => !isClosed && generation == _auditGeneration;

  int _displayTotalFor(FollowAuditBatch batch) {
    final expectedTotal = batch.totalFollows;
    if (expectedTotal == null) {
      return batch.scannedCount;
    }
    return expectedTotal < batch.scannedCount ? batch.scannedCount : expectedTotal;
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
      final updatedTotal = (state.totalFollows - count).clamp(0, state.totalFollows);
      final updatedProgress = (state.progress - count).clamp(0, state.progress);

      emit(
        state.copyWith(
          status: FollowAuditStatus.complete,
          results: remaining,
          totalFollows: updatedTotal,
          progress: updatedProgress,
          unfollowedCount: count,
        ),
      );
    } catch (error, stackTrace) {
      log.e('FollowAuditCubit: unfollow failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(status: FollowAuditStatus.error, errorMessage: error.toString()));
    }
  }
}
