/// An actor (user) from search results.
class SearchActorItem {
  SearchActorItem({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.followersCount = 0,
    this.followsCount = 0,
    this.indexedAt,
    this.allowIncoming,
  });

  factory SearchActorItem.fromJson(Map<String, dynamic> json) {
    final did = json['did'];
    final handle = json['handle'];

    if (did is! String || did.isEmpty) {
      throw FormatException('SearchActorItem.did must be a non-empty string', json);
    }
    if (handle is! String || handle.isEmpty) {
      throw FormatException('SearchActorItem.handle must be a non-empty string', json);
    }

    return SearchActorItem(
      did: did,
      handle: handle,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followsCount: json['followsCount'] as int? ?? 0,
      indexedAt: DateTime.tryParse(json['indexedAt'] as String? ?? ''),
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

  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final int followersCount;
  final int followsCount;
  final DateTime? indexedAt;
  final String? allowIncoming;
}
