import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for profile data with cache-first reads.
class ProfileRepository {
  ProfileRepository(this._api, this._dao, this._logger);

  final XrpcClient _api;
  final ProfileDao _dao;
  final Logger _logger;

  /// Fetches a profile from the API and caches it.
  ///
  /// [actor] can be a DID or handle.
  Future<ProfileData> getProfile(String actor) async {
    _logger.info('Fetching profile', {'actor': actor});
    try {
      final response = await _api.call('app.bsky.actor.getProfile', params: {'actor': actor});

      final profile = ProfileData.fromJson(response);

      // Cache the profile
      await _dao.upsertProfile(
        ProfilesCompanion.insert(
          did: profile.did,
          handle: profile.handle,
          displayName: Value(profile.displayName),
          description: Value(profile.description),
          avatar: Value(profile.avatar),
          banner: Value(profile.banner),
          indexedAt: Value(profile.indexedAt),
        ),
      );
      _logger.debug('Cached profile', {'did': profile.did});

      return profile;
    } catch (e, stack) {
      _logger.error('Failed to fetch profile', e, stack);
      rethrow;
    }
  }

  /// Gets a cached profile by DID.
  Future<Profile?> getCachedProfile(String did) {
    return _dao.getProfile(did);
  }

  /// Watches a cached profile by DID.
  Stream<Profile?> watchProfile(String did) {
    return _dao.watchProfile(did);
  }

  /// Fetches author's feed with cursor pagination.
  Future<AuthorFeedResult> getAuthorFeed(String actor, {String? cursor}) async {
    _logger.info('Fetching author feed', {'actor': actor, 'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.feed.getAuthorFeed',
        params: {'actor': actor, 'limit': 50, if (cursor != null) 'cursor': cursor},
      );

      final feed =
          (response['feed'] as List?)
              ?.map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Fetched ${feed.length} author feed items');
      return AuthorFeedResult(items: feed, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Failed to fetch author feed', e, stack);
      rethrow;
    }
  }
}

/// Domain model for profile data from API.
class ProfileData {
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      banner: json['banner'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followsCount: json['followsCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      indexedAt: json['indexedAt'] != null ? DateTime.tryParse(json['indexedAt'] as String) : null,
    );
  }

  ProfileData({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.banner,
    this.followersCount = 0,
    this.followsCount = 0,
    this.postsCount = 0,
    this.indexedAt,
  });

  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final String? banner;
  final int followersCount;
  final int followsCount;
  final int postsCount;
  final DateTime? indexedAt;

  /// Returns display name or handle.
  String get displayNameOrHandle => displayName ?? handle;
}

/// Result of fetching author feed.
class AuthorFeedResult {
  AuthorFeedResult({required this.items, this.cursor});

  final List<FeedItem> items;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// Represents a single feed item from author feed.
class FeedItem {
  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final post = json['post'] as Map<String, dynamic>;
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;

    return FeedItem(
      uri: post['uri'] as String,
      cid: post['cid'] as String,
      authorDid: author['did'] as String,
      authorHandle: author['handle'] as String,
      authorDisplayName: author['displayName'] as String?,
      authorAvatar: author['avatar'] as String?,
      text: record['text'] as String? ?? '',
      indexedAt: DateTime.tryParse(post['indexedAt'] as String? ?? ''),
      replyCount: post['replyCount'] as int? ?? 0,
      repostCount: post['repostCount'] as int? ?? 0,
      likeCount: post['likeCount'] as int? ?? 0,
    );
  }

  FeedItem({
    required this.uri,
    required this.cid,
    required this.authorDid,
    required this.authorHandle,
    this.authorDisplayName,
    this.authorAvatar,
    required this.text,
    this.indexedAt,
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
  });

  final String uri;
  final String cid;
  final String authorDid;
  final String authorHandle;
  final String? authorDisplayName;
  final String? authorAvatar;
  final String text;
  final DateTime? indexedAt;
  final int replyCount;
  final int repostCount;
  final int likeCount;
}
