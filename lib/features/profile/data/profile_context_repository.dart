import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:lazurite/core/network/constellation_client.dart';

class ProfileContextRepository {
  ProfileContextRepository({required dynamic bluesky, required ConstellationClient constellationClient})
    : _bluesky = bluesky,
      _constellation = constellationClient;

  final dynamic _bluesky;
  final ConstellationClient _constellation;

  /// Returns the number of accounts that have blocked [did].
  Future<int> getBlockedByCount(String did) async {
    return _constellation.getBacklinksCount(did, 'app.bsky.graph.block:subject');
  }

  /// Returns a page of profiles that have blocked [did], along with the total
  /// count and a cursor for the next page.
  Future<({List<ProfileView> profiles, String? cursor, int total})> getBlockedByProfiles(
    String did, {
    String? cursor,
  }) async {
    final result = await _constellation.getDistinct(
      did,
      'app.bsky.graph.block:subject',
      cursor: cursor,
    );
    final profiles = await _hydrateProfiles(result.dids);
    return (profiles: profiles, cursor: result.cursor, total: result.total);
  }

  /// Returns a page of profiles that [did] is blocking, along with a cursor.
  /// Uses `com.atproto.repo.listRecords` on the actor's own repo.
  /// [total] reflects the number of profiles hydrated in this page.
  Future<({List<ProfileView> profiles, String? cursor, int total})> getBlockingProfiles(
    String did, {
    String? cursor,
  }) async {
    final response = await _bluesky.atproto.repo.listRecords(
      repo: did,
      collection: 'app.bsky.graph.block',
      limit: 50,
      cursor: cursor,
    );

    final subjectDids = (response.data.records as List<dynamic>)
        .map((r) => r.value['subject'] as String)
        .toList();
    final profiles = await _hydrateProfiles(subjectDids);
    return (profiles: profiles, cursor: response.data.cursor as String?, total: profiles.length);
  }

  /// Returns a page of lists that [did] is a member of, along with the total
  /// count and a cursor for the next page.
  Future<({List<ListView> lists, String? cursor, int total})> getListsOn(String did, {String? cursor}) async {
    final total = await _constellation.getBacklinksCount(did, 'app.bsky.graph.listitem:subject');
    final result = await _constellation.getManyToMany(
      did,
      'app.bsky.graph.listitem:subject',
      'list',
      cursor: cursor,
    );

    final lists = await Future.wait(
      result.items.map((item) async {
        final uri = AtUri.parse(item.otherSubject);
        final response = await _bluesky.graph.getList(list: uri, limit: 1);
        return response.data.list as ListView;
      }),
    );

    return (lists: lists, cursor: result.cursor, total: total);
  }

  /// Hydrates [dids] into [ProfileView] objects in batches of 25.
  Future<List<ProfileView>> _hydrateProfiles(List<String> dids) async {
    if (dids.isEmpty) return [];
    final allProfiles = <ProfileView>[];
    for (var i = 0; i < dids.length; i += 25) {
      final batch = dids.sublist(i, (i + 25).clamp(0, dids.length));
      final response = await _bluesky.actor.getProfiles(actors: batch);
      allProfiles.addAll(response.data.profiles as List<ProfileView>);
    }
    return allProfiles;
  }
}
