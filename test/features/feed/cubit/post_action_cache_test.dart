import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';

void main() {
  const postUri = 'at://did:plc:test/app.bsky.feed.post/abc';
  const likeUri = 'at://did:plc:test/app.bsky.feed.like/like1';
  const repostUri = 'at://did:plc:test/app.bsky.feed.repost/rp1';

  group('PostActionCache', () {
    test('read returns null when nothing cached', () {
      final cache = PostActionCache();
      expect(cache.read(postUri), isNull);
    });

    test('write then read returns cached values', () {
      final cache = PostActionCache();
      const state = PostActionState(
        postUri: postUri,
        isLiked: true,
        isReposted: false,
        likeCount: 3,
        repostCount: 1,
        likeUri: likeUri,
        repostUri: null,
      );

      cache.write(state);
      final cached = cache.read(postUri);

      expect(cached, isNotNull);
      expect(cached!.isLiked, isTrue);
      expect(cached.isReposted, isFalse);
      expect(cached.likeCount, 3);
      expect(cached.repostCount, 1);
      expect(cached.likeUri, likeUri);
      expect(cached.repostUri, isNull);
    });

    test('write ignores states with isLoadingLike true', () {
      final cache = PostActionCache();
      const state = PostActionState(postUri: postUri, isLiked: true, likeCount: 5, isLoadingLike: true);

      cache.write(state);

      expect(cache.read(postUri), isNull);
    });

    test('write ignores states with isLoadingRepost true', () {
      final cache = PostActionCache();
      const state = PostActionState(postUri: postUri, isReposted: true, repostCount: 2, isLoadingRepost: true);

      cache.write(state);

      expect(cache.read(postUri), isNull);
    });

    test('write overwrites existing entry', () {
      final cache = PostActionCache();

      cache.write(const PostActionState(postUri: postUri, isLiked: false, likeCount: 0));
      cache.write(const PostActionState(postUri: postUri, isLiked: true, likeCount: 1, likeUri: likeUri));

      final cached = cache.read(postUri);
      expect(cached!.isLiked, isTrue);
      expect(cached.likeCount, 1);
      expect(cached.likeUri, likeUri);
    });

    test('caches multiple posts independently', () {
      const otherUri = 'at://did:plc:test/app.bsky.feed.post/other';
      final cache = PostActionCache();

      cache.write(const PostActionState(postUri: postUri, isLiked: true, likeCount: 5, likeUri: likeUri));
      cache.write(const PostActionState(postUri: otherUri, isReposted: true, repostCount: 2, repostUri: repostUri));

      expect(cache.read(postUri)!.isLiked, isTrue);
      expect(cache.read(postUri)!.isReposted, isFalse);
      expect(cache.read(otherUri)!.isReposted, isTrue);
      expect(cache.read(otherUri)!.isLiked, isFalse);
    });
  });
}
