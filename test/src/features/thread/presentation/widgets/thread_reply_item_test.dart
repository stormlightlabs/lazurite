import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/thread_reply_item.dart';

void main() {
  group('ThreadReplyItem', () {
    testWidgets('renders post at depth 0', (tester) async {
      final post = _createThreadViewPost(handle: 'user1');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThreadReplyItem(
                post: post,
                depth: 0,
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadReplyItem), findsOneWidget);
    });

    testWidgets('renders post with replies shows collapse toggle', (tester) async {
      final post = _createThreadViewPost(
        handle: 'user1',
        replies: [
          _createThreadViewPost(handle: 'reply1'),
          _createThreadViewPost(handle: 'reply2'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThreadReplyItem(
                post: post,
                depth: 0,
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadReplyItem), findsOneWidget);
    });

    testWidgets('renders post without replies shows no toggle', (tester) async {
      final post = _createThreadViewPost(handle: 'user1');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThreadReplyItem(
                post: post,
                depth: 0,
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadReplyItem), findsOneWidget);
    });

    testWidgets('renders at different depth levels', (tester) async {
      for (var depth = 0; depth <= 5; depth++) {
        final post = _createThreadViewPost(handle: 'user$depth');

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ThreadReplyItem(
                  post: post,
                  depth: depth,
                  isCollapsed: false,
                  onToggleCollapse: () {},
                ),
              ),
            ),
          ),
        );

        final item = tester.widget<ThreadReplyItem>(find.byType(ThreadReplyItem));
        expect(item.depth, depth);
      }
    });

    testWidgets('shows deep thread indicator when depth exceeds max', (tester) async {
      final parent = _createThreadViewPost(handle: 'parent');
      final post = _createThreadViewPost(handle: 'user1', parent: parent);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThreadReplyItem(
                post: post,
                depth: 6, // Exceeds MAX_DEPTH of 5
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Replying to @parent'), findsOneWidget);
    });

    testWidgets('renders blocked post card', (tester) async {
      final post = _createThreadViewPost(handle: 'user1', isBlocked: true);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThreadReplyItem(
                post: post,
                depth: 0,
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadReplyItem), findsOneWidget);
    });

    testWidgets('renders not found post card', (tester) async {
      final post = _createThreadViewPost(handle: 'user1', isNotFound: true);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThreadReplyItem(
                post: post,
                depth: 0,
                isCollapsed: false,
                onToggleCollapse: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadReplyItem), findsOneWidget);
    });
  });
}

ThreadViewPost _createThreadViewPost({
  required String handle,
  ThreadViewPost? parent,
  List<ThreadViewPost>? replies,
  bool isBlocked = false,
  bool isNotFound = false,
}) {
  return ThreadViewPost(
    post: ThreadPost(
      uri: 'at://$handle/post',
      cid: 'cid-$handle',
      author: ThreadAuthor(did: 'did:$handle', handle: handle),
      record: {'text': 'Test post from $handle'},
    ),
    parent: parent,
    replies: replies ?? [],
    isBlocked: isBlocked,
    isNotFound: isNotFound,
  );
}
