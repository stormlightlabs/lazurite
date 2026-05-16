import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';

void main() {
  group('PoptartCacheCodecs', () {
    test('round-trips feed view posts through cache strings', () {
      final post = _feedViewPost();

      final encoded = PoptartCacheCodecs.feedViewPost.encode(post);
      final decoded = PoptartCacheCodecs.feedViewPost.decode(encoded);

      expect(decoded.post.uri.toString(), post.post.uri.toString());
      expect(decoded.post.cid, post.post.cid);
      expect(decoded.post.author.handle, post.post.author.handle);
    });

    test('decodes saved post JSON and liked feed JSON as FeedViewPost', () {
      final post = _feedViewPost();
      final postViewJson = PoptartCacheCodecs.postView.encode(post.post);
      final feedViewPostJson = PoptartCacheCodecs.feedViewPost.encode(post);

      final decodedSaved = PoptartCacheCodecs.decodeSavedOrLikedPost(postViewJson);
      final decodedLiked = PoptartCacheCodecs.decodeSavedOrLikedPost(feedViewPostJson);

      expect(decodedSaved.post.uri.toString(), post.post.uri.toString());
      expect(decodedLiked.post.uri.toString(), post.post.uri.toString());
    });

    test('round-trips moderation preferences as a JSON string list', () {
      final preferences = [const UPreferences.adultContentPref(data: AdultContentPref(enabled: true))];

      final encoded = PoptartCacheCodecs.encodeModerationPreferences(preferences);
      final decoded = PoptartCacheCodecs.decodeModerationPreferences(encoded);

      expect(decoded.single.isAdultContentPref, isTrue);
      expect(decoded.single.adultContentPref!.enabled, isTrue);
    });

    test('round-trips feed page cursor metadata without exposing raw maps', () {
      final encoded = PoptartCacheCodecs.encodeFeedPageMetadata(cursor: 'next', lastRequestCursor: 'previous');

      expect(PoptartCacheCodecs.decodeFeedPageCursor(encoded), 'next');
    });
  });
}

FeedViewPost _feedViewPost() {
  return FeedViewPost(
    post: PostView(
      uri: const AtUri('at://did:plc:author/app.bsky.feed.post/abc'),
      cid: 'cid-123',
      author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
      record: {
        r'$type': 'app.bsky.feed.post',
        'text': 'Hello typed cache',
        'createdAt': DateTime.utc(2026, 5, 12).toIso8601String(),
      },
      indexedAt: DateTime.utc(2026, 5, 12),
    ),
  );
}
