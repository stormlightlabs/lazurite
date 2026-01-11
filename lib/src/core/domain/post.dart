import 'dart:convert';

import 'package:lazurite/src/infrastructure/db/app_database.dart' hide Post;
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';

/// Represents an author/profile in posts and feeds.
///
/// This is a lightweight domain model extracted from full profile data,
/// containing only the fields needed for displaying posts.
class Author {
  const Author({required this.did, required this.handle, this.displayName, this.avatar});

  /// Creates an Author from API JSON response.
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  /// Creates an Author from a database Profile.
  factory Author.fromProfile(Profile profile) {
    return Author(
      did: profile.did,
      handle: profile.handle,
      displayName: profile.displayName,
      avatar: profile.avatar,
    );
  }

  /// The decentralized identifier (DID) of the author.
  final String did;

  /// The handle (username) of the author.
  final String handle;

  /// The display name (may be null).
  final String? displayName;

  /// URL to the author's avatar image.
  final String? avatar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Author &&
          runtimeType == other.runtimeType &&
          did == other.did &&
          handle == other.handle &&
          displayName == other.displayName &&
          avatar == other.avatar;

  @override
  int get hashCode => Object.hash(did, handle, displayName, avatar);
}

/// Unified post domain model used across feeds, search, and profiles.
///
/// This consolidates the previously separate `SearchPostItem` and `FeedPost`
/// models into a single source of truth for post data.
class Post {
  const Post({
    required this.uri,
    required this.cid,
    required this.author,
    required this.text,
    this.indexedAt,
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
    this.embed,
    this.record,
    this.facets,
  });

  /// Creates a Post from API JSON response (e.g., searchPosts, getAuthorFeed).
  factory Post.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>;
    final recordJson = json['record'] as Map<String, dynamic>?;

    return Post(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      author: Author.fromJson(authorJson),
      text: recordJson?['text'] as String? ?? '',
      indexedAt: DateTime.tryParse(json['indexedAt'] as String? ?? ''),
      replyCount: json['replyCount'] as int? ?? 0,
      repostCount: json['repostCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      embed: json['embed'] as Map<String, dynamic>?,
      record: recordJson,
      facets: recordJson?['facets'] as List<dynamic>?,
    );
  }

  /// Creates a Post from a database FeedPost (join of Post + Profile).
  factory Post.fromFeedPost(FeedPost feedPost) {
    final post = feedPost.post;
    final profile = feedPost.author;

    Map<String, dynamic>? recordJson;
    try {
      recordJson = jsonDecode(post.record) as Map<String, dynamic>?;
    } catch (_) {
      recordJson = null;
    }

    Map<String, dynamic>? embedJson;
    if (post.embed != null) {
      try {
        embedJson = jsonDecode(post.embed!) as Map<String, dynamic>?;
      } catch (_) {
        embedJson = null;
      }
    }

    return Post(
      uri: post.uri,
      cid: post.cid,
      author: Author.fromProfile(profile),
      text: recordJson?['text'] as String? ?? '',
      indexedAt: post.indexedAt,
      replyCount: post.replyCount,
      repostCount: post.repostCount,
      likeCount: post.likeCount,
      embed: embedJson,
      record: recordJson,
    );
  }

  /// The AT URI of the post (at://did:plc:xxx/app.bsky.feed.post/yyy).
  final String uri;

  /// The CID (content identifier) of the post.
  final String cid;

  /// The author of the post.
  final Author author;

  /// The post text content.
  final String text;

  /// When the post was indexed.
  final DateTime? indexedAt;

  /// Number of replies to this post.
  final int replyCount;

  /// Number of reposts of this post.
  final int repostCount;

  /// Number of likes on this post.
  final int likeCount;

  /// Embedded content (images, video, external links, quoted posts).
  final Map<String, dynamic>? embed;

  /// The raw record data from the post.
  final Map<String, dynamic>? record;

  /// Rich text facets (mentions, links, hashtags).
  ///
  /// This is the raw JSON from the AT Protocol. Use [FacetHelper.parseFacets]
  /// to convert this to a list of [Facet] objects.
  final List<dynamic>? facets;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post && runtimeType == other.runtimeType && uri == other.uri && cid == other.cid;

  @override
  int get hashCode => Object.hash(uri, cid);
}
