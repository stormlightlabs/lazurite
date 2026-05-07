import 'dart:async';
import 'dart:convert';

import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/actor_repository_service_resolver.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class ProfileRepository {
  ProfileRepository({
    required AppDatabase database,
    required dynamic bluesky,
    ModerationService? moderationService,
    ActorRepositoryServiceResolver? actorRepositoryServiceResolver,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    dynamic Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _database = database,
       _moderationService = moderationService,
       _actorRepoResolver = actorRepositoryServiceResolver ?? _createActorRepositoryServiceResolver(),
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<dynamic>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
      onUnauthorizedException: (error, stackTrace) {
        log.w('profile.auth unauthorized; attempting session recovery', error: error, stackTrace: stackTrace);
      },
    );
  }

  late final UnauthorizedRecoveryRunner<dynamic> _authRecovery;
  final AppDatabase _database;
  dynamic get _bluesky => _authRecovery.client;
  final ModerationService? _moderationService;
  final ActorRepositoryServiceResolver? _actorRepoResolver;
  final AppViewRequestContext _appViewContext;
  static const int _maxProfilesBatchSize = 25;
  static const int _maxPostsHydrationBatchSize = 25;

  static ActorRepositoryServiceResolver? _createActorRepositoryServiceResolver() {
    try {
      return ActorRepositoryServiceResolver();
    } catch (error, stackTrace) {
      log.d('ProfileRepository: actor repository service resolver unavailable', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<ProfileViewDetailed> getProfile(String actor) async {
    log.d('ProfileRepository: Loading profile for $actor via ${_describeClientContext()}');

    ProfileViewDetailed profile;
    try {
      final headers = _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.actor.getProfile',
        await _moderationService?.headersForRequest(),
      );
      log.i(
        'ProfileRepository: getProfile request actor=$actor atproto-proxy=${_headerValue(headers, 'atproto-proxy') ?? 'none'}',
      );
      final response = await _authRecovery.run((client) => client.actor.getProfile(actor: actor, $headers: headers));
      profile = response.data;
      log.i('ProfileRepository: Loaded profile ${profile.did} (${profile.handle})');
    } catch (error, stackTrace) {
      log.e('ProfileRepository: Failed to fetch profile from network for $actor', error: error, stackTrace: stackTrace);
      final cachedProfile = await _getCachedProfile(actor);
      if (cachedProfile != null) {
        log.w('ProfileRepository: Using cached profile for $actor after request failure');
        log.w('ProfileRepository: getProfile cached JSON ${jsonEncode(cachedProfile.toJson())}');
        if (_moderationService?.shouldFilterProfileDetailedInView(cachedProfile) ?? false) {
          throw Exception('Profile hidden by moderation preferences');
        }
        return cachedProfile;
      }

      rethrow;
    }

    unawaited(_cacheProfileSafely(profile));

    if (_moderationService?.shouldFilterProfileDetailedInView(profile) ?? false) {
      throw Exception('Profile hidden by moderation preferences');
    }

    return profile;
  }

  Future<List<ProfileView>> getProfiles(List<String> actors) async {
    log.d('ProfileRepository: Loading ${actors.length} profiles via ${_describeClientContext()}');
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.actor.getProfiles',
      await _moderationService?.headersForRequest(),
    );
    final normalizedActors = actors.where((actor) => actor.trim().isNotEmpty).toList(growable: false);
    if (normalizedActors.isEmpty) {
      return const [];
    }

    log.i(
      'ProfileRepository: getProfiles request actors=${normalizedActors.length} batchSize=$_maxProfilesBatchSize atproto-proxy=${_headerValue(headers, 'atproto-proxy') ?? 'none'}',
    );

    final profiles = <ProfileView>[];
    for (var i = 0; i < normalizedActors.length; i += _maxProfilesBatchSize) {
      final batch = normalizedActors.sublist(i, (i + _maxProfilesBatchSize).clamp(0, normalizedActors.length));
      final response = await _authRecovery.run((client) => client.actor.getProfiles(actors: batch, $headers: headers));
      profiles.addAll(
        response.data.profiles.where((profile) => !(_moderationService?.shouldFilterProfileInList(profile) ?? false)),
      );
    }

    log.i('ProfileRepository: Loaded ${profiles.length} profiles');
    return profiles;
  }

  Future<List<ProfileView>> getSuggestedFollows(String actor) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.graph.getSuggestedFollowsByActor',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.graph.getSuggestedFollowsByActor(actor: actor, $headers: headers),
    );
    final suggestions = response.data.suggestions;
    final moderationService = _moderationService;
    if (moderationService == null) return suggestions;
    return suggestions.where((p) => !moderationService.shouldFilterProfileInList(p)).toList();
  }

  Future<ProfileConnectionsPage> getFollowing({required String actor, String? cursor, int limit = 50}) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.graph.getFollows',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.graph.getFollows(actor: actor, cursor: cursor, limit: limit, $headers: headers),
    );
    final profiles = _filterProfileList(response.data.follows as List<ProfileView>);
    return ProfileConnectionsPage(
      subject: response.data.subject as ProfileView,
      profiles: profiles,
      cursor: response.data.cursor as String?,
    );
  }

  Future<ProfileConnectionsPage> getFollowers({required String actor, String? cursor, int limit = 50}) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.graph.getFollowers',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.graph.getFollowers(actor: actor, cursor: cursor, limit: limit, $headers: headers),
    );
    final profiles = _filterProfileList(response.data.followers as List<ProfileView>);
    return ProfileConnectionsPage(
      subject: response.data.subject as ProfileView,
      profiles: profiles,
      cursor: response.data.cursor as String?,
    );
  }

  /// Likes transport matrix:
  /// - Self liked tab: app.bsky.feed.getActorLikes via viewer-auth context
  ///   (PDS-routed, read-after-write behavior for the current account).
  /// - Non-self liked tab: actor repo scan on actor PDS via
  ///   com.atproto.repo.listRecords(app.bsky.feed.like), then hydrate subjects
  ///   on AppView via app.bsky.feed.getPosts.
  /// Never route non-self repo reads through the viewer PDS.
  Future<ProfileActorLikesResult> getActorLikes({required String actor, String? cursor, int limit = 50}) async {
    if (_isCurrentSessionActor(actor)) {
      final headers = _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest());
      log.i(
        'ProfileRepository: likes self path actor=$actor endpoint=app.bsky.feed.getActorLikes host=current-session-pds',
      );
      final response = await _authRecovery.run(
        (client) => client.feed.getActorLikes(actor: actor, cursor: cursor, limit: limit, $headers: headers),
      );
      final feed = (response.data.feed as List<dynamic>).whereType<FeedViewPost>().toList(growable: false);
      final moderationService = _moderationService;
      final posts = moderationService == null
          ? feed
          : feed.where((post) => !moderationService.shouldFilterFeedViewPostInList(post)).toList();
      return ProfileActorLikesResult(
        entries: posts
            .map(
              (post) =>
                  ProfileActorLikeEntry.available(feedViewPost: post, likedAt: _extractLikedAtFromReason(post.reason)),
            )
            .toList(growable: false),
        cursor: response.data.cursor,
      );
    }

    final resolved = await _resolveActorRepositoryService(actor);
    log.i(
      'ProfileRepository: likes non-self list path actor=$actor did=${resolved.did} endpoint=com.atproto.repo.listRecords host=${resolved.pdsHost}',
    );
    final recordsResponse = await _authRecovery.run(
      (client) => client.atproto.repo.listRecords(
        repo: resolved.did,
        collection: 'app.bsky.feed.like',
        limit: limit.clamp(1, 100),
        cursor: cursor,
        reverse: false,
        $service: resolved.pdsHost,
      ),
    );
    final likeRecords = _extractLikeRecords(recordsResponse.data.records as List<dynamic>);
    if (likeRecords.isEmpty) {
      return ProfileActorLikesResult(entries: const [], cursor: recordsResponse.data.cursor);
    }

    final appViewHost = AppViewProviders.bluesky.publicBaseUrl.host;
    log.i(
      'ProfileRepository: likes non-self hydrate path actor=$actor did=${resolved.did} endpoint=app.bsky.feed.getPosts host=$appViewHost',
    );
    final hydrationHeaders = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getPosts',
      await _moderationService?.headersForRequest(),
    );
    final moderationService = _moderationService;
    final postsByUri = <String, PostView>{};
    final subjectUris = likeRecords.map((record) => atp_core.AtUri.parse(record.subjectUri)).toList(growable: false);
    for (var i = 0; i < subjectUris.length; i += _maxPostsHydrationBatchSize) {
      final batch = subjectUris.sublist(i, (i + _maxPostsHydrationBatchSize).clamp(0, subjectUris.length));
      final response = await _authRecovery.run(
        (client) => client.feed.getPosts(uris: batch, $service: appViewHost, $headers: hydrationHeaders),
      );
      for (final post in response.data.posts) {
        postsByUri[post.uri.toString()] = post;
      }
    }

    final entries = <ProfileActorLikeEntry>[];
    for (final record in likeRecords) {
      final post = postsByUri[record.subjectUri];
      if (post != null) {
        final feedViewPost = FeedViewPost(post: post);
        if (moderationService != null && moderationService.shouldFilterFeedViewPostInList(feedViewPost)) {
          continue;
        }
        entries.add(
          ProfileActorLikeEntry.available(
            feedViewPost: FeedViewPost(post: post),
            likedAt: record.createdAt,
          ),
        );
      } else {
        entries.add(ProfileActorLikeEntry.unavailable(subjectUri: record.subjectUri, likedAt: record.createdAt));
      }
    }

    return ProfileActorLikesResult(entries: entries, cursor: recordsResponse.data.cursor);
  }

  Future<ProfileViewDetailed?> getCurrentUserProfile(AuthTokens tokens) async {
    log.d('ProfileRepository: Loading current user profile for ${tokens.did} via ${_describeClientContext()}');

    try {
      final headers = _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.actor.getProfile',
        await _moderationService?.headersForRequest(),
      );
      log.i(
        'ProfileRepository: getCurrentUserProfile request did=${tokens.did} atproto-proxy=${_headerValue(headers, 'atproto-proxy') ?? 'none'}',
      );
      final response = await _authRecovery.run(
        (client) => client.actor.getProfile(actor: tokens.did, $headers: headers),
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

  Future<void> _cacheProfileSafely(ProfileViewDetailed profile) async {
    try {
      await _database.cacheProfile(did: profile.did, handle: profile.handle, payload: jsonEncode(profile.toJson()));
      log.d('ProfileRepository: Cached profile ${profile.did} (${profile.handle})');
    } catch (error, stackTrace) {
      log.w(
        'ProfileRepository: Failed to cache profile ${profile.did} (${profile.handle})',
        error: error,
        stackTrace: stackTrace,
      );
    }
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

  String? _headerValue(Map<String, String>? headers, String key) {
    if (headers == null) {
      return null;
    }
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  bool _isCurrentSessionActor(String actor) {
    final normalizedActor = actor.trim().toLowerCase();
    if (normalizedActor.isEmpty) {
      return false;
    }

    final bluesky = _bluesky;
    if (bluesky is Bluesky) {
      final session = bluesky.session;
      final sessionDid = session?.did.trim().toLowerCase();
      final sessionHandle = session?.handle.trim().toLowerCase();
      if (normalizedActor == sessionDid || normalizedActor == sessionHandle) {
        return true;
      }

      final oauthDid = bluesky.oAuthSession?.sub.trim().toLowerCase();
      return normalizedActor == oauthDid;
    }

    try {
      final session = bluesky.session;
      final sessionDid = (session?.did as String?)?.trim().toLowerCase();
      final sessionHandle = (session?.handle as String?)?.trim().toLowerCase();
      if (normalizedActor == sessionDid || normalizedActor == sessionHandle) {
        return true;
      }
    } catch (e) {
      log.d('ProfileRepository: Unable to parse current session actor', error: e);
    }

    try {
      final oauthSession = bluesky.oAuthSession;
      final oauthDid = (oauthSession?.sub as String?)?.trim().toLowerCase();
      if (normalizedActor == oauthDid) {
        return true;
      }
    } catch (e) {
      log.d('ProfileRepository: Unable to parse current session actor', error: e);
    }
    return false;
  }

  Future<ActorRepositoryServiceResolution> _resolveActorRepositoryService(String actor) async {
    final resolver = _actorRepoResolver;
    if (resolver == null) {
      throw StateError('Actor repository resolver is unavailable in this profile repository context.');
    }
    return resolver.resolve(actor);
  }

  List<_LikeRecord> _extractLikeRecords(List<dynamic> rawRecords) {
    final records = <_LikeRecord>[];
    for (final raw in rawRecords) {
      final value = (raw as dynamic).value;
      if (value is! Map) {
        continue;
      }
      final subject = value['subject'];
      if (subject is! Map) {
        continue;
      }
      final subjectUri = subject['uri'];
      if (subjectUri is String && subjectUri.isNotEmpty) {
        final createdAtRaw = value['createdAt'];
        final createdAt = createdAtRaw is String ? DateTime.tryParse(createdAtRaw) : null;
        records.add(_LikeRecord(subjectUri: subjectUri, createdAt: createdAt));
      }
    }
    return records;
  }

  DateTime? _extractLikedAtFromReason(dynamic reason) {
    if (reason == null) {
      return null;
    }
    try {
      final map = reason is Map ? reason : (reason as dynamic).toJson();
      final indexedAt = map['indexedAt'] as String?;
      return indexedAt == null ? null : DateTime.tryParse(indexedAt);
    } catch (error, stackTrace) {
      log.d('ProfileRepository: ignored malformed actor likes reason', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  List<ProfileView> _filterProfileList(List<ProfileView> profiles) {
    final moderationService = _moderationService;
    if (moderationService == null) return profiles;
    return profiles.where((profile) => !moderationService.shouldFilterProfileInList(profile)).toList(growable: false);
  }
}

class ProfileConnectionsPage {
  const ProfileConnectionsPage({required this.subject, required this.profiles, this.cursor});

  final ProfileView subject;
  final List<ProfileView> profiles;
  final String? cursor;
}

class ProfileActorLikesResult {
  const ProfileActorLikesResult({required this.entries, this.cursor});

  final List<ProfileActorLikeEntry> entries;
  final String? cursor;

  List<FeedViewPost> get posts =>
      entries.where((entry) => entry.isAvailable).map((entry) => entry.feedViewPost!).toList(growable: false);

  List<String> get unavailableSubjectUris =>
      entries.where((entry) => !entry.isAvailable).map((entry) => entry.subjectUri!).toList(growable: false);
}

class ProfileActorLikeEntry {
  const ProfileActorLikeEntry._({
    required this.likedAt,
    required this.feedViewPost,
    required this.subjectUri,
    required this.unavailableReason,
  });

  const ProfileActorLikeEntry.available({required FeedViewPost feedViewPost, required DateTime? likedAt})
    : this._(likedAt: likedAt, feedViewPost: feedViewPost, subjectUri: null, unavailableReason: null);

  const ProfileActorLikeEntry.unavailable({required String subjectUri, required DateTime? likedAt})
    : this._(
        likedAt: likedAt,
        feedViewPost: null,
        subjectUri: subjectUri,
        unavailableReason: 'Post unavailable or failed to hydrate',
      );

  final DateTime? likedAt;
  final FeedViewPost? feedViewPost;
  final String? subjectUri;
  final String? unavailableReason;

  bool get isAvailable => feedViewPost != null;
}

class _LikeRecord {
  const _LikeRecord({required this.subjectUri, required this.createdAt});

  final String subjectUri;
  final DateTime? createdAt;
}
