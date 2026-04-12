import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';

void main() {
  group('parseComposeRouteExtra', () {
    test('returns args unchanged when already ComposeRouteArgs', () {
      const args = ComposeRouteArgs(replyParentUri: 'at://parent', replyParentCid: 'cid-parent');

      final parsed = parseComposeRouteExtra(args);

      expect(parsed.replyParentUri, 'at://parent');
      expect(parsed.replyParentCid, 'cid-parent');
    });

    test('parses legacy map payload used by reply actions', () {
      final parsed = parseComposeRouteExtra({
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

    test('returns empty args for unsupported payload types', () {
      final parsed = parseComposeRouteExtra(42);

      expect(parsed.replyParentUri, isNull);
      expect(parsed.replyParentCid, isNull);
      expect(parsed.quoteUri, isNull);
      expect(parsed.initialText, isNull);
    });
  });
}
