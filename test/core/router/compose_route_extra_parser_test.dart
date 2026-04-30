import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';

void main() {
  group('ComposeRouteArgs.parseExtra', () {
    test('returns args unchanged when already ComposeRouteArgs', () {
      const args = ComposeRouteArgs(replyParentUri: 'at://parent', replyParentCid: 'cid-parent');

      final parsed = ComposeRouteArgs.parseExtra(args);

      expect(parsed.replyParentUri, 'at://parent');
      expect(parsed.replyParentCid, 'cid-parent');
    });

    test('parses legacy map payload used by reply actions', () {
      final parsed = ComposeRouteArgs.parseExtra({
        'replyParentUri': 'at://parent',
        'replyParentCid': 'cid-parent',
        'replyRootUri': 'at://root',
        'replyRootCid': 'cid-root',
        'replyAuthorHandle': 'alice.bsky.social',
      });

      expect(parsed.replyParentUri, 'at://parent');
      expect(parsed.replyParentCid, 'cid-parent');
      expect(parsed.replyRootUri, 'at://root');
      expect(parsed.replyRootCid, 'cid-root');
      expect(parsed.replyAuthorHandle, 'alice.bsky.social');
    });

    test('parses edit context fields from map payload', () {
      final parsed = ComposeRouteArgs.parseExtra({
        'initialText': 'updated post',
        'editPostUri': 'at://did:plc:test/app.bsky.feed.post/abc123',
        'editPostCid': 'cid-123',
        'editRecord': {r'$type': 'app.bsky.feed.post', 'text': 'old post', 'createdAt': '2026-04-14T10:00:00.000Z'},
      });

      expect(parsed.initialText, 'updated post');
      expect(parsed.editPostUri, 'at://did:plc:test/app.bsky.feed.post/abc123');
      expect(parsed.editPostCid, 'cid-123');
      expect(parsed.editRecord, isNotNull);
      expect(parsed.editRecord!['text'], 'old post');
    });

    test('returns empty args for unsupported payload types', () {
      final parsed = ComposeRouteArgs.parseExtra(42);

      expect(parsed.replyParentUri, isNull);
      expect(parsed.replyParentCid, isNull);
      expect(parsed.quoteUri, isNull);
      expect(parsed.initialText, isNull);
    });
  });
}
