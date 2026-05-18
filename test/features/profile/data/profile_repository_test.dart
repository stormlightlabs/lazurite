import 'dart:convert';
import 'dart:typed_data';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/get_profiles.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_followers.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_follows.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_known_followers.dart';
import 'package:bluesky_poptart/app/bsky/graph/get_suggested_follows_by_actor.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart' show Bluesky;
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:poptart_core/poptart_core.dart' as atp_core;
import 'package:poptart_lex/com/atproto/repo/get_record.dart';
import 'package:poptart_lex/com/atproto/repo/put_record.dart';
import 'package:poptart_lex/com/atproto/repo/upload_blob.dart';

import '../../../helpers/test_bluesky_client.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('ProfileRepository', () {
    group('getSuggestedFollows', () {
      test('returns suggestions from graph service', () async {
        final suggestions = [
          ProfileView(did: 'did:plc:bob', handle: 'bob.bsky.social', indexedAt: DateTime.utc(2026)),
          ProfileView(did: 'did:plc:carol', handle: 'carol.bsky.social', indexedAt: DateTime.utc(2026)),
        ];
        final repository = ProfileRepository(
          database: database,
          bluesky: _testBlueskyClient(
            actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
            graph: _FakeGraphService(suggestions: suggestions),
          ),
        );

        final result = await repository.getSuggestedFollows('did:plc:alice');

        expect(result.length, 2);
        expect(result.first.did, 'did:plc:bob');
      });

      test('returns empty list when no suggestions', () async {
        final repository = ProfileRepository(
          database: database,
          bluesky: _testBlueskyClient(
            actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
            graph: _FakeGraphService(suggestions: []),
          ),
        );

        final result = await repository.getSuggestedFollows('did:plc:alice');

        expect(result, isEmpty);
      });

      test('propagates exceptions from graph service', () async {
        final repository = ProfileRepository(
          database: database,
          bluesky: _testBlueskyClient(
            actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
            graph: _FakeGraphService(onGetSuggested: (_) async => throw Exception('network error')),
          ),
        );

        expect(() => repository.getSuggestedFollows('did:plc:alice'), throwsException);
      });
    });

    group('connections', () {
      test('returns following page from graph service', () async {
        const subject = ProfileView(did: 'did:plc:alice', handle: 'alice.bsky.social');
        const follows = [
          ProfileView(did: 'did:plc:bob', handle: 'bob.bsky.social'),
          ProfileView(did: 'did:plc:carol', handle: 'carol.bsky.social'),
        ];
        final repository = ProfileRepository(
          database: database,
          bluesky: _testBlueskyClient(
            actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
            graph: _FakeGraphService(follows: follows, followsSubject: subject, followsCursor: 'next'),
          ),
        );

        final result = await repository.getFollowing(actor: subject.did, limit: 25);

        expect(result.subject, subject);
        expect(result.profiles, follows);
        expect(result.cursor, 'next');
      });

      test('returns followers page from graph service', () async {
        const subject = ProfileView(did: 'did:plc:alice', handle: 'alice.bsky.social');
        const followers = [ProfileView(did: 'did:plc:dana', handle: 'dana.bsky.social')];
        final repository = ProfileRepository(
          database: database,
          bluesky: _testBlueskyClient(
            actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
            graph: _FakeGraphService(followers: followers, followersSubject: subject),
          ),
        );

        final result = await repository.getFollowers(actor: subject.did, cursor: 'cursor');

        expect(result.subject, subject);
        expect(result.profiles, followers);
        expect(result.cursor, isNull);
      });

      test('returns known followers page from graph service', () async {
        const subject = ProfileView(did: 'did:plc:alice', handle: 'alice.bsky.social');
        const followers = [ProfileView(did: 'did:plc:erin', handle: 'erin.bsky.social')];
        final repository = ProfileRepository(
          database: database,
          bluesky: _testBlueskyClient(
            actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
            graph: _FakeGraphService(
              knownFollowers: followers,
              knownFollowersSubject: subject,
              knownFollowersCursor: 'more',
            ),
          ),
        );

        final result = await repository.getKnownFollowers(actor: subject.did, cursor: 'cursor');

        expect(result.subject, subject);
        expect(result.profiles, followers);
        expect(result.cursor, 'more');
      });
    });

    test('loads and caches a profile after a successful xrpc response', () async {
      final profile = _buildProfile();
      final repository = ProfileRepository(
        database: database,
        bluesky: _testBlueskyClient(actor: _FakeActorService(onGetProfile: (_) async => _FakeResponse(profile))),
      );

      final result = await repository.getProfile(profile.did);

      expect(result.did, profile.did);
      expect(result.handle, profile.handle);

      final cached = await database.select(database.cachedProfiles).getSingle();
      expect(cached.did, profile.did);
      expect(cached.handle, profile.handle);
    });

    test('refreshes and retries getProfile after unauthorized response', () async {
      final profile = _buildProfile();
      final initialActor = _FakeActorService(onGetProfile: (_) async => throw _unauthorizedException());
      final refreshedActor = _FakeActorService(onGetProfile: (_) async => _FakeResponse(profile));
      final initialClient = _testBlueskyClient(actor: initialActor);
      final refreshedClient = _testBlueskyClient(actor: refreshedActor);
      var recoveryCalls = 0;

      final repository = ProfileRepository(
        database: database,
        bluesky: initialClient,
        onUnauthorized: () async {
          recoveryCalls += 1;
          return const AuthTokens(
            accessToken: 'fresh-access',
            refreshToken: 'fresh-refresh',
            did: 'did:plc:alice',
            handle: 'alice.bsky.social',
          );
        },
        blueskyClientFactory: (_) => refreshedClient,
      );

      final result = await repository.getProfile(profile.did);

      expect(result.did, profile.did);
      expect(recoveryCalls, 1);
      expect(initialActor.getProfileCalls, 1);
      expect(refreshedActor.getProfileCalls, 1);
    });

    test('falls back to the cached profile when the xrpc request fails', () async {
      final profile = _buildProfile();
      await database.cacheProfile(did: profile.did, handle: profile.handle, payload: jsonEncode(profile.toJson()));

      final repository = ProfileRepository(
        database: database,
        bluesky: _testBlueskyClient(
          actor: _FakeActorService(onGetProfile: (_) async => throw Exception('request failed')),
        ),
      );

      final result = await repository.getProfile(profile.handle);

      expect(result.did, profile.did);
      expect(result.handle, profile.handle);
      expect(result.displayName, profile.displayName);
    });

    test('returns fresh network profile even when cache write fails', () async {
      final profile = _buildProfile();
      final repository = ProfileRepository(
        database: database,
        bluesky: _testBlueskyClient(actor: _FakeActorService(onGetProfile: (_) async => _FakeResponse(profile))),
      );

      await database.close();

      final result = await repository.getProfile(profile.did);
      expect(result.did, profile.did);
      expect(result.followersCount, profile.followersCount);
    });

    test('paginates getProfiles requests in batches of 25 actors', () async {
      final requestedBatches = <List<String>>[];
      final actors = List<String>.generate(26, (index) => 'did:plc:actor$index');
      final repository = ProfileRepository(
        database: database,
        bluesky: _testBlueskyClient(
          actor: _FakeActorService(
            onGetProfile: (_) async => throw UnimplementedError(),
            onGetProfiles: (batch) async {
              requestedBatches.add(List<String>.from(batch));
              final profiles = batch
                  .map(
                    (did) => ProfileViewDetailed(did: did, handle: '$did.bsky.social', indexedAt: DateTime.utc(2026)),
                  )
                  .toList(growable: false);
              return _FakeProfilesResponse(_FakeProfilesData(profiles));
            },
          ),
        ),
      );

      final profiles = await repository.getProfiles(actors);

      expect(requestedBatches.length, 2);
      expect(requestedBatches[0].length, 25);
      expect(requestedBatches[1].length, 1);
      expect(profiles.length, 26);
      expect(profiles.map((p) => p.did), orderedEquals(actors));
    });

    test('updates editable profile fields while preserving existing record fields', () async {
      final repo = _FakeRepoService(
        record: {
          r'$type': 'app.bsky.actor.profile',
          'displayName': 'Old Name',
          'description': 'Old description',
          'labels': {r'$type': 'com.atproto.label.defs#selfLabels', 'values': []},
          'createdAt': '2026-01-01T00:00:00.000Z',
          'futureProfileField': {'enabled': true},
        },
        cid: 'bafy-current',
      );
      final repository = ProfileRepository(
        database: database,
        bluesky: _testBlueskyClient(
          actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
          atproto: _FakeAtprotoService(repo: repo),
        ),
      );

      await repository.updateProfile(
        did: 'did:plc:alice',
        draft: const ProfileEditDraft(
          displayName: 'Alice Updated',
          description: 'New description',
          pronouns: 'she/her',
          website: 'https://alice.example',
        ),
      );

      expect(repo.putRecords, hasLength(1));
      final put = repo.putRecords.single;
      expect(put.repo, 'did:plc:alice');
      expect(put.collection, 'app.bsky.actor.profile');
      expect(put.rkey, 'self');
      expect(put.validate, isTrue);
      expect(put.swapRecord, 'bafy-current');
      expect(put.record['displayName'], 'Alice Updated');
      expect(put.record['description'], 'New description');
      expect(put.record['pronouns'], 'she/her');
      expect(put.record['website'], 'https://alice.example');
      expect(put.record['labels'], isA<Map>());
      expect(put.record['createdAt'], '2026-01-01T00:00:00.000Z');
      expect(put.record['futureProfileField'], {'enabled': true});
      expect(put.record.containsKey(r'$unknown'), isFalse);
    });

    test('removes emptied optional text fields and uploads selected profile images', () async {
      final repo = _FakeRepoService(
        record: {
          r'$type': 'app.bsky.actor.profile',
          'displayName': 'Old Name',
          'description': 'Old description',
          'pronouns': 'they/them',
          'website': 'https://old.example',
          'avatar': {
            r'$type': 'blob',
            'mimeType': 'image/jpeg',
            'size': 4,
            'ref': {r'$link': 'old-avatar'},
          },
        },
        cid: 'bafy-current',
      );
      final repository = ProfileRepository(
        database: database,
        bluesky: _testBlueskyClient(
          actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
          atproto: _FakeAtprotoService(repo: repo),
        ),
      );

      await repository.updateProfile(
        did: 'did:plc:alice',
        draft: const ProfileEditDraft(
          displayName: '',
          description: '',
          pronouns: '',
          website: '',
          avatar: ProfileImageUpload(bytes: [1, 2, 3], mimeType: 'image/png'),
          banner: ProfileImageUpload(bytes: [4, 5], mimeType: 'image/jpeg'),
        ),
      );

      final record = repo.putRecords.single.record;
      expect(record.containsKey('displayName'), isFalse);
      expect(record.containsKey('description'), isFalse);
      expect(record.containsKey('pronouns'), isFalse);
      expect(record.containsKey('website'), isFalse);
      expect((record['avatar'] as Map)['mimeType'], 'image/png');
      expect(((record['avatar'] as Map)['ref'] as Map)[r'$link'], 'uploaded-1');
      expect((record['banner'] as Map)['mimeType'], 'image/jpeg');
      expect(((record['banner'] as Map)['ref'] as Map)[r'$link'], 'uploaded-2');
      expect(repo.uploadContentTypes, ['image/png', 'image/jpeg']);
    });

    test('rejects profile edit values outside the profile lexicon limits', () async {
      final repo = _FakeRepoService(record: const {r'$type': 'app.bsky.actor.profile'});
      final repository = ProfileRepository(
        database: database,
        bluesky: _testBlueskyClient(
          actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
          atproto: _FakeAtprotoService(repo: repo),
        ),
      );

      expect(
        () => repository.updateProfile(
          did: 'did:plc:alice',
          draft: ProfileEditDraft(displayName: List.filled(65, 'A').join()),
        ),
        throwsArgumentError,
      );
      expect(repo.putRecords, isEmpty);
    });
  });
}

ProfileViewDetailed _buildProfile() {
  return ProfileViewDetailed(
    did: 'did:plc:alice',
    handle: 'alice.bsky.social',
    displayName: 'Alice Example',
    description: 'Profile for repository tests',
    followersCount: 10,
    followsCount: 20,
    postsCount: 30,
    createdAt: DateTime.utc(2026, 3, 16),
  );
}

Bluesky _testBlueskyClient({required _FakeActorService actor, _FakeGraphService? graph, _FakeAtprotoService? atproto}) {
  final transport = _FakeProfileTransport(
    actor: actor,
    graph: graph ?? _FakeGraphService(),
    atproto: atproto ?? _FakeAtprotoService(repo: _FakeRepoService(record: const {})),
  );
  return testBluesky(getClient: transport.get, postClient: transport.post);
}

class _FakeProfileTransport {
  _FakeProfileTransport({required this.actor, _FakeGraphService? graph, _FakeAtprotoService? atproto})
    : graph = graph ?? _FakeGraphService(),
      atproto = atproto ?? _FakeAtprotoService(repo: _FakeRepoService(record: const {}));

  final _FakeActorService actor;
  final _FakeGraphService graph;
  final _FakeAtprotoService atproto;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final query = url.queryParameters;

    switch (url.pathSegments.last) {
      case 'app.bsky.actor.getProfile':
        final response = await actor.getProfile(actor: query['actor']!, $headers: headers);
        return jsonResponse(url, 'GET', response.data.toJson());
      case 'app.bsky.actor.getProfiles':
        final response = await actor.getProfiles(
          actors: url.queryParametersAll['actors'] ?? const [],
          $headers: headers,
        );
        return jsonResponse(url, 'GET', ActorGetProfilesOutput(profiles: response.data.profiles).toJson());
      case 'app.bsky.graph.getSuggestedFollowsByActor':
        final response = await graph.getSuggestedFollowsByActor(actor: query['actor']!, $headers: headers);
        return jsonResponse(
          url,
          'GET',
          GraphGetSuggestedFollowsByActorOutput(suggestions: response.data.suggestions).toJson(),
        );
      case 'app.bsky.graph.getFollows':
        final response = await graph.getFollows(
          actor: query['actor']!,
          cursor: query['cursor'],
          limit: int.tryParse(query['limit'] ?? ''),
          $headers: headers,
        );
        return jsonResponse(
          url,
          'GET',
          GraphGetFollowsOutput(
            subject: response.data.subject,
            follows: response.data.follows,
            cursor: response.data.cursor,
          ).toJson(),
        );
      case 'app.bsky.graph.getFollowers':
        final response = await graph.getFollowers(
          actor: query['actor']!,
          cursor: query['cursor'],
          limit: int.tryParse(query['limit'] ?? ''),
          $headers: headers,
        );
        return jsonResponse(
          url,
          'GET',
          GraphGetFollowersOutput(
            subject: response.data.subject,
            followers: response.data.followers,
            cursor: response.data.cursor,
          ).toJson(),
        );
      case 'app.bsky.graph.getKnownFollowers':
        final response = await graph.getKnownFollowers(
          actor: query['actor']!,
          cursor: query['cursor'],
          limit: int.tryParse(query['limit'] ?? ''),
          $headers: headers,
        );
        return jsonResponse(
          url,
          'GET',
          GraphGetKnownFollowersOutput(
            subject: response.data.subject,
            followers: response.data.followers,
            cursor: response.data.cursor,
          ).toJson(),
        );
      case 'com.atproto.repo.getRecord':
        final response = await atproto.repo.getRecord(
          repo: query['repo']!,
          collection: query['collection']!,
          rkey: query['rkey']!,
          cid: query['cid'],
          $headers: headers,
        );
        return jsonResponse(
          url,
          'GET',
          RepoGetRecordOutput(
            uri: atp_core.AtUri.parse('at://${query['repo']}/${query['collection']}/${query['rkey']}'),
            cid: response.data.cid,
            value: response.data.value,
          ).toJson(),
        );
      default:
        return unexpectedGetClient(url, headers: headers);
    }
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    switch (url.pathSegments.last) {
      case 'com.atproto.repo.putRecord':
        final input = RepoPutRecordInput.fromJson((jsonDecode(body as String) as Map).cast<String, Object?>());
        await atproto.repo.putRecord(
          repo: input.repo,
          collection: input.collection,
          rkey: input.rkey,
          validate: input.validate,
          record: input.record,
          swapRecord: input.swapRecord,
          swapCommit: input.swapCommit,
          $headers: headers,
        );
        return jsonResponse(
          url,
          'POST',
          RepoPutRecordOutput(
            uri: atp_core.AtUri.parse('at://${input.repo}/${input.collection}/${input.rkey}'),
            cid: 'cid-put',
          ).toJson(),
        );
      case 'com.atproto.repo.uploadBlob':
        final bytes = Uint8List.fromList((body as List<int>?) ?? const []);
        final response = await atproto.repo.uploadBlob(bytes: bytes, $headers: headers);
        return jsonResponse(url, 'POST', RepoUploadBlobOutput(blob: response.data.blob).toJson());
      default:
        return unexpectedPostClient(url, headers: headers, body: body, encoding: encoding);
    }
  }
}

class _FakeActorService {
  _FakeActorService({required this.onGetProfile, this.onGetProfiles});

  final Future<_FakeResponse<ProfileViewDetailed>> Function(String actor) onGetProfile;
  final Future<_FakeProfilesResponse> Function(List<String> actors)? onGetProfiles;
  int getProfileCalls = 0;

  Future<_FakeResponse<ProfileViewDetailed>> getProfile({required String actor, Map<String, String>? $headers}) {
    getProfileCalls += 1;
    return onGetProfile(actor);
  }

  Future<_FakeProfilesResponse> getProfiles({required List<String> actors, Map<String, String>? $headers}) async {
    final handler = onGetProfiles;
    if (handler != null) {
      return handler(actors);
    }
    return _FakeProfilesResponse(const _FakeProfilesData([]));
  }
}

class _FakeResponse<T> {
  _FakeResponse(this.data);

  final T data;
}

class _FakeProfilesResponse {
  _FakeProfilesResponse(this.data);

  final _FakeProfilesData data;
}

class _FakeProfilesData {
  const _FakeProfilesData(this.profiles);

  final List<ProfileViewDetailed> profiles;
}

class _FakeAtprotoService {
  const _FakeAtprotoService({required this.repo});

  final _FakeRepoService repo;
}

class _FakeRepoService {
  _FakeRepoService({required Map<String, dynamic> record, this.cid = 'bafy-record'}) : _record = record;

  final Map<String, dynamic> _record;
  final String? cid;
  final putRecords = <_FakePutRecordCall>[];
  final uploadContentTypes = <String>[];

  Future<_FakeResponse<_FakeGetRecordData>> getRecord({
    required String repo,
    required String collection,
    required String rkey,
    String? cid,
    String? $service,
    Map<String, String>? $headers,
    Map<String, String>? $unknown,
  }) async {
    return _FakeResponse(_FakeGetRecordData(value: _record, cid: this.cid));
  }

  Future<_FakeResponse<_FakePutRecordData>> putRecord({
    required String repo,
    required String collection,
    required String rkey,
    bool? validate,
    required Map<String, dynamic> record,
    String? swapRecord,
    String? swapCommit,
    String? $service,
    Map<String, String>? $headers,
    Map<String, String>? $unknown,
  }) async {
    putRecords.add(
      _FakePutRecordCall(
        repo: repo,
        collection: collection,
        rkey: rkey,
        validate: validate,
        record: Map<String, dynamic>.from(record),
        swapRecord: swapRecord,
      ),
    );
    return _FakeResponse(const _FakePutRecordData());
  }

  Future<_FakeResponse<_FakeUploadBlobData>> uploadBlob({
    required Uint8List bytes,
    String? $service,
    Map<String, String>? $headers,
    Map<String, String>? $parameters,
  }) async {
    final contentType = $headers?['Content-Type'] ?? 'image/jpeg';
    uploadContentTypes.add(contentType);
    return _FakeResponse(
      _FakeUploadBlobData(
        atp_core.Blob(
          mimeType: contentType,
          size: bytes.length,
          ref: atp_core.BlobRef(link: 'uploaded-${uploadContentTypes.length}'),
        ),
      ),
    );
  }
}

class _FakeGetRecordData {
  const _FakeGetRecordData({required this.value, this.cid});

  final Map<String, dynamic> value;
  final String? cid;
}

class _FakePutRecordData {
  const _FakePutRecordData();
}

class _FakeUploadBlobData {
  const _FakeUploadBlobData(this.blob);

  final atp_core.Blob blob;
}

class _FakePutRecordCall {
  const _FakePutRecordCall({
    required this.repo,
    required this.collection,
    required this.rkey,
    required this.validate,
    required this.record,
    required this.swapRecord,
  });

  final String repo;
  final String collection;
  final String rkey;
  final bool? validate;
  final Map<String, dynamic> record;
  final String? swapRecord;
}

class _FakeGraphService {
  _FakeGraphService({
    List<ProfileView>? suggestions,
    Future<_FakeSuggestedResponse> Function(String actor)? onGetSuggested,
    List<ProfileView>? follows,
    ProfileView? followsSubject,
    String? followsCursor,
    List<ProfileView>? followers,
    ProfileView? followersSubject,
    String? followersCursor,
    List<ProfileView>? knownFollowers,
    ProfileView? knownFollowersSubject,
    String? knownFollowersCursor,
  }) : _suggestions = suggestions ?? [],
       _onGetSuggested = onGetSuggested,
       _follows = follows ?? [],
       _followsSubject = followsSubject,
       _followsCursor = followsCursor,
       _followers = followers ?? [],
       _followersSubject = followersSubject,
       _followersCursor = followersCursor,
       _knownFollowers = knownFollowers ?? [],
       _knownFollowersSubject = knownFollowersSubject,
       _knownFollowersCursor = knownFollowersCursor;

  final List<ProfileView> _suggestions;
  final Future<_FakeSuggestedResponse> Function(String actor)? _onGetSuggested;
  final List<ProfileView> _follows;
  final ProfileView? _followsSubject;
  final String? _followsCursor;
  final List<ProfileView> _followers;
  final ProfileView? _followersSubject;
  final String? _followersCursor;
  final List<ProfileView> _knownFollowers;
  final ProfileView? _knownFollowersSubject;
  final String? _knownFollowersCursor;

  Future<_FakeSuggestedResponse> getSuggestedFollowsByActor({required String actor, Map<String, String>? $headers}) {
    final handler = _onGetSuggested;
    if (handler != null) return handler(actor);
    return Future.value(_FakeSuggestedResponse(_FakeSuggestedData(_suggestions)));
  }

  Future<_FakeFollowsResponse> getFollows({
    required String actor,
    String? cursor,
    int? limit,
    Map<String, String>? $headers,
  }) {
    return Future.value(
      _FakeFollowsResponse(
        _FakeFollowsData(_followsSubject ?? ProfileView(did: actor, handle: actor), _follows, _followsCursor),
      ),
    );
  }

  Future<_FakeFollowersResponse> getFollowers({
    required String actor,
    String? cursor,
    int? limit,
    Map<String, String>? $headers,
  }) {
    return Future.value(
      _FakeFollowersResponse(
        _FakeFollowersData(_followersSubject ?? ProfileView(did: actor, handle: actor), _followers, _followersCursor),
      ),
    );
  }

  Future<_FakeFollowersResponse> getKnownFollowers({
    required String actor,
    String? cursor,
    int? limit,
    Map<String, String>? $headers,
  }) {
    return Future.value(
      _FakeFollowersResponse(
        _FakeFollowersData(
          _knownFollowersSubject ?? ProfileView(did: actor, handle: actor),
          _knownFollowers,
          _knownFollowersCursor,
        ),
      ),
    );
  }
}

class _FakeSuggestedResponse {
  _FakeSuggestedResponse(this.data);

  final _FakeSuggestedData data;
}

class _FakeSuggestedData {
  const _FakeSuggestedData(this.suggestions);

  final List<ProfileView> suggestions;
}

class _FakeFollowsResponse {
  _FakeFollowsResponse(this.data);

  final _FakeFollowsData data;
}

class _FakeFollowsData {
  const _FakeFollowsData(this.subject, this.follows, this.cursor);

  final ProfileView subject;
  final List<ProfileView> follows;
  final String? cursor;
}

class _FakeFollowersResponse {
  _FakeFollowersResponse(this.data);

  final _FakeFollowersData data;
}

class _FakeFollowersData {
  const _FakeFollowersData(this.subject, this.followers, this.cursor);

  final ProfileView subject;
  final List<ProfileView> followers;
  final String? cursor;
}

atp_core.UnauthorizedException _unauthorizedException() {
  return atp_core.UnauthorizedException(
    atp_core.XRPCResponse<atp_core.XRPCError>(
      headers: const {},
      status: atp_core.HttpStatus.unauthorized,
      request: atp_core.XRPCRequest(
        method: atp_core.HttpMethod.get,
        url: Uri.parse('https://example.com/xrpc/app.bsky.actor.getProfile'),
      ),
      rateLimit: atp_core.RateLimit.unlimited(),
      data: const atp_core.XRPCError(error: 'Unauthorized', message: '"exp" claim timestamp check failed'),
    ),
  );
}
