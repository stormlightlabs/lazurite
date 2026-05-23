import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/like.dart';
import 'package:characters/characters.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/actor_repository_service_resolver.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:poptart_core/poptart_core.dart' as atp_core;
import 'package:poptart_lex/com/atproto/repo/list_records.dart';

class ProfileRepository {
  ProfileRepository({
    required AppDatabase database,
    required Bluesky bluesky,
    ModerationService? moderationService,
    ActorRepositoryServiceResolver? actorRepositoryServiceResolver,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _database = database,
       _moderationService = moderationService,
       _actorRepoResolver = actorRepositoryServiceResolver ?? _createActorRepositoryServiceResolver(),
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
      onUnauthorizedException: (error, stackTrace) {
        log.w('profile.auth unauthorized; attempting session recovery', error: error, stackTrace: stackTrace);
      },
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final AppDatabase _database;
  Bluesky get _bluesky => _authRecovery.client;
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
        log.w(
          'ProfileRepository: getProfile cached JSON ${PoptartCacheCodecs.profileViewDetailed.encode(cachedProfile)}',
        );
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
        response.data.profiles
            .map(_profileViewFromDetailed)
            .where((profile) => !(_moderationService?.shouldFilterProfileInList(profile) ?? false)),
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
    final profiles = _filterProfileList(response.data.follows);
    return ProfileConnectionsPage(subject: response.data.subject, profiles: profiles, cursor: response.data.cursor);
  }

  Future<ProfileConnectionsPage> getFollowers({required String actor, String? cursor, int limit = 50}) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.graph.getFollowers',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.graph.getFollowers(actor: actor, cursor: cursor, limit: limit, $headers: headers),
    );
    final profiles = _filterProfileList(response.data.followers);
    return ProfileConnectionsPage(subject: response.data.subject, profiles: profiles, cursor: response.data.cursor);
  }

  Future<ProfileConnectionsPage> getKnownFollowers({required String actor, String? cursor, int limit = 50}) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.graph.getKnownFollowers',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.graph.getKnownFollowers(actor: actor, cursor: cursor, limit: limit, $headers: headers),
    );
    final profiles = _filterProfileList(response.data.followers);
    return ProfileConnectionsPage(subject: response.data.subject, profiles: profiles, cursor: response.data.cursor);
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
      final feed = response.data.feed;
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
    final likeRecords = _extractLikeRecords(recordsResponse.data.records);
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
    final subjectUris = <atp_core.AtUri>[];
    for (final record in likeRecords) {
      try {
        final subjectUri = atp_core.AtUri.parse(record.subjectUri);
        if (subjectUri.collection.toString() != 'app.bsky.feed.post' || subjectUri.rkey.isEmpty) {
          log.w('ProfileRepository: skipping malformed liked post URI ${record.subjectUri}');
          continue;
        }
        subjectUris.add(subjectUri);
      } catch (error, stackTrace) {
        log.w(
          'ProfileRepository: skipping malformed liked post URI ${record.subjectUri}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
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

  Future<void> updateProfile({required String did, required ProfileEditDraft draft}) async {
    _validateProfileEditDraft(draft);
    log.d('ProfileRepository: Updating profile record for $did');

    final response = await _authRecovery.run(
      (client) => client.atproto.repo.getRecord(repo: did, collection: 'app.bsky.actor.profile', rkey: 'self'),
    );
    var updatedRecord = _profileRecordFromValue(response.data.value).copyWith(
      displayName: _trimOptional(draft.displayName),
      description: _trimOptional(draft.description),
      pronouns: _trimOptional(draft.pronouns),
      website: _trimOptional(draft.website),
    );

    final avatar = draft.avatar;
    if (avatar != null) {
      updatedRecord = updatedRecord.copyWith(avatar: await _uploadProfileBlob(avatar));
    }

    final banner = draft.banner;
    if (banner != null) {
      updatedRecord = updatedRecord.copyWith(banner: await _uploadProfileBlob(banner));
    }

    await _authRecovery.run(
      (client) => client.atproto.repo.putRecord(
        repo: did,
        collection: 'app.bsky.actor.profile',
        rkey: 'self',
        validate: true,
        record: _profileRecordJson(updatedRecord),
        swapRecord: response.data.cid,
      ),
    );
  }

  Future<atp_core.Blob> _uploadProfileBlob(ProfileImageUpload upload) async {
    final response = await _authRecovery.run(
      (client) => client.atproto.repo.uploadBlob(
        bytes: Uint8List.fromList(upload.bytes),
        $headers: {'Content-Type': upload.mimeType},
      ),
    );
    return response.data.blob;
  }

  String? _trimOptional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  ActorProfileRecord _profileRecordFromValue(Map<String, dynamic> value) {
    if (!ActorProfileRecord.validate(value)) {
      log.w('ProfileRepository: current profile record missing app.bsky.actor.profile type; rebuilding typed record');
      return const ActorProfileRecord();
    }

    return const ActorProfileRecordConverter().fromJson(value);
  }

  Map<String, dynamic> _profileRecordJson(ActorProfileRecord record) {
    return const ActorProfileRecordConverter().toJson(record);
  }

  void _validateProfileEditDraft(ProfileEditDraft draft) {
    _validateTextLimit('displayName', draft.displayName, maxGraphemes: 64, maxUtf8Bytes: 640);
    _validateTextLimit('description', draft.description, maxGraphemes: 256, maxUtf8Bytes: 2560);
    _validateTextLimit('pronouns', draft.pronouns, maxGraphemes: 20, maxUtf8Bytes: 200);
    _validateProfileImage('avatar', draft.avatar);
    _validateProfileImage('banner', draft.banner);
  }

  void _validateTextLimit(String field, String? value, {required int maxGraphemes, required int maxUtf8Bytes}) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return;
    }
    if (text.characters.length > maxGraphemes || utf8.encode(text).length > maxUtf8Bytes) {
      throw ArgumentError('$field exceeds the profile lexicon limit.');
    }
  }

  void _validateProfileImage(String field, ProfileImageUpload? upload) {
    if (upload == null) {
      return;
    }
    if (!ProfileImageUpload.acceptedMimeTypes.contains(upload.mimeType)) {
      throw ArgumentError('$field must be a JPEG or PNG image.');
    }
    if (upload.bytes.length > ProfileImageUpload.maxBytes) {
      throw ArgumentError('$field must be smaller than 1MB.');
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
    return PoptartCacheCodecs.profileViewDetailed.decode(cachedProfile.payload);
  }

  Future<void> _cacheProfileSafely(ProfileViewDetailed profile) async {
    try {
      await _database.cacheProfile(
        did: profile.did,
        handle: profile.handle,
        payload: PoptartCacheCodecs.profileViewDetailed.encode(profile),
      );
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

    final session = _bluesky.session;
    final sessionDid = session?.did.trim().toLowerCase();
    final sessionHandle = session?.handle.trim().toLowerCase();
    if (normalizedActor == sessionDid || normalizedActor == sessionHandle) {
      return true;
    }

    final oauthDid = _bluesky.oAuthSession?.sub.trim().toLowerCase();
    return normalizedActor == oauthDid;
  }

  Future<ActorRepositoryServiceResolution> _resolveActorRepositoryService(String actor) async {
    final resolver = _actorRepoResolver;
    if (resolver == null) {
      throw StateError('Actor repository resolver is unavailable in this profile repository context.');
    }
    return resolver.resolve(actor);
  }

  List<_LikeRecord> _extractLikeRecords(List<RepoListRecordsRecord> rawRecords) {
    final records = <_LikeRecord>[];
    for (final raw in rawRecords) {
      final value = raw.value;
      if (!FeedLikeRecord.validate(value)) {
        continue;
      }
      final like = const FeedLikeRecordConverter().fromJson(value);
      final subjectUri = like.subject.uri.toString();
      if (subjectUri.isEmpty) {
        continue;
      }
      records.add(_LikeRecord(subjectUri: subjectUri, createdAt: like.createdAt));
    }
    return records;
  }

  DateTime? _extractLikedAtFromReason(UFeedViewPostReason? reason) {
    if (reason == null) {
      return null;
    }

    if (reason.isReasonRepost) {
      return reason.reasonRepost!.indexedAt.toUtc();
    }

    final indexedAt = reason.unknown?['indexedAt'];
    return indexedAt is String ? DateTime.tryParse(indexedAt)?.toUtc() : null;
  }

  List<ProfileView> _filterProfileList(List<ProfileView> profiles) {
    final moderationService = _moderationService;
    if (moderationService == null) return profiles;
    return profiles.where((profile) => !moderationService.shouldFilterProfileInList(profile)).toList(growable: false);
  }

  ProfileView _profileViewFromDetailed(ProfileViewDetailed profile) {
    return ProfileView(
      did: profile.did,
      handle: profile.handle,
      displayName: profile.displayName,
      pronouns: profile.pronouns,
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
}

class ProfileConnectionsPage {
  const ProfileConnectionsPage({required this.subject, required this.profiles, this.cursor});

  final ProfileView subject;
  final List<ProfileView> profiles;
  final String? cursor;
}

class ProfileEditDraft {
  const ProfileEditDraft({this.displayName, this.description, this.pronouns, this.website, this.avatar, this.banner});

  final String? displayName;
  final String? description;
  final String? pronouns;
  final String? website;
  final ProfileImageUpload? avatar;
  final ProfileImageUpload? banner;
}

class ProfileImageUpload {
  const ProfileImageUpload({required this.bytes, required this.mimeType});

  static const int maxBytes = 1000000;
  static const Set<String> acceptedMimeTypes = {'image/jpeg', 'image/png'};

  final List<int> bytes;
  final String mimeType;
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
