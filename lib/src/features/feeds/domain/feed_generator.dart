import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_generator.freezed.dart';
part 'feed_generator.g.dart';

/// Represents a feed generator creator or basic actor profile.
@freezed
abstract class ActorBasic with _$ActorBasic {
  const factory ActorBasic({
    required String did,
    required String handle,
    String? displayName,
    String? avatar,
    String? description,
    DateTime? indexedAt,
    int? followersCount,
    int? followsCount,
    int? postsCount,
  }) = _ActorBasic;

  factory ActorBasic.fromJson(Map<String, dynamic> json) => _$ActorBasicFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ActorBasicToJson(this as _ActorBasic);
}

/// Represents feed generator metadata from app.bsky.feed.getFeedGenerator.
@freezed
abstract class FeedGenerator with _$FeedGenerator {
  const factory FeedGenerator({
    required String uri,
    required String cid,
    required String did,
    required ActorBasic creator,
    required String displayName,
    String? description,
    String? avatar,
    int? likeCount,
    DateTime? indexedAt,
  }) = _FeedGenerator;

  factory FeedGenerator.fromJson(Map<String, dynamic> json) => _$FeedGeneratorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FeedGeneratorToJson(this as _FeedGenerator);
}
