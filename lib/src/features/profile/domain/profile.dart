import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/core/domain/post.dart';

part 'profile.freezed.dart';

@freezed
abstract class ProfileData with _$ProfileData {
  const factory ProfileData({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    String? avatar,
    String? banner,
    @Default(0) int followersCount,
    @Default(0) int followsCount,
    @Default(0) int postsCount,
    DateTime? indexedAt,
    String? pronouns,
    String? website,
    DateTime? createdAt,
    String? verificationStatus,
    List<Map<String, dynamic>>? labels,
    String? pinnedPostUri,
    @Default(false) bool viewerFollowing,
    String? viewerFollowUri,
    @Default(false) bool viewerMuted,
    @Default(false) bool viewerBlockedBy,
    String? viewerBlockingUri,
    @Default(false) bool viewerFollowedBy,
    String? viewerMutedByList,
    String? viewerBlockingByList,
  }) = _ProfileData;

  const ProfileData._();

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

  String get displayNameOrHandle => displayName ?? handle;
}

/// Result of fetching author feed.
@freezed
abstract class AuthorFeedResult with _$AuthorFeedResult {
  const factory AuthorFeedResult({required List<Post> items, String? cursor}) = _AuthorFeedResult;

  const AuthorFeedResult._();

  bool get hasMore => cursor != null;
}

/// Result of fetching followers.
@freezed
abstract class FollowersResult with _$FollowersResult {
  const factory FollowersResult({required List<Author> followers, String? cursor}) =
      _FollowersResult;

  const FollowersResult._();

  bool get hasMore => cursor != null;
}

/// Result of fetching follows.
@freezed
abstract class FollowsResult with _$FollowsResult {
  const factory FollowsResult({required List<Author> follows, String? cursor}) = _FollowsResult;

  const FollowsResult._();

  bool get hasMore => cursor != null;
}
