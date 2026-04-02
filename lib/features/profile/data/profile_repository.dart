import 'dart:convert';

import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class ProfileRepository {
  ProfileRepository({required AppDatabase database, required dynamic bluesky, ModerationService? moderationService})
    : _database = database,
      _bluesky = bluesky,
      _moderationService = moderationService;

  final AppDatabase _database;
  final dynamic _bluesky;
  final ModerationService? _moderationService;

  Future<ProfileViewDetailed> getProfile(String actor) async {
    log.d('ProfileRepository: Loading profile for $actor via ${_describeClientContext()}');

    try {
      final response = await _bluesky.actor.getProfile(
        actor: actor,
        $headers: await _moderationService?.headersForRequest(),
      );
      final profile = response.data;
      log.i('ProfileRepository: Loaded profile ${profile.did} (${profile.handle})');

      await _database.cacheProfile(did: profile.did, handle: profile.handle, payload: jsonEncode(profile.toJson()));
      log.d('ProfileRepository: Cached profile ${profile.did} (${profile.handle})');

      if (_moderationService?.shouldFilterProfileDetailedInView(profile) ?? false) {
        throw Exception('Profile hidden by moderation preferences');
      }

      return profile;
    } catch (error, stackTrace) {
      log.e('ProfileRepository: Failed to load profile for $actor', error: error, stackTrace: stackTrace);
      final cachedProfile = await _getCachedProfile(actor);
      if (cachedProfile != null) {
        log.w('ProfileRepository: Using cached profile for $actor after request failure');
        if (_moderationService?.shouldFilterProfileDetailedInView(cachedProfile) ?? false) {
          throw Exception('Profile hidden by moderation preferences');
        }
        return cachedProfile;
      }

      rethrow;
    }
  }

  Future<List<ProfileView>> getProfiles(List<String> actors) async {
    log.d('ProfileRepository: Loading ${actors.length} profiles via ${_describeClientContext()}');
    final response = await _bluesky.actor.getProfiles(
      actors: actors,
      $headers: await _moderationService?.headersForRequest(),
    );
    final profiles = response.data.profiles
        .where((profile) => !(_moderationService?.shouldFilterProfileInList(profile) ?? false))
        .toList();
    log.i('ProfileRepository: Loaded ${profiles.length} profiles');
    return profiles;
  }

  Future<List<ProfileView>> getSuggestedFollows(String actor) async {
    final response = await _bluesky.graph.getSuggestedFollowsByActor(actor: actor);
    final suggestions = response.data.suggestions;
    final moderationService = _moderationService;
    if (moderationService == null) return suggestions;
    return suggestions.where((p) => !moderationService.shouldFilterProfileInList(p)).toList();
  }

  Future<ProfileViewDetailed?> getCurrentUserProfile(AuthTokens tokens) async {
    log.d('ProfileRepository: Loading current user profile for ${tokens.did} via ${_describeClientContext()}');

    try {
      final response = await _bluesky.actor.getProfile(
        actor: tokens.did,
        $headers: await _moderationService?.headersForRequest(),
      );
      log.i('ProfileRepository: Loaded current user profile ${response.data.did} (${response.data.handle})');
      return response.data;
    } catch (error, stackTrace) {
      log.e(
        'ProfileRepository: Failed to load current user profile for ${tokens.did}',
        error: error,
        stackTrace: stackTrace,
      );
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
      log.d('ProfileRepository: No cached profile found for $actor');
      return null;
    }

    log.d('ProfileRepository: Found cached profile for $actor');
    return ProfileViewDetailed.fromJson(jsonDecode(cachedProfile.payload) as Map<String, dynamic>);
  }

  String _describeClientContext() {
    final bluesky = _bluesky;
    if (bluesky is! Bluesky) {
      return 'unknown client';
    }

    final oauthSession = bluesky.oAuthSession;
    final session = bluesky.session;
    final configuredService = bluesky.service;

    if (oauthSession != null) {
      return 'oauth service=$configuredService pds=${oauthSession.atprotoPdsEndpoint ?? 'unknown'}';
    }

    if (session != null) {
      return 'session service=$configuredService pds=${session.atprotoPdsEndpoint ?? 'unknown'}';
    }

    return 'anonymous service=$configuredService';
  }
}
