/// Domain model for profile data.
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
      verificationStatus: json['verification']?['type'] as String?,
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
    bool? viewerFollowedBy,
    dynamic viewerBlockingUri = _sentinel,
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
      viewerFollowedBy: viewerFollowedBy ?? this.viewerFollowedBy,
      viewerMutedByList: viewerMutedByList,
      viewerBlockingByList: viewerBlockingByList,
    );
  }
}

const _sentinel = Object();

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

  final bool isReply;
  final bool hasImages;
  final bool hasVideo;
  final String? embedType;
  final Map<String, dynamic>? record;
  final Map<String, dynamic>? embed;
  final String? viewerLikeUri;
  final String? viewerRepostUri;
  final bool viewerBookmarked;
  final bool isRepost;
  final bool isQuote;

  bool get hasMedia => hasImages || hasVideo;

  static bool _isQuoteEmbed(String? embedType) {
    if (embedType == null) return false;
    return embedType.startsWith('app.bsky.embed.record');
  }
}

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
