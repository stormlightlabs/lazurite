import 'package:bluesky_poptart/app/bsky/feed/defs.dart' show GeneratorView;
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/list.dart';
import 'package:bluesky_poptart/app/bsky/graph/starterpack.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:poptart_core/poptart_core.dart' as atcore show UnauthorizedException;

class StarterPackRepository {
  StarterPackRepository({
    required Bluesky bluesky,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;

  Future<ActorStarterPacksResult> getActorStarterPacks({required String actor, String? cursor, int limit = 50}) async {
    final headers = await _moderationService?.headersForRequest();
    final response = await _authRecovery.run(
      (client) => client.graph.getActorStarterPacks(
        actor: actor,
        cursor: cursor,
        limit: limit,
        $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.graph.getActorStarterPacks', headers),
      ),
    );

    return ActorStarterPacksResult(starterPacks: response.data.starterPacks, cursor: response.data.cursor);
  }

  Future<StarterPackView> getStarterPack({required AtUri starterPackUri}) async {
    final headers = await _moderationService?.headersForRequest();
    final response = await _authRecovery.run(
      (client) => client.graph.getStarterPack(
        starterPack: starterPackUri,
        $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.graph.getStarterPack', headers),
      ),
    );

    return response.data.starterPack;
  }

  Future<List<GeneratorView>> getSuggestedFeeds({int limit = 50}) async {
    final headers = await _moderationService?.headersForRequest();
    final response = await _authRecovery.run(
      (client) => client.feed.getSuggestedFeeds(
        limit: limit,
        $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.feed.getSuggestedFeeds', headers),
      ),
    );
    return response.data.feeds;
  }

  /// Creates a starter pack using the 3-step flow:
  /// 1. Create a reference list
  /// 2. Add members as listitem records
  /// 3. Create the starter pack record pointing at the reference list
  Future<AtUri> createStarterPack({
    required String userDid,
    required String name,
    String? description,
    List<String> memberDids = const [],
    List<AtUri> feedUris = const [],
  }) async {
    final refListUri = await _createReferenceList(userDid: userDid);

    for (final did in memberDids) {
      await addMember(listUri: refListUri, subjectDid: did);
    }

    final feeds = feedUris.map((uri) => FeedItem(uri: uri)).toList();
    final headers = await _moderationService?.headersForRequest();

    final response = await _authRecovery.run(
      (client) => client.graph.starterpack.create(
        name: name,
        description: description,
        list: refListUri,
        feeds: feeds.isEmpty ? null : feeds,
        createdAt: DateTime.now(),
        $headers: _appViewContext.appBskyHeadersWithoutProxy(headers),
      ),
    );

    return response.data.uri;
  }

  Future<void> updateStarterPack({
    required AtUri packUri,
    required AtUri referenceListUri,
    required String name,
    String? description,
    List<AtUri> feedUris = const [],
  }) async {
    final feeds = feedUris.map((uri) => FeedItem(uri: uri)).toList();
    final headers = await _moderationService?.headersForRequest();

    await _authRecovery.run(
      (client) => client.graph.starterpack.put(
        rkey: packUri.rkey,
        name: name,
        description: description,
        list: referenceListUri,
        feeds: feeds.isEmpty ? null : feeds,
        createdAt: DateTime.now(),
        $headers: _appViewContext.appBskyHeadersWithoutProxy(headers),
      ),
    );
  }

  Future<void> deleteStarterPack({
    required AtUri packUri,
    required AtUri referenceListUri,
    required String userDid,
  }) async {
    final headers = await _moderationService?.headersForRequest();
    await _authRecovery.run(
      (client) => client.graph.starterpack.delete(
        rkey: packUri.rkey,
        $headers: _appViewContext.appBskyHeadersWithoutProxy(headers),
      ),
    );
    await _authRecovery.run(
      (client) => client.atproto.repo.deleteRecord(
        repo: userDid,
        collection: 'app.bsky.graph.list',
        rkey: referenceListUri.rkey,
      ),
    );
  }

  Future<String> addMember({required AtUri listUri, required String subjectDid}) async {
    final headers = await _moderationService?.headersForRequest();
    final response = await _authRecovery.run(
      (client) => client.graph.listitem.create(
        list: listUri,
        subject: subjectDid,
        createdAt: DateTime.now(),
        $headers: _appViewContext.appBskyHeadersWithoutProxy(headers),
      ),
    );

    return response.data.uri.toString();
  }

  Future<void> removeMember({required AtUri listItemUri}) async {
    final headers = await _moderationService?.headersForRequest();
    await _authRecovery.run(
      (client) => client.graph.listitem.delete(
        rkey: listItemUri.rkey,
        $headers: _appViewContext.appBskyHeadersWithoutProxy(headers),
      ),
    );
  }

  /// Follows every member in the starter pack's backing reference list.
  /// Paginates through all list items and calls follow.create for each.
  /// Returns the number of members followed.
  Future<int> followAll({required AtUri referenceListUri}) async {
    int count = 0;
    String? cursor;
    final headers = await _moderationService?.headersForRequest();
    do {
      final response = await _authRecovery.run(
        (client) => client.graph.getList(
          list: referenceListUri,
          cursor: cursor,
          limit: 100,
          $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.graph.getList', headers),
        ),
      );

      for (final item in response.data.items as List) {
        try {
          await _authRecovery.run(
            (client) => client.graph.follow.create(
              subject: item.subject.did as String,
              createdAt: DateTime.now(),
              $headers: _appViewContext.appBskyHeadersWithoutProxy(headers),
            ),
          );
          count++;
        } on atcore.UnauthorizedException {
          rethrow;
        } catch (error, stackTrace) {
          log.d('Follow-all member follow failed', error: error, stackTrace: stackTrace);
          log.w('Failed to follow ${item.subject.did} (already followed or blocked)');
        }
      }

      cursor = response.data.cursor;
    } while (cursor != null);

    return count;
  }

  Future<AtUri> _createReferenceList({required String userDid}) async {
    final response = await _authRecovery.run(
      (client) => client.atproto.repo.createRecord(
        repo: userDid,
        collection: 'app.bsky.graph.list',
        record: GraphListRecord(
          purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsReferencelist),
          name: 'Starter Pack Members',
          createdAt: DateTime.now().toUtc(),
        ).toJson(),
      ),
    );

    return response.data.uri;
  }
}

class ActorStarterPacksResult {
  const ActorStarterPacksResult({required this.starterPacks, this.cursor});

  final List<StarterPackViewBasic> starterPacks;
  final String? cursor;
}
