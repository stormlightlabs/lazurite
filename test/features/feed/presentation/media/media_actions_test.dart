import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/presentation/media/media_actions.dart';

void main() {
  group('MediaActions.buildBlueskyBlobDownloadUrl', () {
    test('builds blob URL from watch playlist URL', () {
      final result = MediaActions.buildBlueskyBlobDownloadUrl(
        playlistUrl: 'https://video.bsky.app/watch/did%3Aplc%3Aabc123/bafkreixyz987/playlist.m3u8',
      );

      expect(result, 'https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did%3Aplc%3Aabc123&cid=bafkreixyz987');
    });

    test('builds blob URL from hls playlist URL', () {
      final result = MediaActions.buildBlueskyBlobDownloadUrl(
        playlistUrl: 'https://video.cdn.bsky.app/hls/did%3Aplc%3Aabc123/bafkreixyz987/playlist.m3u8',
      );

      expect(result, 'https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did%3Aplc%3Aabc123&cid=bafkreixyz987');
    });

    test('returns null when URL does not contain did and cid segments', () {
      final result = MediaActions.buildBlueskyBlobDownloadUrl(playlistUrl: 'https://example.com/video/playlist.m3u8');

      expect(result, isNull);
    });
  });
}
