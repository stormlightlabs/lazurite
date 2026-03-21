import 'dart:convert';

import 'package:drift/native.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
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
  _FakeBlueskyClient({required this.actor});

  final _FakeActorService actor;
}

class _FakeActorService {
  _FakeActorService({required this.onGetProfile});

  final Future<_FakeResponse<ProfileViewDetailed>> Function(String actor) onGetProfile;

  Future<_FakeResponse<ProfileViewDetailed>> getProfile({required String actor, Map<String, String>? $headers}) {
    return onGetProfile(actor);
  }

  Future<_FakeProfilesResponse> getProfiles({required List<String> actors, Map<String, String>? $headers}) async {
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
