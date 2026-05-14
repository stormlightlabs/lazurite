import 'dart:convert';

import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/labeler/defs.dart';

class JsonStringCacheCodec<T> {
  const JsonStringCacheCodec({required this.encode, required this.decode});

  final String Function(T value) encode;
  final T Function(String payload) decode;
}

class PoptartCacheCodecs {
  const PoptartCacheCodecs._();

  static final profileViewDetailed = JsonStringCacheCodec<ProfileViewDetailed>(
    encode: (profile) => jsonEncode(profile.toJson()),
    decode: (payload) => ProfileViewDetailed.fromJson(_decodeObject(payload)),
  );

  static final postView = JsonStringCacheCodec<PostView>(
    encode: (post) => jsonEncode(post.toJson()),
    decode: (payload) => PostView.fromJson(_decodeObject(payload)),
  );

  static final feedViewPost = JsonStringCacheCodec<FeedViewPost>(
    encode: (post) => jsonEncode(post.toJson()),
    decode: (payload) => FeedViewPost.fromJson(_decodeObject(payload)),
  );

  static final threadViewPost = JsonStringCacheCodec<ThreadViewPost>(
    encode: (thread) => jsonEncode(thread.toJson()),
    decode: (payload) => ThreadViewPost.fromJson(_decodeObject(payload)),
  );

  static final labelerPolicies = JsonStringCacheCodec<LabelerPolicies>(
    encode: (policies) => jsonEncode(policies.toJson()),
    decode: (payload) => LabelerPolicies.fromJson(_decodeObject(payload)),
  );

  static String encodeModerationPreferences(List<UPreferences> preferences) {
    return jsonEncode(preferences.map((preference) => preference.toJson()).toList());
  }

  static List<UPreferences> decodeModerationPreferences(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      throw FormatException('Expected cached moderation preferences to be a JSON list.', payload);
    }
    return decoded
        .map((json) => const UPreferencesConverter().fromJson(Map<String, dynamic>.from(json as Map)))
        .toList(growable: false);
  }

  static String encodeFeedPageMetadata({String? cursor, String? lastRequestCursor}) {
    return jsonEncode({'cursor': cursor, 'lastRequestCursor': lastRequestCursor});
  }

  static String? decodeFeedPageCursor(String payload) {
    return _decodeObject(payload)['cursor'] as String?;
  }

  static FeedViewPost decodeSavedOrLikedPost(String payload) {
    final decoded = _decodeObject(payload);
    if (decoded['post'] is Map) {
      return FeedViewPost.fromJson(decoded);
    }
    return FeedViewPost(post: PostView.fromJson(decoded));
  }

  static PostView decodeSavedOrLikedPostView(String payload) => decodeSavedOrLikedPost(payload).post;

  static Map<String, dynamic> _decodeObject(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map) {
      throw FormatException('Expected cached payload to be a JSON object.', payload);
    }
    return Map<String, dynamic>.from(decoded);
  }
}
