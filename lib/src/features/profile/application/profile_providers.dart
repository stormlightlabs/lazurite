import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/profile/domain/profile.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('ProfileRepository'));
  return ProfileRepository(api, db.profileDao, db.followsDao, db.profileRelationshipDao, logger);
}

@riverpod
Future<Post?> pinnedPost(Ref ref, String uri) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getPost(uri);
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<ProfileData> build(String actor) async {
    return _fetchProfile(actor);
  }

  Future<ProfileData> _fetchProfile(String actor) async {
    final repository = ref.read(profileRepositoryProvider);
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : 'anonymous';
    return repository.getProfile(actor, ownerDid);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProfile(actor));
  }

  /// Updates the local following state (used after follow/unfollow mutations).
  void updateFollowingState({required bool isFollowing, String? followUri}) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(viewerFollowing: isFollowing, viewerFollowUri: followUri));
  }

  /// Toggles the mute status of the profile.
  Future<void> toggleMute() async {
    final current = state.value;
    if (current == null) return;

    final wasMuted = current.viewerMuted;
    state = AsyncData(current.copyWith(viewerMuted: !wasMuted));

    try {
      final repo = ref.read(profileRepositoryProvider);
      if (wasMuted) {
        await repo.unmuteActor(authState.session.did, current.did);
      } else {
        await repo.muteActor(authState.session.did, current.did);
      }
    } catch (e) {
      if (state.hasValue) {
        state = AsyncData(current);
      }
      rethrow;
    }
  }

  /// Toggles the block status of the profile.
  Future<void> toggleBlock() async {
    final current = state.value;
    if (current == null) return;

    final wasBlocked = current.viewerBlockingUri != null;
    final originalUri = current.viewerBlockingUri;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      if (wasBlocked) {
        await repo.unblockActor(authState.session.did, originalUri!, subjectDid: current.did);
        return current.copyWith(viewerBlockingUri: null);
      } else {
        final uri = await repo.blockActor(authState.session.did, current.did);
        return current.copyWith(viewerBlockingUri: uri);
      }
    });
  }

  /// Reports the profile.
  Future<void> report({required String reasonType, String? reason}) async {
    final current = state.value;
    if (current == null) return;

    await ref
        .read(profileRepositoryProvider)
        .createReport(reasonType: reasonType, subjectDid: current.did, reason: reason);
  }

  AuthStateAuthenticated get authState {
    final auth = ref.read(authProvider);
    if (auth is! AuthStateAuthenticated) {
      throw StateError('Must be authenticated');
    }
    return auth;
  }
}

@riverpod
class AuthorFeedNotifier extends _$AuthorFeedNotifier {
  String? _cursor;
  bool _hasMore = true;

  @override
  Future<List<Post>> build(String actor) async {
    return _fetchFeed(actor);
  }

  Future<List<Post>> _fetchFeed(String actor, {bool loadMore = false}) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getAuthorFeed(actor, cursor: loadMore ? _cursor : null);

    _cursor = result.cursor;
    _hasMore = result.hasMore;

    if (loadMore) {
      final current = state.value ?? [];
      return [...current, ...result.items];
    }
    return result.items;
  }

  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    state = AsyncData(await _fetchFeed(actor, loadMore: true));
  }

  Future<void> refresh() async {
    _cursor = null;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFeed(actor));
  }
}

/// Notifier for managing follow/unfollow mutations.
@riverpod
class FollowNotifier extends _$FollowNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Follow a user.
  Future<void> follow(String subjectDid) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) {
      state = AsyncError(StateError('Must be authenticated to follow'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      final uri = await repo.follow(authState.session.did, subjectDid);

      ref
          .read(profileProvider(subjectDid).notifier)
          .updateFollowingState(isFollowing: true, followUri: uri);
    });
  }

  /// Unfollow a user.
  Future<void> unfollow(String subjectDid, String followUri) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) {
      state = AsyncError(StateError('Must be authenticated to unfollow'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.unfollow(authState.session.did, followUri);

      ref
          .read(profileProvider(subjectDid).notifier)
          .updateFollowingState(isFollowing: false, followUri: null);
    });
  }
}

/// Notifier for managing followers list with cursor pagination.
@riverpod
class FollowersNotifier extends _$FollowersNotifier {
  String? _cursor;
  bool _hasMore = true;

  @override
  Future<List<Author>> build(String actor) async {
    return _fetchFollowers(actor);
  }

  Future<List<Author>> _fetchFollowers(String actor, {bool loadMore = false}) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getFollowers(actor, cursor: loadMore ? _cursor : null);

    _cursor = result.cursor;
    _hasMore = result.hasMore;

    if (loadMore) {
      final current = state.value ?? [];
      return [...current, ...result.followers];
    }
    return result.followers;
  }

  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    state = AsyncData(await _fetchFollowers(actor, loadMore: true));
  }

  Future<void> refresh() async {
    _cursor = null;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFollowers(actor));
  }
}

/// Notifier for managing following list with cursor pagination.
@riverpod
class FollowingNotifier extends _$FollowingNotifier {
  String? _cursor;
  bool _hasMore = true;

  @override
  Future<List<Author>> build(String actor) async {
    return _fetchFollowing(actor);
  }

  Future<List<Author>> _fetchFollowing(String actor, {bool loadMore = false}) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getFollows(actor, cursor: loadMore ? _cursor : null);

    _cursor = result.cursor;
    _hasMore = result.hasMore;

    if (loadMore) {
      final current = state.value ?? [];
      return [...current, ...result.follows];
    }
    return result.follows;
  }

  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    state = AsyncData(await _fetchFollowing(actor, loadMore: true));
  }

  Future<void> refresh() async {
    _cursor = null;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFollowing(actor));
  }
}
