import 'dart:convert';

import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';

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
          bluesky: _FakeBlueskyClient(
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
          bluesky: _FakeBlueskyClient(
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
          bluesky: _FakeBlueskyClient(
            actor: _FakeActorService(onGetProfile: (_) async => throw UnimplementedError()),
            graph: _FakeGraphService(onGetSuggested: (_) async => throw Exception('network error')),
          ),
        );

        expect(() => repository.getSuggestedFollows('did:plc:alice'), throwsException);
      });
    });

    test('loads and caches a profile after a successful xrpc response', () async {
      final profile = _buildProfile();
      final repository = ProfileRepository(
        database: database,
        bluesky: _FakeBlueskyClient(actor: _FakeActorService(onGetProfile: (_) async => _FakeResponse(profile))),
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
      final initialClient = _FakeBlueskyClient(
        actor: _FakeActorService(onGetProfile: (_) async => throw _unauthorizedException()),
      );
      final refreshedClient = _FakeBlueskyClient(
        actor: _FakeActorService(onGetProfile: (_) async => _FakeResponse(profile)),
      );
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
      expect(initialClient.actor.getProfileCalls, 1);
      expect(refreshedClient.actor.getProfileCalls, 1);
    });

    test('falls back to the cached profile when the xrpc request fails', () async {
      final profile = _buildProfile();
      await database.cacheProfile(did: profile.did, handle: profile.handle, payload: jsonEncode(profile.toJson()));

      final repository = ProfileRepository(
        database: database,
        bluesky: _FakeBlueskyClient(
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
        bluesky: _FakeBlueskyClient(actor: _FakeActorService(onGetProfile: (_) async => _FakeResponse(profile))),
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
        bluesky: _FakeBlueskyClient(
          actor: _FakeActorService(
            onGetProfile: (_) async => throw UnimplementedError(),
            onGetProfiles: (batch) async {
              requestedBatches.add(List<String>.from(batch));
              final profiles = batch
                  .map((did) => ProfileView(did: did, handle: '$did.bsky.social', indexedAt: DateTime.utc(2026)))
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

class _FakeBlueskyClient {
  _FakeBlueskyClient({required this.actor, _FakeGraphService? graph}) : graph = graph ?? _FakeGraphService();

  final _FakeActorService actor;
  final _FakeGraphService graph;
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

  final List<ProfileView> profiles;
}

class _FakeGraphService {
  _FakeGraphService({
    List<ProfileView>? suggestions,
    Future<_FakeSuggestedResponse> Function(String actor)? onGetSuggested,
  }) : _suggestions = suggestions ?? [],
       _onGetSuggested = onGetSuggested;

  final List<ProfileView> _suggestions;
  final Future<_FakeSuggestedResponse> Function(String actor)? _onGetSuggested;

  Future<_FakeSuggestedResponse> getSuggestedFollowsByActor({required String actor, Map<String, String>? $headers}) {
    final handler = _onGetSuggested;
    if (handler != null) return handler(actor);
    return Future.value(_FakeSuggestedResponse(_FakeSuggestedData(_suggestions)));
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
