import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/profile/data/profile_context_repository.dart';

part 'profile_context_state.dart';

class ProfileContextCubit extends Cubit<ProfileContextState> {
  ProfileContextCubit({required ProfileContextRepository repository, required String did, required bool isOwnProfile})
    : _repository = repository,
      super(ProfileContextState.initial(did: did, isOwnProfile: isOwnProfile));

  final ProfileContextRepository _repository;

  /// Loads blocked-by and lists-on counts in parallel for tab header badges.
  Future<void> init() async {
    try {
      final results = await Future.wait([
        _repository.getBlockedByCount(state.did),
        _repository.getListsOnCount(state.did),
      ]);
      emit(state.copyWith(blockedByCount: results[0], listsOnCount: results[1]));
    } catch (error) {
      log.w('failed to load initial counts: $error');
    }
  }

  /// Fetches a page of profiles that have blocked the viewed user and appends
  /// them to state. Pass [cursor] from [state.blockedByCursor] for pagination.
  Future<void> loadBlockedBy({String? cursor}) async {
    if (state.blockedByStatus == ProfileContextTabStatus.loading) return;

    emit(state.copyWith(blockedByStatus: ProfileContextTabStatus.loading, blockedByError: null));

    try {
      final result = await _repository.getBlockedByProfiles(state.did, cursor: cursor);
      emit(
        state.copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByProfiles: [...state.blockedByProfiles, ...result.profiles],
          blockedByCount: result.total,
          blockedByCursor: result.cursor,
          blockedByHasMore: result.cursor != null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          blockedByStatus: ProfileContextTabStatus.error,
          blockedByError: 'Failed to load blocked-by profiles: $error',
        ),
      );
    }
  }

  /// Fetches a page of profiles that the viewed user is blocking and appends
  /// them to state. Only available when [state.isOwnProfile] is true.
  Future<void> loadBlocking({String? cursor}) async {
    if (!state.isOwnProfile) return;
    if (state.blockingStatus == ProfileContextTabStatus.loading) return;

    emit(state.copyWith(blockingStatus: ProfileContextTabStatus.loading, blockingError: null));

    try {
      final result = await _repository.getBlockingProfiles(state.did, cursor: cursor);
      final merged = [...state.blockingProfiles, ...result.profiles];
      emit(
        state.copyWith(
          blockingStatus: ProfileContextTabStatus.loaded,
          blockingProfiles: merged,
          blockingCount: merged.length,
          blockingCursor: result.cursor,
          blockingHasMore: result.cursor != null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          blockingStatus: ProfileContextTabStatus.error,
          blockingError: 'Failed to load blocking profiles: $error',
        ),
      );
    }
  }

  /// Fetches a page of lists the viewed user is on and appends them to state.
  /// Pass [cursor] from [state.listsOnCursor] for pagination.
  Future<void> loadListsOn({String? cursor}) async {
    if (state.listsOnStatus == ProfileContextTabStatus.loading) return;

    emit(state.copyWith(listsOnStatus: ProfileContextTabStatus.loading, listsOnError: null));

    try {
      final result = await _repository.getListsOn(state.did, cursor: cursor);
      emit(
        state.copyWith(
          listsOnStatus: ProfileContextTabStatus.loaded,
          listsOn: [...state.listsOn, ...result.lists],
          listsOnCount: result.total,
          listsOnCursor: result.cursor,
          listsOnHasMore: result.cursor != null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(listsOnStatus: ProfileContextTabStatus.error, listsOnError: 'Failed to load lists: $error'));
    }
  }

  /// Resets the blocked-by list and reloads from the first page.
  Future<void> refreshBlockedBy() async {
    emit(
      state.copyWith(
        blockedByProfiles: [],
        blockedByCursor: null,
        blockedByHasMore: false,
        blockedByStatus: ProfileContextTabStatus.initial,
        blockedByError: null,
      ),
    );
    await loadBlockedBy();
  }

  /// Resets the blocking list and reloads from the first page.
  Future<void> refreshBlocking() async {
    if (!state.isOwnProfile) return;
    emit(
      state.copyWith(
        blockingProfiles: [],
        blockingCursor: null,
        blockingHasMore: false,
        blockingStatus: ProfileContextTabStatus.initial,
        blockingError: null,
        blockingCount: 0,
      ),
    );
    await loadBlocking();
  }

  /// Resets the lists-on list and reloads from the first page.
  Future<void> refreshListsOn() async {
    emit(
      state.copyWith(
        listsOn: [],
        listsOnCursor: null,
        listsOnHasMore: false,
        listsOnStatus: ProfileContextTabStatus.initial,
        listsOnError: null,
      ),
    );
    await loadListsOn();
  }
}
