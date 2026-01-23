import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/conversation_list_item.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ConversationListItem', () {
    final now = DateTime.now();
    final conversation = DmConversation(
      convoId: '123',
      members: [
        const Author(did: 'did:web:alice', handle: 'alice.bsky.social', displayName: 'Alice'),
        const Author(did: 'did:web:bob', handle: 'bob.bsky.social', displayName: 'Bob'),
      ],
      lastMessageText: 'Hello',
      lastMessageAt: now,
      unreadCount: 0,
      isAccepted: true,
      isMuted: false,
    );

    testWidgets('renders other party info', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: ConversationListItem(conversation: conversation, onTap: () {}),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders unread count badge', (tester) async {
      final unreadConversation = conversation.copyWith(unreadCount: 5);
      await tester.pumpApp(
        Scaffold(
          body: ConversationListItem(conversation: unreadConversation, onTap: () {}),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders request tag if not accepted', (tester) async {
      final requestConversation = conversation.copyWith(isAccepted: false);
      await tester.pumpApp(
        Scaffold(
          body: ConversationListItem(conversation: requestConversation, onTap: () {}),
        ),
      );

      expect(find.text('Request'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        Scaffold(
          body: ConversationListItem(conversation: conversation, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(ConversationListItem));
      expect(tapped, isTrue);
    });
  });
}
