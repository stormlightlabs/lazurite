import 'dart:convert';

import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

class ProfileRepository {
  ProfileRepository({required AppDatabase database, required dynamic bluesky})
    : _database = database,
      _bluesky = bluesky;

  final AppDatabase _database;
  final dynamic _bluesky;

  Future<ProfileViewDetailed> getProfile(String actor) async {
    try {
      final response = await _bluesky.actor.getProfile(actor: actor);
      final profile = response.data;

      await _database.cacheProfile(did: profile.did, handle: profile.handle, payload: jsonEncode(profile.toJson()));

      return profile;
    } catch (error) {
      final cachedProfile = await _getCachedProfile(actor);
      if (cachedProfile != null) {
        return cachedProfile;
      }

      rethrow;
    }
  }

  Future<List<ProfileView>> getProfiles(List<String> actors) async {
    final response = await _bluesky.actor.getProfiles(actors: actors);
    return response.data.profiles;
  }

  Future<ProfileViewDetailed?> getCurrentUserProfile(AuthTokens tokens) async {
    try {
      final response = await _bluesky.actor.getProfile(actor: tokens.did);
      return response.data;
    } catch (error) {
      return null;
    }
  }

  Future<ProfileViewDetailed?> _getCachedProfile(String actor) async {
    final cachedProfileByDid = await (_database.select(
      _database.cachedProfiles,
    )..where((profile) => profile.did.equals(actor))).getSingleOrNull();
    final cachedProfile =
        cachedProfileByDid ??
        await (_database.select(
          _database.cachedProfiles,
        )..where((profile) => profile.handle.equals(actor))).getSingleOrNull();

    if (cachedProfile == null) {
      return null;
    }

    return ProfileViewDetailed.fromJson(jsonDecode(cachedProfile.payload) as Map<String, dynamic>);
  }
}
