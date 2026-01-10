import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
import 'package:lazurite/src/features/thread/domain/thread_layout_calculator.dart';

void main() {
  group('ThreadLayoutCalculator', () {
    group('calculateIndent', () {
      test('returns 0 for depth 0', () {
        expect(ThreadLayoutCalculator.calculateIndent(0), 0.0);
      });

      test('calculates indent for various depths', () {
        expect(ThreadLayoutCalculator.calculateIndent(1), 32.0);
        expect(ThreadLayoutCalculator.calculateIndent(2), 64.0);
        expect(ThreadLayoutCalculator.calculateIndent(3), 96.0);
        expect(ThreadLayoutCalculator.calculateIndent(4), 128.0);
        expect(ThreadLayoutCalculator.calculateIndent(5), 160.0);
      });

      test('clamps indent at maxDepth', () {
        expect(ThreadLayoutCalculator.calculateIndent(6), 160.0);
        expect(ThreadLayoutCalculator.calculateIndent(10), 160.0);
        expect(ThreadLayoutCalculator.calculateIndent(100), 160.0);
      });

      test('handles negative depth gracefully', () {
        expect(ThreadLayoutCalculator.calculateIndent(-1), 0.0);
        expect(ThreadLayoutCalculator.calculateIndent(-10), 0.0);
      });
    });

    group('calculateConnectorLeft', () {
      test('positions connector at avatar center for depth 0', () {
        expect(
          ThreadLayoutCalculator.calculateConnectorLeft(0),
          20.0, // 0 + avatarCenterOffset
        );
      });

      test('calculates connector position relative to indent', () {
        expect(
          ThreadLayoutCalculator.calculateConnectorLeft(1),
          52.0, // 32 + 20
        );
        expect(
          ThreadLayoutCalculator.calculateConnectorLeft(2),
          84.0, // 64 + 20
        );
        expect(
          ThreadLayoutCalculator.calculateConnectorLeft(3),
          116.0, // 96 + 20
        );
      });

      test('clamps connector position at maxDepth', () {
        final maxConnectorLeft = ThreadLayoutCalculator.calculateConnectorLeft(
          ThreadLayoutCalculator.maxDepth,
        );
        expect(ThreadLayoutCalculator.calculateConnectorLeft(10), maxConnectorLeft);
      });
    });

    group('shouldFlattenDepth', () {
      test('returns false for depths within maxDepth', () {
        expect(ThreadLayoutCalculator.shouldFlattenDepth(0), false);
        expect(ThreadLayoutCalculator.shouldFlattenDepth(3), false);
        expect(ThreadLayoutCalculator.shouldFlattenDepth(5), false);
      });

      test('returns true for depths exceeding maxDepth', () {
        expect(ThreadLayoutCalculator.shouldFlattenDepth(6), true);
        expect(ThreadLayoutCalculator.shouldFlattenDepth(10), true);
        expect(ThreadLayoutCalculator.shouldFlattenDepth(100), true);
      });
    });

    group('calculateEffectiveDepth', () {
      test('returns actual depth when within bounds', () {
        expect(ThreadLayoutCalculator.calculateEffectiveDepth(0), 0);
        expect(ThreadLayoutCalculator.calculateEffectiveDepth(3), 3);
        expect(ThreadLayoutCalculator.calculateEffectiveDepth(5), 5);
      });

      test('clamps to maxDepth when exceeding', () {
        expect(ThreadLayoutCalculator.calculateEffectiveDepth(6), ThreadLayoutCalculator.maxDepth);
        expect(
          ThreadLayoutCalculator.calculateEffectiveDepth(10),
          ThreadLayoutCalculator.maxDepth,
        );
      });

      test('clamps to 0 for negative depths', () {
        expect(ThreadLayoutCalculator.calculateEffectiveDepth(-1), 0);
      });
    });

    group('getParentContext', () {
      test('returns empty string when no parent', () {
        final post = _createThreadViewPost(handle: 'user1');
        expect(ThreadLayoutCalculator.getParentContext(post), '');
      });

      test('returns parent handle with @ prefix', () {
        final parent = _createThreadViewPost(handle: 'parentuser');
        final post = _createThreadViewPost(handle: 'user1', parent: parent);
        expect(ThreadLayoutCalculator.getParentContext(post), '@parentuser');
      });
    });

    group('countAllReplies', () {
      test('returns 0 for post with no replies', () {
        final post = _createThreadViewPost(handle: 'user1');
        expect(ThreadLayoutCalculator.countAllReplies(post), 0);
      });

      test('counts direct replies', () {
        final post = _createThreadViewPost(
          handle: 'user1',
          replies: [
            _createThreadViewPost(handle: 'reply1'),
            _createThreadViewPost(handle: 'reply2'),
            _createThreadViewPost(handle: 'reply3'),
          ],
        );
        expect(ThreadLayoutCalculator.countAllReplies(post), 3);
      });

      test('counts nested replies recursively', () {
        final post = _createThreadViewPost(
          handle: 'user1',
          replies: [
            _createThreadViewPost(
              handle: 'reply1',
              replies: [
                _createThreadViewPost(handle: 'nested1'),
                _createThreadViewPost(handle: 'nested2'),
              ],
            ),
            _createThreadViewPost(
              handle: 'reply2',
              replies: [_createThreadViewPost(handle: 'nested3')],
            ),
          ],
        );

        expect(ThreadLayoutCalculator.countAllReplies(post), 5);
      });

      test('counts deeply nested replies', () {
        final deepPost = _createThreadViewPost(
          handle: 'root',
          replies: [
            _createThreadViewPost(
              handle: 'level1',
              replies: [
                _createThreadViewPost(
                  handle: 'level2',
                  replies: [
                    _createThreadViewPost(
                      handle: 'level3',
                      replies: [_createThreadViewPost(handle: 'level4')],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        expect(ThreadLayoutCalculator.countAllReplies(deepPost), 4);
      });
    });
  });
}

/// Helper to create test ThreadViewPost instances
ThreadViewPost _createThreadViewPost({
  required String handle,
  ThreadViewPost? parent,
  List<ThreadViewPost>? replies,
}) {
  return ThreadViewPost(
    post: ThreadPost(
      uri: 'at://$handle/post',
      cid: 'cid-$handle',
      author: ThreadAuthor(did: 'did:$handle', handle: handle),
      record: {'text': 'Test post'},
    ),
    parent: parent,
    replies: replies ?? [],
  );
}
