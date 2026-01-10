import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/infrastructure/post_interaction_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_interaction_providers.g.dart';

/// Domain model for post interaction state (mirrors PostInteraction entity).
class PostInteractionData {
  PostInteractionData({
    required this.postUri,
    this.likeUri,
    this.repostUri,
    this.bookmarkUri,
    required this.bookmarked,
    required this.threadMuted,
  });

  final String postUri;
  final String? likeUri;
  final String? repostUri;
  final String? bookmarkUri;
  final bool bookmarked;
  final bool threadMuted;

  static PostInteractionData fromEntity(PostInteraction entity) {
    return PostInteractionData(
      postUri: entity.postUri,
      likeUri: entity.likeUri,
      repostUri: entity.repostUri,
      bookmarkUri: entity.bookmarkUri,
      bookmarked: entity.bookmarked,
      threadMuted: entity.threadMuted,
    );
  }
}

@riverpod
PostInteractionRepository postInteractionRepository(Ref ref) {
  return PostInteractionRepository(
    ref.watch(xrpcClientProvider),
    ref.watch(appDatabaseProvider).postInteractionsDao,
    ref.watch(loggerProvider('PostInteractionRepository')),
  );
}

@riverpod
Stream<PostInteractionData?> postInteractionState(Ref ref, String postUri) {
  final authState = ref.watch(authProvider);
  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;
  if (ownerDid == null) return Stream.value(null);

  final dao = ref.watch(appDatabaseProvider).postInteractionsDao;
  return dao.watchInteraction(postUri, ownerDid).map((entity) {
    if (entity == null) return null;
    return PostInteractionData.fromEntity(entity);
  });
}
