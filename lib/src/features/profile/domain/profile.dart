import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/core/domain/content_label.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

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
    DateTime? createdAt,
    String? pronouns,
    String? website,
    @JsonKey(name: 'verification', fromJson: _parseVerification) String? verificationStatus,
    @JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost) String? pinnedPostUri,
    ActorViewer? viewer,
    List<ContentLabel>? labels,
  }) = _ProfileData;

  const ProfileData._();

  factory ProfileData.fromJson(Map<String, dynamic> json) => _$ProfileDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProfileDataToJson(this as _ProfileData);

  String get displayNameOrHandle => displayName ?? handle;

  // Proxy getters for UI compatibility
  bool get viewerFollowing => viewer?.following != null;
  String? get viewerFollowUri => viewer?.following;
  bool get viewerMuted => viewer?.muted ?? false;
  bool get viewerBlockedBy => viewer?.blockedBy ?? false;
  String? get viewerBlockingUri => viewer?.blocking;
  bool get viewerFollowedBy => viewer?.followedBy != null;
  String? get viewerMutedByList => viewer?.mutedByList;
  String? get viewerBlockingByList => viewer?.blockingByList;
}

String? _parseVerification(Object? json) {
  if (json is Map<String, dynamic>) {
    return json['type'] as String?;
  }
  return null;
}

String? _parsePinnedPost(Object? json) {
  if (json is Map<String, dynamic>) {
    return json['uri'] as String?;
  }
  return null;
}

/// Result of fetching author feed.
@freezed
abstract class AuthorFeedResult with _$AuthorFeedResult {
  const factory AuthorFeedResult({required List<Post> items, String? cursor}) = _AuthorFeedResult;

  const AuthorFeedResult._();

  factory AuthorFeedResult.fromJson(Map<String, dynamic> json) => _$AuthorFeedResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthorFeedResultToJson(this as _AuthorFeedResult);

  bool get hasMore => cursor != null;
}

/// Result of fetching followers.
@freezed
abstract class FollowersResult with _$FollowersResult {
  const factory FollowersResult({required List<Author> followers, String? cursor}) =
      _FollowersResult;

  const FollowersResult._();

  factory FollowersResult.fromJson(Map<String, dynamic> json) => _$FollowersResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FollowersResultToJson(this as _FollowersResult);

  bool get hasMore => cursor != null;
}

/// Result of fetching follows.
@freezed
abstract class FollowsResult with _$FollowsResult {
  const factory FollowsResult({required List<Author> follows, String? cursor}) = _FollowsResult;

  const FollowsResult._();

  factory FollowsResult.fromJson(Map<String, dynamic> json) => _$FollowsResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FollowsResultToJson(this as _FollowsResult);

  bool get hasMore => cursor != null;
}
