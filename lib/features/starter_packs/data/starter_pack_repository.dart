import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_feed_defs.dart' show GeneratorView;
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:bluesky/app_bsky_graph_starterpack.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class StarterPackRepository {
  StarterPackRepository({required dynamic bluesky, ModerationService? moderationService})
    : _bluesky = bluesky,
      _moderationService = moderationService;

  final dynamic _bluesky;
  final ModerationService? _moderationService;

  Future<ActorStarterPacksResult> getActorStarterPacks({required String actor, String? cursor, int limit = 50}) async {
    final response = await _bluesky.graph.getActorStarterPacks(
      actor: actor,
      cursor: cursor,
      limit: limit,
      $headers: await _moderationService?.headersForRequest(),
    );

    return ActorStarterPacksResult(starterPacks: response.data.starterPacks, cursor: response.data.cursor);
  }

  Future<StarterPackView> getStarterPack({required AtUri starterPackUri}) async {
    final response = await _bluesky.graph.getStarterPack(
      starterPack: starterPackUri,
      $headers: await _moderationService?.headersForRequest(),
    );

    return response.data.starterPack;
  }

  Future<List<GeneratorView>> getSuggestedFeeds({int limit = 50}) async {
    final response = await _bluesky.feed.getSuggestedFeeds(limit: limit);
    return response.data.feeds as List<GeneratorView>;
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

    final response = await _bluesky.graph.starterpack.create(
      name: name,
      description: description,
      list: refListUri,
      feeds: feeds.isEmpty ? null : feeds,
      createdAt: DateTime.now(),
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

    await _bluesky.graph.starterpack.put(
      rkey: packUri.rkey,
      name: name,
      description: description,
      list: referenceListUri,
      feeds: feeds.isEmpty ? null : feeds,
      createdAt: DateTime.now(),
    );
  }

  Future<void> deleteStarterPack({
    required AtUri packUri,
    required AtUri referenceListUri,
    required String userDid,
  }) async {
    await _bluesky.graph.starterpack.delete(rkey: packUri.rkey);
    await _bluesky.atproto.repo.deleteRecord(
      repo: userDid,
      collection: 'app.bsky.graph.list',
      rkey: referenceListUri.rkey,
    );
  }

  Future<String> addMember({required AtUri listUri, required String subjectDid}) async {
    final response = await _bluesky.graph.listitem.create(
      list: listUri,
      subject: subjectDid,
      createdAt: DateTime.now(),
    );

    return response.data.uri.toString();
  }

  Future<void> removeMember({required AtUri listItemUri}) async {
    await _bluesky.graph.listitem.delete(rkey: listItemUri.rkey);
  }

  /// Follows every member in the starter pack's backing reference list.
  /// Paginates through all list items and calls follow.create for each.
  /// Returns the number of members followed.
  Future<int> followAll({required AtUri referenceListUri}) async {
    int count = 0;
    String? cursor;

    do {
      final response = await _bluesky.graph.getList(list: referenceListUri, cursor: cursor, limit: 100);

      for (final item in response.data.items as List) {
        try {
          await _bluesky.graph.follow.create(subject: item.subject.did as String, createdAt: DateTime.now());
          count++;
        } catch (_) {
          log.w('Failed to follow ${item.subject.did} (already followed or blocked)');
        }
      }

      cursor = response.data.cursor as String?;
    } while (cursor != null);

    return count;
  }

  Future<AtUri> _createReferenceList({required String userDid}) async {
    final response = await _bluesky.atproto.repo.createRecord(
      repo: userDid,
      collection: 'app.bsky.graph.list',
      record: <String, dynamic>{
        r'$type': 'app.bsky.graph.list',
        'purpose': 'app.bsky.graph.defs#referencelist',
        'name': 'Starter Pack Members',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      },
    );

    return response.data.uri;
  }
}

class ActorStarterPacksResult {
  const ActorStarterPacksResult({required this.starterPacks, this.cursor});

  final List<StarterPackViewBasic> starterPacks;
  final String? cursor;
}
