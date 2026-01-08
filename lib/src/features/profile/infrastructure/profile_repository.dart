import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/follows_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_relationship_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for profile data with cache-first reads.
class ProfileRepository {
  ProfileRepository(this._api, this._dao, this._followsDao, this._relationshipsDao, this._logger);

  final XrpcClient _api;
  final ProfileDao _dao;
  final FollowsDao _followsDao;
  final ProfileRelationshipDao _relationshipsDao;
  final Logger _logger;

  /// Fetches a profile from the API and caches it.
  ///
  /// [actor] can be a DID or handle.
  Future<ProfileData> getProfile(String actor) async {
    _logger.info('Fetching profile', {'actor': actor});
    try {
      final response = await _api.call('app.bsky.actor.getProfile', params: {'actor': actor});

      final pinnedRaw = response['pinnedPost'];
      if (pinnedRaw != null) {
        _logger.info('Received pinnedPost', {
          'type': pinnedRaw.runtimeType.toString(),
          'value': pinnedRaw.toString(),
        });
      } else {
        _logger.info('No pinnedPost in response');
      }

      final profile = ProfileData.fromJson(response);

      await _dao.upsertProfile(
        ProfilesCompanion.insert(
          did: profile.did,
          handle: profile.handle,
          displayName: Value(profile.displayName),
          description: Value(profile.description),
          avatar: Value(profile.avatar),
          banner: Value(profile.banner),
          indexedAt: Value(profile.indexedAt),
          pronouns: Value(profile.pronouns),
          website: Value(profile.website),
          createdAt: Value(profile.createdAt),
          verificationStatus: Value(profile.verificationStatus),
          labels: Value(profile.labels != null ? jsonEncode(profile.labels) : null),
          pinnedPostUri: Value(profile.pinnedPostUri),
        ),
      );

      await _relationshipsDao.upsertRelationship(
        ProfileRelationshipsCompanion.insert(
          profileDid: profile.did,
          following: Value(profile.viewerFollowing),
          followingUri: Value(profile.viewerFollowUri),
          followedBy: Value(profile.viewerFollowedBy),
          muted: Value(profile.viewerMuted),
          blocked: Value(profile.viewerBlockingUri != null),
          blockedBy: Value(profile.viewerBlockedBy),
          blockingUri: Value(profile.viewerBlockingUri),
          mutedByList: Value(profile.viewerMutedByList),
          blockingByList: Value(profile.viewerBlockingByList),
          updatedAt: DateTime.now(),
        ),
      );

      _logger.debug('Cached profile and relationships', {'did': profile.did});

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

  /// Fetches followers of an actor with cursor pagination.
  Future<FollowersResult> getFollowers(String actor, {String? cursor}) async {
    _logger.info('Fetching followers', {'actor': actor, 'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.graph.getFollowers',
        params: {'actor': actor, 'limit': 50, if (cursor != null) 'cursor': cursor},
      );

      final followers =
          (response['followers'] as List?)
              ?.map((e) => ActorBasic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Fetched ${followers.length} followers');
      return FollowersResult(followers: followers, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Failed to fetch followers', e, stack);
      rethrow;
    }
  }

  /// Fetches accounts an actor is following with cursor pagination.
  Future<FollowsResult> getFollows(String actor, {String? cursor}) async {
    _logger.info('Fetching follows', {'actor': actor, 'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.graph.getFollows',
        params: {'actor': actor, 'limit': 50, if (cursor != null) 'cursor': cursor},
      );

      final follows =
          (response['follows'] as List?)
              ?.map((e) => ActorBasic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Fetched ${follows.length} follows');
      return FollowsResult(follows: follows, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Failed to fetch follows', e, stack);
      rethrow;
    }
  }

  /// Follow a user. Returns the created follow record URI.
  Future<String> follow(String actorDid, String subjectDid) async {
    _logger.info('Following user', {'subject': subjectDid});
    try {
      final response = await _api.call(
        'com.atproto.repo.createRecord',
        body: {
          'repo': actorDid,
          'collection': 'app.bsky.graph.follow',
          'record': {
            r'$type': 'app.bsky.graph.follow',
            'subject': subjectDid,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );

      final uri = response['uri'] as String;

      await _followsDao.upsertFollow(
        FollowsCompanion.insert(
          actorDid: actorDid,
          subjectDid: subjectDid,
          uri: uri,
          createdAt: Value(DateTime.now()),
        ),
      );

      _logger.debug('Created follow record', {'uri': uri});
      return uri;
    } catch (e, stack) {
      _logger.error('Failed to follow user', e, stack);
      rethrow;
    }
  }

  /// Unfollow a user by deleting the follow record.
  Future<void> unfollow(String actorDid, String followUri) async {
    _logger.info('Unfollowing user', {'uri': followUri});
    try {
      final parts = followUri.split('/');
      if (parts.length < 2) {
        throw ArgumentError('Invalid follow URI: $followUri');
      }
      final rkey = parts.last;

      await _api.call(
        'com.atproto.repo.deleteRecord',
        body: {'repo': actorDid, 'collection': 'app.bsky.graph.follow', 'rkey': rkey},
      );

      await _followsDao.deleteFollowByUri(followUri);

      _logger.debug('Deleted follow record', {'uri': followUri});
    } catch (e, stack) {
      _logger.error('Failed to unfollow user', e, stack);
      rethrow;
    }
  }

  /// Gets cached follow state for a user.
  Future<Follow?> getCachedFollow(String actorDid, String subjectDid) {
    return _followsDao.getFollow(actorDid, subjectDid);
  }

  /// Watches cached follow state for a user.
  Stream<Follow?> watchFollow(String actorDid, String subjectDid) {
    return _followsDao.watchFollow(actorDid, subjectDid);
  }

  /// Mutes a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  Future<void> muteActor(String actorDid, String subjectDid) async {
    _logger.info('Muting user', {'subject': subjectDid});
    try {
      await _api.call('app.bsky.graph.muteActor', body: {'actor': subjectDid});

      await _relationshipsDao.updateMuteStatus(subjectDid, true);
      _logger.debug('Muted user', {'subject': subjectDid});
    } catch (e, stack) {
      _logger.error('Failed to mute user', e, stack);
      rethrow;
    }
  }

  /// Unmutes a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  Future<void> unmuteActor(String actorDid, String subjectDid) async {
    _logger.info('Unmuting user', {'subject': subjectDid});
    try {
      await _api.call('app.bsky.graph.unmuteActor', body: {'actor': subjectDid});

      await _relationshipsDao.updateMuteStatus(subjectDid, false);
      _logger.debug('Unmuted user', {'subject': subjectDid});
    } catch (e, stack) {
      _logger.error('Failed to unmute user', e, stack);
      rethrow;
    }
  }

  /// Blocks a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  Future<String> blockActor(String actorDid, String subjectDid) async {
    _logger.info('Blocking user', {'subject': subjectDid});
    try {
      final response = await _api.call(
        'com.atproto.repo.createRecord',
        body: {
          'repo': actorDid,
          'collection': 'app.bsky.graph.block',
          'record': {
            r'$type': 'app.bsky.graph.block',
            'subject': subjectDid,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );

      final uri = response['uri'] as String;

      await _relationshipsDao.updateBlockStatus(subjectDid, true, blockingUri: uri);
      _logger.debug('Blocked user', {'subject': subjectDid, 'uri': uri});
      return uri;
    } catch (e, stack) {
      _logger.error('Failed to block user', e, stack);
      rethrow;
    }
  }

  /// Unblocks a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  /// [subjectDid] is optional but recommended to allow immediate local state update.
  Future<void> unblockActor(String actorDid, String blockUri, {String? subjectDid}) async {
    _logger.info('Unblocking user', {'uri': blockUri, 'subject': subjectDid});
    try {
      final parts = blockUri.split('/');
      if (parts.length < 2) {
        throw ArgumentError('Invalid block URI: $blockUri');
      }
      final rkey = parts.last;

      await _api.call(
        'com.atproto.repo.deleteRecord',
        body: {'repo': actorDid, 'collection': 'app.bsky.graph.block', 'rkey': rkey},
      );

      if (subjectDid != null) {
        await _relationshipsDao.updateBlockStatus(subjectDid, false);
      }

      _logger.debug('Deleted block record', {'uri': blockUri});
    } catch (e, stack) {
      _logger.error('Failed to unblock user', e, stack);
      rethrow;
    }
  }

  /// Reports a user or content.
  ///
  /// [reasonType] should be one of the supported AT Protocol report reasons.
  Future<void> createReport({
    required String reasonType,
    required String subjectDid,
    String? reason,
  }) async {
    _logger.info('Reporting user', {'subject': subjectDid, 'reasonType': reasonType});
    try {
      await _api.call(
        'com.atproto.moderation.createReport',
        body: {
          'reasonType': reasonType,
          'subject': {r'$type': 'com.atproto.admin.defs#repoRef', 'did': subjectDid},
          if (reason != null) 'reason': reason,
        },
      );
      _logger.debug('Reported user', {'subject': subjectDid});
    } catch (e, stack) {
      _logger.error('Failed to report user', e, stack);
      rethrow;
    }
  }

  /// Fetches a single post by URI.
  Future<FeedItem?> getPost(String uri) async {
    _logger.info('Fetching post', {'uri': uri});
    try {
      final response = await _api.call(
        'app.bsky.feed.getPosts',
        params: {
          'uris': [uri],
        },
      );

      final posts = response['posts'] as List?;
      if (posts == null || posts.isEmpty) return null;

      return FeedItem.fromPostView(posts.first as Map<String, dynamic>);
    } catch (e, stack) {
      _logger.error('Failed to fetch post', e, stack);
      rethrow;
    }
  }
}

class ProfileData {
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final viewer = json['viewer'] as Map<String, dynamic>?;
    final labels = json['labels'] as List?;

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
      pronouns: json['pronouns'] as String?,
      website: json['website'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      verificationStatus: json['verification']?['type'] as String?, // Assuming structure
      labels: labels?.cast<Map<String, dynamic>>(),
      pinnedPostUri: json['pinnedPost']?['uri'] as String?,
      viewerFollowing: viewer?['following'] != null,
      viewerFollowUri: viewer?['following'] as String?,
      viewerMuted: viewer?['muted'] as bool? ?? false,
      viewerBlockedBy: viewer?['blockedBy'] as bool? ?? false,
      viewerBlockingUri: viewer?['blocking'] as String?,
      viewerFollowedBy: viewer?['followedBy'] != null,
      viewerMutedByList: viewer?['mutedByList']?['uri'] as String?,
      viewerBlockingByList: viewer?['blockingByList']?['uri'] as String?,
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
    this.pronouns,
    this.website,
    this.createdAt,
    this.verificationStatus,
    this.labels,
    this.pinnedPostUri,
    this.viewerFollowing = false,
    this.viewerFollowUri,
    this.viewerMuted = false,
    this.viewerBlockedBy = false,
    this.viewerBlockingUri,
    this.viewerFollowedBy = false,
    this.viewerMutedByList,
    this.viewerBlockingByList,
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
  final String? pronouns;
  final String? website;
  final DateTime? createdAt;
  final String? verificationStatus;
  final List<Map<String, dynamic>>? labels;
  final String? pinnedPostUri;

  final bool viewerFollowing;
  final String? viewerFollowUri;
  final bool viewerMuted;
  final bool viewerBlockedBy;
  final String? viewerBlockingUri;
  final bool viewerFollowedBy;
  final String? viewerMutedByList;
  final String? viewerBlockingByList;

  String get displayNameOrHandle => displayName ?? handle;

  ProfileData copyWith({
    String? pronouns,
    String? website,
    DateTime? createdAt,
    String? verificationStatus,
    String? pinnedPostUri,
    bool? viewerFollowing,
    String? viewerFollowUri,
    bool? viewerMuted,
    bool? viewerBlockedBy,
    dynamic viewerBlockingUri = _sentinel, // Use dynamic to detect sentinel
  }) {
    return ProfileData(
      did: did,
      handle: handle,
      displayName: displayName,
      description: description,
      avatar: avatar,
      banner: banner,
      followersCount: followersCount,
      followsCount: followsCount,
      postsCount: postsCount,
      indexedAt: indexedAt,
      pronouns: pronouns ?? this.pronouns,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      labels: labels,
      pinnedPostUri: pinnedPostUri ?? this.pinnedPostUri,
      viewerFollowing: viewerFollowing ?? this.viewerFollowing,
      viewerFollowUri: viewerFollowUri ?? this.viewerFollowUri,
      viewerMuted: viewerMuted ?? this.viewerMuted,
      viewerBlockedBy: viewerBlockedBy ?? this.viewerBlockedBy,
      viewerBlockingUri: viewerBlockingUri == _sentinel
          ? this.viewerBlockingUri
          : viewerBlockingUri as String?,
      viewerFollowedBy: viewerFollowedBy,
      viewerMutedByList: viewerMutedByList,
      viewerBlockingByList: viewerBlockingByList,
    );
  }
}

const _sentinel = Object();

/// Result of fetching author feed.
class AuthorFeedResult {
  AuthorFeedResult({required this.items, this.cursor});

  final List<FeedItem> items;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// Result of fetching followers.
class FollowersResult {
  FollowersResult({required this.followers, this.cursor});

  final List<ActorBasic> followers;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// Result of fetching follows.
class FollowsResult {
  FollowsResult({required this.follows, this.cursor});

  final List<ActorBasic> follows;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// Basic actor information for follow lists.
class ActorBasic {
  factory ActorBasic.fromJson(Map<String, dynamic> json) {
    return ActorBasic(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  ActorBasic({required this.did, required this.handle, this.displayName, this.avatar});

  final String did;
  final String handle;
  final String? displayName;
  final String? avatar;

  /// Returns display name or handle.
  String get displayNameOrHandle => displayName ?? handle;
}

/// Represents a single feed item from author feed.
class FeedItem {
  factory FeedItem.fromPostView(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>;
    final record = json['record'] as Map<String, dynamic>;
    final embed = json['embed'] as Map<String, dynamic>?;
    final embedType = embed?[r'$type'] as String?;
    final hasImages =
        embedType == 'app.bsky.embed.images#view' ||
        embedType == 'app.bsky.embed.recordWithMedia#view' &&
            (embed?['media'] as Map<String, dynamic>?)?[r'$type'] == 'app.bsky.embed.images#view';
    final hasVideo = embedType == 'app.bsky.embed.video#view';
    final viewer = json['viewer'] as Map<String, dynamic>?;
    final isQuote = _isQuoteEmbed(embedType);

    return FeedItem(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      authorDid: author['did'] as String,
      authorHandle: author['handle'] as String,
      authorDisplayName: author['displayName'] as String?,
      authorAvatar: author['avatar'] as String?,
      text: record['text'] as String? ?? '',
      indexedAt: DateTime.tryParse(json['indexedAt'] as String? ?? ''),
      replyCount: json['replyCount'] as int? ?? 0,
      repostCount: json['repostCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      isReply: record['reply'] != null,
      hasImages: hasImages,
      hasVideo: hasVideo,
      embedType: embedType,
      record: record,
      embed: embed,
      viewerLikeUri: viewer?['like'] as String?,
      viewerRepostUri: viewer?['repost'] as String?,
      viewerBookmarked: viewer?['bookmarked'] as bool? ?? false,
      isQuote: isQuote,
    );
  }

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final post = json['post'] as Map<String, dynamic>;
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;
    final reply = record['reply'] as Map<String, dynamic>?;
    final isReply = reply != null;
    final embed = post['embed'] as Map<String, dynamic>?;
    final embedType = embed?[r'$type'] as String?;
    final hasImages =
        embedType == 'app.bsky.embed.images#view' ||
        embedType == 'app.bsky.embed.recordWithMedia#view' &&
            (embed?['media'] as Map<String, dynamic>?)?[r'$type'] == 'app.bsky.embed.images#view';
    final hasVideo = embedType == 'app.bsky.embed.video#view';
    final viewer = post['viewer'] as Map<String, dynamic>?;
    final reason = json['reason'] as Map<String, dynamic>?;
    final isRepost = (reason?[r'$type'] as String?)?.contains('reasonRepost') ?? false;
    final isQuote = _isQuoteEmbed(embedType);

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
      isReply: isReply,
      hasImages: hasImages,
      hasVideo: hasVideo,
      embedType: embedType,
      record: record,
      embed: embed,
      viewerLikeUri: viewer?['like'] as String?,
      viewerRepostUri: viewer?['repost'] as String?,
      viewerBookmarked: viewer?['bookmarked'] as bool? ?? false,
      isRepost: isRepost,
      isQuote: isQuote,
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
    this.isReply = false,
    this.hasImages = false,
    this.hasVideo = false,
    this.embedType,
    this.record,
    this.embed,
    this.viewerLikeUri,
    this.viewerRepostUri,
    this.viewerBookmarked = false,
    this.isRepost = false,
    this.isQuote = false,
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

  /// Whether this post is a reply to another post.
  final bool isReply;

  /// Whether this post has embedded images.
  final bool hasImages;

  /// Whether this post has embedded video.
  final bool hasVideo;

  /// The embed type string (e.g., 'app.bsky.embed.images#view').
  final String? embedType;

  /// The raw record map.
  final Map<String, dynamic>? record;

  /// The raw embed map.
  final Map<String, dynamic>? embed;

  /// URI if viewer has liked this post (non-null = liked).
  final String? viewerLikeUri;

  /// URI if viewer has reposted this post (non-null = reposted).
  final String? viewerRepostUri;

  /// Whether viewer has bookmarked this post.
  final bool viewerBookmarked;

  /// Whether this feed item is a repost of someone else's content.
  final bool isRepost;

  /// Whether this feed item quotes another record.
  final bool isQuote;

  /// Whether this post has any media (images or video).
  bool get hasMedia => hasImages || hasVideo;

  static bool _isQuoteEmbed(String? embedType) {
    if (embedType == null) return false;
    return embedType.startsWith('app.bsky.embed.record');
  }
}
