import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/threadgate_indicator.dart';

void main() {
  group('ThreadgateIndicator', () {
    testWidgets('renders restriction description', (tester) async {
      final threadgate = Threadgate(
        uri: 'at://did:example/app.bsky.feed.threadgate/abc',
        record: ThreadgateRecord(
          post: 'at://did:example/app.bsky.feed.post/123',
          allow: [
            {r'$type': 'app.bsky.feed.threadgate#mentionRule'},
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ThreadgateIndicator(threadgate: threadgate)),
        ),
      );

      expect(find.text('Replies limited to mentioned users'), findsOneWidget);
    });

    testWidgets('displays lock icon', (tester) async {
      final threadgate = Threadgate(uri: 'at://test/gate/1');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ThreadgateIndicator(threadgate: threadgate)),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      final threadgate = Threadgate(
        uri: 'at://test/gate/1',
        record: ThreadgateRecord(post: 'at://test/post/1', allow: []),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ThreadgateIndicator(threadgate: threadgate)),
        ),
      );

      final semantic = tester.getSemantics(find.byType(ThreadgateIndicator));
      expect(semantic.label, contains('Reply restriction'));
    });

    testWidgets('shows tooltip on hover/long press', (tester) async {
      final threadgate = Threadgate(
        uri: 'at://test/gate/1',
        record: ThreadgateRecord(
          post: 'at://test/post/1',
          allow: [
            {r'$type': 'app.bsky.feed.threadgate#followingRule'},
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ThreadgateIndicator(threadgate: threadgate)),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });
  });

  group('Threadgate', () {
    test('restrictionDescription returns correct text for mentionRule', () {
      final threadgate = Threadgate(
        uri: 'at://test/gate/1',
        record: ThreadgateRecord(
          post: 'at://test/post/1',
          allow: [
            {r'$type': 'app.bsky.feed.threadgate#mentionRule'},
          ],
        ),
      );

      expect(threadgate.restrictionDescription, 'Replies limited to mentioned users');
    });

    test('restrictionDescription returns correct text for followingRule', () {
      final threadgate = Threadgate(
        uri: 'at://test/gate/1',
        record: ThreadgateRecord(
          post: 'at://test/post/1',
          allow: [
            {r'$type': 'app.bsky.feed.threadgate#followingRule'},
          ],
        ),
      );

      expect(threadgate.restrictionDescription, 'Replies limited to accounts the author follows');
    });

    test('restrictionDescription returns correct text for listRule', () {
      final threadgate = Threadgate(
        uri: 'at://test/gate/1',
        record: ThreadgateRecord(
          post: 'at://test/post/1',
          allow: [
            {r'$type': 'app.bsky.feed.threadgate#listRule'},
          ],
        ),
      );

      expect(threadgate.restrictionDescription, 'Replies limited to list members');
    });

    test('restrictionDescription handles multiple rules', () {
      final threadgate = Threadgate(
        uri: 'at://test/gate/1',
        record: ThreadgateRecord(
          post: 'at://test/post/1',
          allow: [
            {r'$type': 'app.bsky.feed.threadgate#mentionRule'},
            {r'$type': 'app.bsky.feed.threadgate#followingRule'},
          ],
        ),
      );

      expect(
        threadgate.restrictionDescription,
        'Replies limited to mentioned users, accounts the author follows',
      );
    });

    test('restrictionDescription returns disabled for empty allow', () {
      final threadgate = Threadgate(
        uri: 'at://test/gate/1',
        record: ThreadgateRecord(post: 'at://test/post/1', allow: []),
      );

      expect(threadgate.restrictionDescription, 'Replies disabled');
    });

    test('restrictionDescription returns restricted for null record', () {
      final threadgate = Threadgate(uri: 'at://test/gate/1');

      expect(threadgate.restrictionDescription, 'Replies restricted');
    });

    test('fromJson parses threadgate correctly', () {
      final json = {
        'uri': 'at://did:test/app.bsky.feed.threadgate/123',
        'cid': 'bafytest123',
        'record': {
          'post': 'at://did:test/app.bsky.feed.post/456',
          'allow': [
            {r'$type': 'app.bsky.feed.threadgate#mentionRule'},
          ],
          'createdAt': '2024-01-01T00:00:00Z',
        },
        'lists': [
          {'uri': 'at://did:test/app.bsky.graph.list/789'},
        ],
      };

      final threadgate = Threadgate.fromJson(json);

      expect(threadgate.uri, 'at://did:test/app.bsky.feed.threadgate/123');
      expect(threadgate.cid, 'bafytest123');
      expect(threadgate.record, isNotNull);
      expect(threadgate.record!.post, 'at://did:test/app.bsky.feed.post/456');
      expect(threadgate.record!.allow.length, 1);
      expect(threadgate.lists.length, 1);
    });
  });
}
