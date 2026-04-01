import 'dart:convert';

import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/features/profile/data/profile_context_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProfileView _buildProfileView(String did, String handle) {
  return ProfileView(did: did, handle: handle, indexedAt: DateTime.utc(2026, 1, 1));
}

ListView _buildListView(String uriStr, String name) {
  return ListView(
    uri: AtUri.parse(uriStr),
    cid: 'cid-$name',
    creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    name: name,
    purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsCuratelist),
    indexedAt: DateTime.utc(2026, 1, 1),
  );
}

ConstellationClient _constellationWithResponses(Map<String, dynamic> Function(Uri) handler) {
  return ConstellationClient(
    httpClient: MockClient((request) async {
      final body = handler(request.url);
      return http.Response(jsonEncode(body), 200);
    }),
  );
}

class _FakeBluesky {
  _FakeBluesky({required this.actor, required this.graph, required this.atproto});

  final dynamic actor;
  final dynamic graph;
  final dynamic atproto;
}

class _FakeAtProto {
  _FakeAtProto({required this.repo});

  final dynamic repo;
}

class _FakeActorService {
  _FakeActorService({required this.profiles});

  final List<ProfileView> profiles;

  Future<_FakeResponse<_FakeProfilesOutput>> getProfiles({
    required List<String> actors,
    Map<String, String>? $headers,
  }) async {
    final matched = profiles.where((p) => actors.contains(p.did) || actors.contains(p.handle)).toList();
    return _FakeResponse(_FakeProfilesOutput(matched));
  }
}

class _FakeProfilesOutput {
  _FakeProfilesOutput(this.profiles);

  final List<ProfileView> profiles;
}

class _FakeGraphService {
  _FakeGraphService({this.lists = const {}});

  final Map<String, ListView> lists;

  Future<_FakeResponse<_FakeGetListOutput>> getList({
    required AtUri list,
    int limit = 50,
    Map<String, String>? $headers,
  }) async {
    final listView = lists[list.toString()];
    if (listView == null) throw Exception('List not found: $list');
    return _FakeResponse(_FakeGetListOutput(listView));
  }
}

class _FakeGetListOutput {
  _FakeGetListOutput(this.list);

  final ListView list;
}

/// A lightweight stand-in for [RepoListRecordsRecord] with a .value map.
class _FakeRecord {
  _FakeRecord(this.value);

  final Map<String, dynamic> value;
}

class _FakeRepoService {
  _FakeRepoService({required this.records, this.cursor});

  /// Each entry is a raw map like `{'value': {'subject': 'did:plc:x'}}`.
  final List<Map<String, dynamic>> records;
  final String? cursor;

  Future<_FakeResponse<_FakeListRecordsOutput>> listRecords({
    required String repo,
    required String collection,
    int limit = 50,
    String? cursor,
  }) async {
    final fakeRecords = records.map((r) => _FakeRecord(r['value'] as Map<String, dynamic>)).toList();
    return _FakeResponse(_FakeListRecordsOutput(records: fakeRecords, cursor: this.cursor));
  }
}

class _FakeListRecordsOutput {
  _FakeListRecordsOutput({required this.records, this.cursor});

  final List<_FakeRecord> records;
  final String? cursor;
}

class _FakeResponse<T> {
  _FakeResponse(this.data);

  final T data;
}

void main() {
  group('ProfileContextRepository', () {
    group('getBlockedByCount', () {
      test('returns total from constellation getBacklinksCount', () async {
        final constellation = _constellationWithResponses((uri) {
          expect(uri.path, contains('getBacklinksCount'));
          expect(uri.queryParameters['subject'], 'did:plc:alice');
          expect(uri.queryParameters['source'], 'app.bsky.graph.block:subject');
          return {'total': 42};
        });

        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final count = await repo.getBlockedByCount('did:plc:alice');

        expect(count, 42);
      });

      test('returns 0 when no blocks found', () async {
        final constellation = _constellationWithResponses((_) => {'total': 0});
        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        expect(await repo.getBlockedByCount('did:plc:nobody'), 0);
      });
    });

    group('getBlockedByProfiles', () {
      test('hydrates DIDs returned by getDistinct', () async {
        final aliceProfile = _buildProfileView('did:plc:alice', 'alice.bsky.social');
        final bobProfile = _buildProfileView('did:plc:bob', 'bob.bsky.social');

        final constellation = _constellationWithResponses((uri) {
          expect(uri.path, contains('getDistinct'));
          return {
            'total': 2,
            'dids': ['did:plc:alice', 'did:plc:bob'],
          };
        });

        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(profiles: [aliceProfile, bobProfile]),
          constellationClient: constellation,
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(result.total, 2);
        expect(result.profiles.length, 2);
        expect(result.profiles.map((p) => p.did), containsAll(['did:plc:alice', 'did:plc:bob']));
        expect(result.cursor, isNull);
      });

      test('passes cursor to getDistinct and returns cursor from response', () async {
        String? capturedCursor;
        final constellation = _constellationWithResponses((uri) {
          capturedCursor = uri.queryParameters['cursor'];
          return {'total': 10, 'dids': [], 'cursor': 'page2'};
        });

        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final result = await repo.getBlockedByProfiles('did:plc:target', cursor: 'page1');

        expect(capturedCursor, 'page1');
        expect(result.cursor, 'page2');
      });

      test('hydrates profiles in batches of 25', () async {
        final dids = List.generate(30, (i) => 'did:plc:user$i');
        final profiles = dids.map((d) => _buildProfileView(d, '$d.bsky.social')).toList();

        final batchSizes = <int>[];
        final constellation = _constellationWithResponses((_) => {'total': 30, 'dids': dids});

        final repo = ProfileContextRepository(
          bluesky: _FakeBluesky(
            actor: _BatchTrackingActorService(profiles: profiles, batchSizes: batchSizes),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: constellation,
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(batchSizes, [25, 5]);
        expect(result.profiles.length, 30);
      });

      test('returns empty profiles when no DIDs returned', () async {
        final constellation = _constellationWithResponses((_) => {'total': 0, 'dids': []});
        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(result.profiles, isEmpty);
        expect(result.total, 0);
      });
    });

    group('getBlockingProfiles', () {
      test('extracts subject DIDs from listRecords and hydrates', () async {
        final aliceProfile = _buildProfileView('did:plc:alice', 'alice.bsky.social');
        final blockRecords = [
          {
            'value': {'subject': 'did:plc:alice'},
          },
        ];

        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(profiles: [aliceProfile], blockRecords: blockRecords),
          constellationClient: _alwaysThrowConstellation(),
        );

        final result = await repo.getBlockingProfiles('did:plc:actor');

        expect(result.profiles.length, 1);
        expect(result.profiles.first.did, 'did:plc:alice');
        expect(result.total, 1);
      });

      test('returns empty when no block records exist', () async {
        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(blockRecords: []),
          constellationClient: _alwaysThrowConstellation(),
        );

        final result = await repo.getBlockingProfiles('did:plc:actor');

        expect(result.profiles, isEmpty);
        expect(result.total, 0);
        expect(result.cursor, isNull);
      });

      test('passes cursor to listRecords and returns cursor from response', () async {
        String? capturedCursor;
        final repo = ProfileContextRepository(
          bluesky: _FakeBluesky(
            actor: _FakeActorService(profiles: []),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(
              repo: _CursorTrackingRepoService(
                records: [],
                responseCursor: 'next-page',
                onListRecords: (cursor) => capturedCursor = cursor,
              ),
            ),
          ),
          constellationClient: _alwaysThrowConstellation(),
        );

        final result = await repo.getBlockingProfiles('did:plc:actor', cursor: 'page1');

        expect(capturedCursor, 'page1');
        expect(result.cursor, 'next-page');
      });
    });

    group('getListsOn', () {
      test('returns lists hydrated from getManyToMany results', () async {
        const listUri = 'at://did:plc:owner/app.bsky.graph.list/listkey';
        final listView = _buildListView(listUri, 'My List');

        final constellation = _constellationWithResponses((uri) {
          if (uri.path.contains('getBacklinksCount')) return {'total': 1};
          if (uri.path.contains('getManyToMany')) {
            expect(uri.queryParameters['pathToOther'], 'list');
            return {
              'items': [
                {
                  'linkRecord': {'did': 'did:plc:owner', 'collection': 'app.bsky.graph.listitem', 'rkey': 'itemrkey'},
                  'otherSubject': listUri,
                },
              ],
            };
          }
          throw Exception('Unexpected endpoint: ${uri.path}');
        });

        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(lists: {listUri: listView}),
          constellationClient: constellation,
        );

        final result = await repo.getListsOn('did:plc:target');

        expect(result.total, 1);
        expect(result.lists.length, 1);
        expect(result.lists.first.name, 'My List');
        expect(result.cursor, isNull);
      });

      test('returns total from getBacklinksCount for listitem:subject', () async {
        String? countSource;
        final constellation = _constellationWithResponses((uri) {
          if (uri.path.contains('getBacklinksCount')) {
            countSource = uri.queryParameters['source'];
            return {'total': 7};
          }
          return {'items': []};
        });

        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final result = await repo.getListsOn('did:plc:target');

        expect(countSource, 'app.bsky.graph.listitem:subject');
        expect(result.total, 7);
      });

      test('passes cursor to getManyToMany and returns response cursor', () async {
        String? capturedCursor;
        final constellation = _constellationWithResponses((uri) {
          if (uri.path.contains('getBacklinksCount')) return {'total': 0};
          if (uri.path.contains('getManyToMany')) {
            capturedCursor = uri.queryParameters['cursor'];
            return {'items': [], 'cursor': 'next-page'};
          }
          return {};
        });

        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final result = await repo.getListsOn('did:plc:target', cursor: 'page1');

        expect(capturedCursor, 'page1');
        expect(result.cursor, 'next-page');
      });

      test('returns empty lists when getManyToMany returns no items', () async {
        final constellation = _constellationWithResponses((uri) {
          if (uri.path.contains('getBacklinksCount')) return {'total': 0};
          return {'items': []};
        });

        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final result = await repo.getListsOn('did:plc:target');

        expect(result.lists, isEmpty);
      });

      test('derives list AT-URI from otherSubject and fetches list metadata', () async {
        const listUri = 'at://did:plc:owner/app.bsky.graph.list/abc123';
        final listView = _buildListView(listUri, 'Test List');

        AtUri? capturedUri;

        final repo = ProfileContextRepository(
          bluesky: _FakeBluesky(
            actor: _FakeActorService(profiles: []),
            graph: _UriCapturingGraphService(lists: {listUri: listView}, onGetList: (u) => capturedUri = u),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: _constellationWithResponses((uri) {
            if (uri.path.contains('getBacklinksCount')) return {'total': 1};
            return {
              'items': [
                {
                  'linkRecord': {'did': 'did:plc:owner', 'collection': 'app.bsky.graph.listitem', 'rkey': 'rk'},
                  'otherSubject': listUri,
                },
              ],
            };
          }),
        );

        await repo.getListsOn('did:plc:target');

        expect(capturedUri.toString(), listUri);
      });
    });
  });
}

_FakeBluesky _buildBluesky({
  List<ProfileView> profiles = const [],
  Map<String, ListView> lists = const {},
  List<Map<String, dynamic>> blockRecords = const [],
  String? blockRecordsCursor,
}) {
  return _FakeBluesky(
    actor: _FakeActorService(profiles: profiles),
    graph: _FakeGraphService(lists: lists),
    atproto: _FakeAtProto(
      repo: _FakeRepoService(records: blockRecords, cursor: blockRecordsCursor),
    ),
  );
}

ConstellationClient _alwaysThrowConstellation() {
  return ConstellationClient(
    httpClient: MockClient((_) async => throw Exception('Constellation should not be called')),
  );
}

class _BatchTrackingActorService {
  _BatchTrackingActorService({required this.profiles, required this.batchSizes});

  final List<ProfileView> profiles;
  final List<int> batchSizes;

  Future<_FakeResponse<_FakeProfilesOutput>> getProfiles({
    required List<String> actors,
    Map<String, String>? $headers,
  }) async {
    batchSizes.add(actors.length);
    final matched = profiles.where((p) => actors.contains(p.did)).toList();
    return _FakeResponse(_FakeProfilesOutput(matched));
  }
}

class _CursorTrackingRepoService {
  _CursorTrackingRepoService({
    required List<Map<String, dynamic>> records,
    required this.responseCursor,
    required this.onListRecords,
  }) : _records = records;

  final List<Map<String, dynamic>> _records;
  final String responseCursor;
  final void Function(String?) onListRecords;

  Future<_FakeResponse<_FakeListRecordsOutput>> listRecords({
    required String repo,
    required String collection,
    int limit = 50,
    String? cursor,
  }) async {
    onListRecords(cursor);
    final fakeRecords = _records.map((r) => _FakeRecord(r['value'] as Map<String, dynamic>)).toList();
    return _FakeResponse(_FakeListRecordsOutput(records: fakeRecords, cursor: responseCursor));
  }
}

class _UriCapturingGraphService {
  _UriCapturingGraphService({required this.lists, required this.onGetList});

  final Map<String, ListView> lists;
  final void Function(AtUri) onGetList;

  Future<_FakeResponse<_FakeGetListOutput>> getList({
    required AtUri list,
    int limit = 50,
    Map<String, String>? $headers,
  }) async {
    onGetList(list);
    final listView = lists[list.toString()];
    if (listView == null) throw Exception('List not found: $list');
    return _FakeResponse(_FakeGetListOutput(listView));
  }
}
