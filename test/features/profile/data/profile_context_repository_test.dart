import 'dart:convert';

import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/get_profiles.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_list.dart';
import 'package:poptart_lex/com/atproto/repo/list_records.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart' show Bluesky;
import 'package:lazurite/features/profile/data/profile_context_repository.dart';

import '../../../helpers/test_bluesky_client.dart';

ProfileView _buildProfileView(String did, String handle) {
  return ProfileView(did: did, handle: handle, indexedAt: DateTime.utc(2026, 1, 1));
}

ProfileViewDetailed _buildProfileViewDetailed(String did, String handle) {
  return ProfileViewDetailed(
    did: did,
    handle: handle,
    displayName: 'Detailed $did',
    description: 'Bio for $did',
    indexedAt: DateTime.utc(2026, 1, 1),
  );
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

Bluesky _fakeBluesky({required dynamic actor, required dynamic graph, required dynamic atproto}) {
  final transport = _ProfileContextTransport(actor: actor, graph: graph, atproto: atproto);
  return testBluesky(did: 'did:plc:actor', handle: 'actor.bsky.social', getClient: transport.get);
}

class _ProfileContextTransport {
  const _ProfileContextTransport({required this.actor, required this.graph, required this.atproto});

  final dynamic actor;
  final dynamic graph;
  final dynamic atproto;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final query = url.queryParameters;
    switch (url.pathSegments.last) {
      case 'app.bsky.actor.getProfiles':
        final response = await actor.getProfiles(
          actors: url.queryParametersAll['actors'] ?? const [],
          $service: url.host,
          $headers: headers,
        );
        return jsonResponse(
          url,
          'GET',
          ActorGetProfilesOutput(
            profiles: response.data.profiles.map<ProfileViewDetailed>(_toDetailedProfile).toList(growable: false),
          ).toJson(),
        );
      case 'app.bsky.actor.getProfile':
        final response = await actor.getProfile(actor: query['actor']!, $service: url.host, $headers: headers);
        return jsonResponse(url, 'GET', _toDetailedProfile(response.data).toJson());
      case 'app.bsky.graph.getList':
        final response = await graph.getList(list: AtUri.parse(query['list']!), $service: url.host, $headers: headers);
        return jsonResponse(url, 'GET', GraphGetListOutput(list: response.data.list, items: const []).toJson());
      case 'com.atproto.repo.listRecords':
        final response = await atproto.repo.listRecords(
          repo: query['repo']!,
          collection: query['collection']!,
          limit: int.tryParse(query['limit'] ?? '') ?? 50,
          cursor: query['cursor'],
        );
        return jsonResponse(
          url,
          'GET',
          RepoListRecordsOutput(
            records: [
              for (var i = 0; i < response.data.records.length; i++)
                RepoListRecordsRecord(
                  uri: AtUri.parse('at://${query['repo']}/${query['collection']}/$i'),
                  cid: 'cid-$i',
                  value: _recordValue(response.data.records[i].value),
                ),
            ],
            cursor: response.data.cursor,
          ).toJson(),
        );
      default:
        return unexpectedGetClient(url, headers: headers);
    }
  }
}

ProfileViewDetailed _toDetailedProfile(dynamic profile) {
  if (profile is ProfileViewDetailed) {
    return profile;
  }

  if (profile is ProfileView) {
    return ProfileViewDetailed(
      did: profile.did,
      handle: profile.handle,
      displayName: profile.displayName,
      description: profile.description,
      avatar: profile.avatar,
      associated: profile.associated,
      indexedAt: profile.indexedAt,
      createdAt: profile.createdAt,
      viewer: profile.viewer,
      labels: profile.labels,
      verification: profile.verification,
      status: profile.status,
      debug: profile.debug,
    );
  }

  throw ArgumentError.value(profile, 'profile', 'Expected ProfileView or ProfileViewDetailed');
}

Map<String, dynamic> _recordValue(Map<String, dynamic> value) {
  if (value.containsKey(r'$type')) {
    return value;
  }
  if (value.containsKey('subject') && value['subject'] is String) {
    return {r'$type': 'app.bsky.graph.block', 'createdAt': '2026-01-01T00:00:00.000Z', ...value};
  }
  return value;
}

class _FakeAtProto {
  _FakeAtProto({required this.repo});

  final dynamic repo;
}

class _FakeActorService {
  _FakeActorService({required this.profiles, Map<String, dynamic>? profileByActor, Map<String, Object>? errorsByActor})
    : _profileByActor = profileByActor ?? const {},
      _errorsByActor = errorsByActor ?? const {};

  final List<dynamic> profiles;
  final Map<String, dynamic> _profileByActor;
  final Map<String, Object> _errorsByActor;

  Future<_FakeResponse<_FakeProfilesOutput>> getProfiles({
    required List<String> actors,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    final matched = profiles.where((p) => actors.contains(p.did) || actors.contains(p.handle)).toList();
    return _FakeResponse(_FakeProfilesOutput(matched));
  }

  Future<_FakeResponse<dynamic>> getProfile({
    required String actor,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    final error = _errorsByActor[actor];
    if (error != null) throw error;
    final profile = _profileByActor[actor];
    if (profile == null) throw Exception('Profile not found: $actor');
    return _FakeResponse(profile);
  }
}

class _ThrowingActorService {
  Future<_FakeResponse<_FakeProfilesOutput>> getProfiles({
    required List<String> actors,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    throw Exception('Authenticated actor client should not be used for public profile hydration');
  }

  Future<_FakeResponse<dynamic>> getProfile({
    required String actor,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    throw Exception('Authenticated actor client should not be used for public profile hydration');
  }
}

class _BatchThrowingActorService {
  _BatchThrowingActorService({required Map<String, dynamic> profileByActor}) : _profileByActor = profileByActor;

  final Map<String, dynamic> _profileByActor;

  Future<_FakeResponse<_FakeProfilesOutput>> getProfiles({
    required List<String> actors,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    throw Exception('Batch lookup failed');
  }

  Future<_FakeResponse<dynamic>> getProfile({
    required String actor,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    final profile = _profileByActor[actor];
    if (profile == null) throw Exception('Profile not found: $actor');
    return _FakeResponse(profile);
  }
}

class _FakeProfilesOutput {
  _FakeProfilesOutput(this.profiles);

  final List<dynamic> profiles;
}

class _FakeGraphService {
  _FakeGraphService({this.lists = const {}});

  final Map<String, ListView> lists;

  Future<_FakeResponse<_FakeGetListOutput>> getList({
    required AtUri list,
    int limit = 50,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    final listView = lists[list.toString()];
    if (listView == null) throw Exception('List not found: $list');
    return _FakeResponse(_FakeGetListOutput(listView));
  }
}

class _ThrowingGraphService {
  Future<_FakeResponse<_FakeGetListOutput>> getList({
    required AtUri list,
    int limit = 50,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    throw Exception('Authenticated graph client should not be used for public list hydration');
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
        expect(result.entries, hasLength(2));
        expect(result.entries.map((entry) => entry.did), containsAll(['did:plc:alice', 'did:plc:bob']));
        expect(result.entries.every((entry) => entry.isAvailable), isTrue);
        expect(result.cursor, isNull);
      });

      test('converts detailed profiles returned by getProfiles into ProfileView', () async {
        final aliceProfile = _buildProfileViewDetailed('did:plc:alice', 'alice.bsky.social');

        final constellation = _constellationWithResponses((_) {
          return {
            'total': 1,
            'dids': ['did:plc:alice'],
          };
        });

        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(profiles: [aliceProfile]),
          constellationClient: constellation,
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(result.entries, hasLength(1));
        expect(result.entries.first.profile?.did, 'did:plc:alice');
        expect(result.entries.first.profile?.handle, 'alice.bsky.social');
        expect(result.entries.first.profile?.displayName, 'Detailed did:plc:alice');
      });

      test('falls back to getProfile for DIDs missing from getProfiles', () async {
        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _ThrowingActorService(),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          publicBluesky: _fakeBluesky(
            actor: _FakeActorService(
              profiles: const [],
              profileByActor: {'did:plc:alice': _buildProfileViewDetailed('did:plc:alice', 'alice.bsky.social')},
            ),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: _constellationWithResponses((_) {
            return {
              'total': 1,
              'dids': ['did:plc:alice'],
            };
          }),
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(result.entries, hasLength(1));
        expect(result.entries.first.profile?.did, 'did:plc:alice');
        expect(result.entries.first.profile?.handle, 'alice.bsky.social');
      });

      test('falls back to per-DID getProfile when batch getProfiles fails', () async {
        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _ThrowingActorService(),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          publicBluesky: _fakeBluesky(
            actor: _BatchThrowingActorService(
              profileByActor: {'did:plc:alice': _buildProfileViewDetailed('did:plc:alice', 'alice.bsky.social')},
            ),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: _constellationWithResponses((_) {
            return {
              'total': 2,
              'dids': ['did:plc:alice', 'did:plc:suspended'],
            };
          }),
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(result.total, 2);
        expect(result.entries, hasLength(2));
        expect(result.entries.first.profile?.did, 'did:plc:alice');
        expect(result.entries.last.did, 'did:plc:suspended');
        expect(result.entries.last.unavailableReason, 'Profile unavailable');
      });

      test('uses public bluesky client for batch profile hydration', () async {
        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _ThrowingActorService(),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          publicBluesky: _fakeBluesky(
            actor: _FakeActorService(profiles: [_buildProfileViewDetailed('did:plc:alice', 'alice.bsky.social')]),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: _constellationWithResponses((_) {
            return {
              'total': 1,
              'dids': ['did:plc:alice'],
            };
          }),
        );

        await repo.getBlockedByProfiles('did:plc:target');
      });

      test('uses local offset cursor after collecting blocked-by DIDs', () async {
        var getDistinctCalls = 0;
        String? capturedLimit;
        final constellation = _constellationWithResponses((uri) {
          getDistinctCalls += 1;
          capturedLimit = uri.queryParameters['limit'];
          if (getDistinctCalls == 1) {
            expect(uri.queryParameters['cursor'], isNull);
            return {
              'total': 3,
              'dids': ['did:plc:one', 'did:plc:two'],
              'cursor': 'page2',
            };
          }
          expect(uri.queryParameters['cursor'], 'page2');
          return {
            'total': 3,
            'dids': ['did:plc:three'],
            'cursor': null,
          };
        });

        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(
            profiles: [
              _buildProfileView('did:plc:one', 'one.bsky.social'),
              _buildProfileView('did:plc:two', 'two.bsky.social'),
              _buildProfileView('did:plc:three', 'three.bsky.social'),
            ],
          ),
          constellationClient: constellation,
        );

        final result = await repo.getBlockedByProfiles('did:plc:target', cursor: '2');

        expect(getDistinctCalls, 2);
        expect(capturedLimit, '16');
        expect(result.entries.map((entry) => entry.did), ['did:plc:three']);
        expect(result.cursor, isNull);
      });

      test('falls back to getBacklinks when getDistinct returns 404', () async {
        final aliceProfile = _buildProfileViewDetailed('did:plc:alice', 'alice.bsky.social');
        final bobProfile = _buildProfileViewDetailed('did:plc:bob', 'bob.bsky.social');

        final constellation = ConstellationClient(
          httpClient: MockClient((request) async {
            if (request.url.path.contains('getDistinct')) {
              return http.Response('Not Found', 404);
            }

            if (request.url.path.contains('getBacklinks')) {
              return http.Response(
                jsonEncode({
                  'total': 3,
                  'records': [
                    {'did': 'did:plc:alice', 'collection': 'app.bsky.graph.block', 'rkey': '1'},
                    {'did': 'did:plc:bob', 'collection': 'app.bsky.graph.block', 'rkey': '2'},
                    {'did': 'did:plc:alice', 'collection': 'app.bsky.graph.block', 'rkey': '3'},
                  ],
                }),
                200,
              );
            }

            throw Exception('Unexpected endpoint: ${request.url.path}');
          }),
        );

        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(profiles: [aliceProfile, bobProfile]),
          constellationClient: constellation,
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(result.total, 3);
        expect(result.cursor, isNull);
        expect(result.entries.map((entry) => entry.did).toList(), ['did:plc:alice', 'did:plc:bob']);
      });

      test('collects blocked-by DIDs across pages before hydrating', () async {
        var getDistinctCalls = 0;
        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _ThrowingActorService(),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          publicBluesky: _fakeBluesky(
            actor: _FakeActorService(
              profiles: [_buildProfileViewDetailed('did:plc:alice', 'alice.bsky.social')],
              profileByActor: const {},
            ),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: _constellationWithResponses((uri) {
            if (!uri.path.contains('getDistinct')) {
              throw Exception('Unexpected endpoint: ${uri.path}');
            }

            getDistinctCalls += 1;
            if (getDistinctCalls == 1) {
              expect(uri.queryParameters['cursor'], isNull);
              return {
                'total': 23,
                'dids': ['did:plc:suspended'],
                'cursor': 'page-2',
              };
            }

            expect(uri.queryParameters['cursor'], 'page-2');
            return {
              'total': 23,
              'dids': ['did:plc:alice'],
              'cursor': null,
            };
          }),
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(getDistinctCalls, 2);
        expect(result.total, 23);
        expect(result.cursor, isNull);
        expect(result.entries.map((entry) => entry.did), ['did:plc:suspended', 'did:plc:alice']);
        expect(result.entries.first.unavailableReason, 'Profile unavailable');
        expect(result.entries.last.profile?.did, 'did:plc:alice');
      });

      test('hydrates profiles in batches of 25', () async {
        final dids = List.generate(30, (i) => 'did:plc:user$i');
        final profiles = dids.map((d) => _buildProfileView(d, '$d.bsky.social')).toList();

        final batchSizes = <int>[];
        final constellation = _constellationWithResponses((_) => {'total': 30, 'dids': dids});

        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _BatchTrackingActorService(profiles: profiles, batchSizes: batchSizes),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: constellation,
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(batchSizes, [25, 5]);
        expect(result.entries.length, 16);
        expect(result.cursor, '16');
      });

      test('returns empty profiles when no DIDs returned', () async {
        final constellation = _constellationWithResponses((_) => {'total': 0, 'dids': []});
        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(result.entries, isEmpty);
        expect(result.total, 0);
      });

      test('preserves blocked-by order across two local pages and marks suspended accounts inline', () async {
        const unavailableDidOne = 'did:plc:tsy5hmbt5lruc5jjaqglajtp';
        const unavailableDidTwo = 'did:plc:hcton3oag5fbmtx2r55wduei';
        final orderedDids = <String>[
          'did:plc:blocker00',
          'did:plc:blocker01',
          'did:plc:blocker02',
          'did:plc:blocker03',
          unavailableDidOne,
          'did:plc:blocker05',
          'did:plc:blocker06',
          'did:plc:blocker07',
          'did:plc:blocker08',
          'did:plc:blocker09',
          'did:plc:blocker10',
          'did:plc:blocker11',
          'did:plc:blocker12',
          'did:plc:blocker13',
          'did:plc:blocker14',
          'did:plc:blocker15',
          'did:plc:blocker16',
          'did:plc:blocker17',
          'did:plc:blocker18',
          unavailableDidTwo,
          'did:plc:blocker20',
          'did:plc:blocker21',
          'did:plc:blocker22',
        ];
        final resolvedProfiles = orderedDids
            .where((did) => did != unavailableDidOne && did != unavailableDidTwo)
            .map((did) => _buildProfileViewDetailed(did, '$did.bsky.social'))
            .toList();

        final constellation = ConstellationClient(
          httpClient: MockClient((request) async {
            if (request.url.path.contains('getDistinct')) {
              return http.Response('Not Found', 404);
            }

            if (request.url.path.contains('getBacklinks')) {
              final cursor = request.url.queryParameters['cursor'];
              final pageDids = cursor == null ? orderedDids.take(16).toList() : orderedDids.skip(16).toList();
              return http.Response(
                jsonEncode({
                  'total': 23,
                  'records': [
                    for (var i = 0; i < pageDids.length; i++)
                      {'did': pageDids[i], 'collection': 'app.bsky.graph.block', 'rkey': '${cursor ?? 'page-1'}-$i'},
                  ],
                  'cursor': cursor == null ? '190209' : null,
                }),
                200,
              );
            }

            throw Exception('Unexpected endpoint: ${request.url.path}');
          }),
        );

        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _ThrowingActorService(),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          publicBluesky: _fakeBluesky(
            actor: _FakeActorService(
              profiles: resolvedProfiles,
              errorsByActor: const {
                unavailableDidOne: ConstellationException('HTTP 400: AccountTakedown'),
                unavailableDidTwo: ConstellationException('HTTP 400: AccountTakedown'),
              },
            ),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: constellation,
        );

        final firstPage = await repo.getBlockedByProfiles('did:plc:xg2vq45muivyy3xwatcehspu');
        final secondPage = await repo.getBlockedByProfiles(
          'did:plc:xg2vq45muivyy3xwatcehspu',
          cursor: firstPage.cursor,
        );
        final allEntries = [...firstPage.entries, ...secondPage.entries];

        expect(firstPage.total, 23);
        expect(firstPage.cursor, '16');
        expect(secondPage.cursor, isNull);
        expect(allEntries, hasLength(23));
        expect(allEntries.map((entry) => entry.did).toList(), orderedDids);
        expect(allEntries.where((entry) => entry.isAvailable), hasLength(21));
        expect(allEntries.where((entry) => !entry.isAvailable).map((entry) => entry.did).toList(), [
          unavailableDidOne,
          unavailableDidTwo,
        ]);
        expect(
          allEntries
              .where((entry) => !entry.isAvailable)
              .every((entry) => entry.unavailableReason == 'Suspended account'),
          isTrue,
        );
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
          bluesky: _fakeBluesky(
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

    group('getBlockingCount', () {
      test('counts records across every listRecords page', () async {
        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _FakeActorService(profiles: []),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(
              repo: _PaginatedRepoService(
                pages: [
                  _FakeListRecordsOutput(
                    records: [
                      _FakeRecord({'subject': 'did:plc:one'}),
                      _FakeRecord({'subject': 'did:plc:two'}),
                    ],
                    cursor: 'page-2',
                  ),
                  _FakeListRecordsOutput(
                    records: [
                      _FakeRecord({'subject': 'did:plc:three'}),
                    ],
                  ),
                ],
              ),
            ),
          ),
          constellationClient: _alwaysThrowConstellation(),
        );

        final result = await repo.getBlockingCount('did:plc:actor');

        expect(result, 3);
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
          bluesky: _fakeBluesky(
            actor: _FakeActorService(profiles: const []),
            graph: _ThrowingGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          publicBluesky: _fakeBluesky(
            actor: _FakeActorService(profiles: const []),
            graph: _FakeGraphService(lists: {listUri: listView}),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
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
        String? capturedLimit;
        final constellation = _constellationWithResponses((uri) {
          if (uri.path.contains('getBacklinksCount')) return {'total': 0};
          if (uri.path.contains('getManyToMany')) {
            capturedCursor = uri.queryParameters['cursor'];
            capturedLimit = uri.queryParameters['limit'];
            return {'items': [], 'cursor': 'next-page'};
          }
          return {};
        });

        final repo = ProfileContextRepository(bluesky: _buildBluesky(), constellationClient: constellation);

        final result = await repo.getListsOn('did:plc:target', cursor: 'page1');

        expect(capturedCursor, 'page1');
        expect(capturedLimit, '16');
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
          bluesky: _fakeBluesky(
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

      test('deduplicates list URIs before hydrating metadata', () async {
        const listUri = 'at://did:plc:owner/app.bsky.graph.list/abc123';
        final listView = _buildListView(listUri, 'Test List');

        var getListCalls = 0;

        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _FakeActorService(profiles: []),
            graph: _CountingGraphService(lists: {listUri: listView}, onGetList: () => getListCalls += 1),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: _constellationWithResponses((uri) {
            if (uri.path.contains('getBacklinksCount')) return {'total': 2};
            return {
              'items': [
                {
                  'linkRecord': {'did': 'did:plc:owner', 'collection': 'app.bsky.graph.listitem', 'rkey': 'rk-1'},
                  'otherSubject': listUri,
                },
                {
                  'linkRecord': {'did': 'did:plc:owner', 'collection': 'app.bsky.graph.listitem', 'rkey': 'rk-2'},
                  'otherSubject': listUri,
                },
              ],
            };
          }),
        );

        final result = await repo.getListsOn('did:plc:target');

        expect(getListCalls, 1);
        expect(result.lists, [listView]);
      });

      test('skips lists that fail hydration instead of failing the whole page', () async {
        const goodListUri = 'at://did:plc:owner/app.bsky.graph.list/good';
        const missingListUri = 'at://did:plc:owner/app.bsky.graph.list/missing';
        final goodListView = _buildListView(goodListUri, 'Good List');

        final repo = ProfileContextRepository(
          bluesky: _buildBluesky(lists: {goodListUri: goodListView}),
          constellationClient: _constellationWithResponses((uri) {
            if (uri.path.contains('getBacklinksCount')) return {'total': 2};
            return {
              'items': [
                {
                  'linkRecord': {'did': 'did:plc:owner', 'collection': 'app.bsky.graph.listitem', 'rkey': 'good'},
                  'otherSubject': goodListUri,
                },
                {
                  'linkRecord': {'did': 'did:plc:owner', 'collection': 'app.bsky.graph.listitem', 'rkey': 'bad'},
                  'otherSubject': missingListUri,
                },
              ],
            };
          }),
        );

        final result = await repo.getListsOn('did:plc:target');

        expect(result.total, 2);
        expect(result.lists, [goodListView]);
      });
    });

    group('_hydrateProfiles normalization behavior via public APIs', () {
      test('trims and deduplicates DIDs before public hydration', () async {
        final capturedActors = <List<String>>[];
        final repo = ProfileContextRepository(
          bluesky: _fakeBluesky(
            actor: _ThrowingActorService(),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          publicBluesky: _fakeBluesky(
            actor: _BatchTrackingActorService(
              profiles: [_buildProfileView('did:plc:alice', 'alice.bsky.social')],
              batchSizes: [],
              onGetProfiles: (actors) => capturedActors.add(actors),
            ),
            graph: _FakeGraphService(),
            atproto: _FakeAtProto(repo: _FakeRepoService(records: [])),
          ),
          constellationClient: _constellationWithResponses((_) {
            return {
              'total': 3,
              'dids': [' did:plc:alice ', 'did:plc:alice', '   '],
            };
          }),
        );

        final result = await repo.getBlockedByProfiles('did:plc:target');

        expect(capturedActors, [
          ['did:plc:alice'],
        ]);
        expect(result.entries, hasLength(1));
        expect(result.entries.first.profile?.did, 'did:plc:alice');
      });
    });
  });
}

Bluesky _buildBluesky({
  List<dynamic> profiles = const [],
  Map<String, dynamic> profileByActor = const {},
  Map<String, ListView> lists = const {},
  List<Map<String, dynamic>> blockRecords = const [],
  String? blockRecordsCursor,
}) {
  return _fakeBluesky(
    actor: _FakeActorService(profiles: profiles, profileByActor: profileByActor),
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
  _BatchTrackingActorService({required this.profiles, required this.batchSizes, this.onGetProfiles});

  final List<dynamic> profiles;
  final List<int> batchSizes;
  final void Function(List<String> actors)? onGetProfiles;

  Future<_FakeResponse<_FakeProfilesOutput>> getProfiles({
    required List<String> actors,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    batchSizes.add(actors.length);
    onGetProfiles?.call(actors);
    final matched = profiles.where((p) => actors.contains(p.did as String)).toList();
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

class _PaginatedRepoService {
  _PaginatedRepoService({required this.pages});

  final List<_FakeListRecordsOutput> pages;
  var _pageIndex = 0;

  Future<_FakeResponse<_FakeListRecordsOutput>> listRecords({
    required String repo,
    required String collection,
    int limit = 50,
    String? cursor,
  }) async {
    final page = pages[_pageIndex];
    if (_pageIndex < pages.length - 1) {
      _pageIndex += 1;
    }
    return _FakeResponse(page);
  }
}

class _UriCapturingGraphService {
  _UriCapturingGraphService({required this.lists, required this.onGetList});

  final Map<String, ListView> lists;
  final void Function(AtUri) onGetList;

  Future<_FakeResponse<_FakeGetListOutput>> getList({
    required AtUri list,
    int limit = 50,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    onGetList(list);
    final listView = lists[list.toString()];
    if (listView == null) throw Exception('List not found: $list');
    return _FakeResponse(_FakeGetListOutput(listView));
  }
}

class _CountingGraphService {
  _CountingGraphService({required this.lists, required this.onGetList});

  final Map<String, ListView> lists;
  final void Function() onGetList;

  Future<_FakeResponse<_FakeGetListOutput>> getList({
    required AtUri list,
    int limit = 50,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    onGetList();
    final listView = lists[list.toString()];
    if (listView == null) throw Exception('List not found: $list');
    return _FakeResponse(_FakeGetListOutput(listView));
  }
}
