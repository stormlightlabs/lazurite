import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart' as db;

part 'post.freezed.dart';

/// Unified post domain model used across feeds, search, and profiles.
@freezed
abstract class Post with _$Post {
  const factory Post({
    required String uri,
    required String cid,
    required Author author,
    required String text,
    DateTime? indexedAt,
    @Default(0) int replyCount,
    @Default(0) int repostCount,
    @Default(0) int likeCount,
    Map<String, dynamic>? embed,
    Map<String, dynamic>? record,
    List<dynamic>? facets,
    String? viewerLikeUri,
    String? viewerRepostUri,
    @Default(false) bool viewerBookmarked,
    @Default(false) bool isReply,
    @Default(false) bool isRepost,
    @Default(false) bool isQuote,
    @Default(false) bool hasImages,
    @Default(false) bool hasVideo,
    String? embedType,
  }) = _Post;

  const Post._();

  factory Post.fromJson(Map<String, dynamic> json) {
    final postJson = json.containsKey('post') ? json['post'] as Map<String, dynamic> : json;
    final authorJson = postJson['author'] as Map<String, dynamic>;
    final recordJson = postJson['record'] as Map<String, dynamic>?;
    final embedJson = postJson['embed'] as Map<String, dynamic>?;
    final viewerJson = postJson['viewer'] as Map<String, dynamic>?;
    final reasonJson = json.containsKey('reason') ? json['reason'] as Map<String, dynamic>? : null;

    final embedType = embedJson?[r'$type'] as String?;
    final hasImages =
        embedType == 'app.bsky.embed.images#view' ||
        embedType == 'app.bsky.embed.recordWithMedia#view' &&
            (embedJson?['media'] as Map<String, dynamic>?)?[r'$type'] ==
                'app.bsky.embed.images#view';
    final hasVideo = embedType == 'app.bsky.embed.video#view';
    final isQuote = embedType != null && embedType.startsWith('app.bsky.embed.record');
    final isRepost = (reasonJson?[r'$type'] as String?)?.contains('reasonRepost') ?? false;

    return Post(
      uri: postJson['uri'] as String,
      cid: postJson['cid'] as String,
      author: Author.fromJson(authorJson),
      text: recordJson?['text'] as String? ?? '',
      indexedAt: DateTime.tryParse(postJson['indexedAt'] as String? ?? ''),
      replyCount: postJson['replyCount'] as int? ?? 0,
      repostCount: postJson['repostCount'] as int? ?? 0,
      likeCount: postJson['likeCount'] as int? ?? 0,
      embed: embedJson,
      record: recordJson,
      facets: recordJson?['facets'] as List<dynamic>?,
      viewerLikeUri: viewerJson?['like'] as String?,
      viewerRepostUri: viewerJson?['repost'] as String?,
      viewerBookmarked: viewerJson?['bookmarked'] as bool? ?? false,
      isReply: recordJson?['reply'] != null,
      isRepost: isRepost,
      isQuote: isQuote,
      hasImages: hasImages,
      hasVideo: hasVideo,
      embedType: embedType,
    );
  }

  /// Creates a Post from a database FeedPost (join of Post + Profile).
  factory Post.fromFeedPost(db.FeedPost feedPost) {
    final post = feedPost.post;
    final profile = feedPost.author;
    final recordJson = jsonDecode(post.record) as Map<String, dynamic>;

    return Post(
      uri: post.uri,
      cid: post.cid,
      author: Author.fromProfile(profile),
      text: recordJson['text'] as String? ?? '',
      indexedAt: post.indexedAt,
      replyCount: post.replyCount,
      repostCount: post.repostCount,
      likeCount: post.likeCount,
      record: recordJson,
      embed: post.embed != null ? jsonDecode(post.embed!) as Map<String, dynamic> : null,
      viewerLikeUri: post.viewerLikeUri,
      viewerRepostUri: post.viewerRepostUri,
      viewerBookmarked: post.viewerBookmarked,
    );
  }

  bool get hasMedia => hasImages || hasVideo;
}
