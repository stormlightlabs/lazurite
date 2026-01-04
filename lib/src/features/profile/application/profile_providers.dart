import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('ProfileRepository'));
  return ProfileRepository(api, db.profileDao, logger);
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<ProfileData> build(String actor) async {
    return _fetchProfile(actor);
  }

  Future<ProfileData> _fetchProfile(String actor) async {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getProfile(actor);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProfile(actor));
  }
}

@riverpod
class AuthorFeedNotifier extends _$AuthorFeedNotifier {
  String? _cursor;
  bool _hasMore = true;

  @override
  Future<List<FeedItem>> build(String actor) async {
    return _fetchFeed(actor);
  }

  Future<List<FeedItem>> _fetchFeed(String actor, {bool loadMore = false}) async {
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
