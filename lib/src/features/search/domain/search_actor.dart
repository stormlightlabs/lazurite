import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_actor.freezed.dart';

/// An actor (user) from search results.
@freezed
abstract class SearchActorItem with _$SearchActorItem {
  const factory SearchActorItem({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    String? avatar,
    @Default(0) int followersCount,
    @Default(0) int followsCount,
    DateTime? indexedAt,
    String? allowIncoming,
  }) = _SearchActorItem;

  const SearchActorItem._();

  factory SearchActorItem.fromJson(Map<String, dynamic> json) {
    if (json['did'] is! String || (json['did'] as String).isEmpty) {
      throw FormatException('SearchActorItem.did must be a non-empty string', json);
    }
    if (json['handle'] is! String || (json['handle'] as String).isEmpty) {
      throw FormatException('SearchActorItem.handle must be a non-empty string', json);
    }

    return SearchActorItem(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followsCount: json['followsCount'] as int? ?? 0,
      indexedAt: json['indexedAt'] != null ? DateTime.tryParse(json['indexedAt'] as String) : null,
      allowIncoming: _parseAllowIncoming(json),
    );
  }

  static String? _parseAllowIncoming(Map<String, dynamic> json) {
    final associated = json['associated'];
    if (associated is Map<String, dynamic>) {
      final chat = associated['chat'];
      if (chat is Map<String, dynamic>) {
        return chat['allowIncoming'] as String?;
      }
    }
    return null;
  }
}
