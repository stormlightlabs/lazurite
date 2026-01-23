import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/message_request_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('MessageRequestCard', () {
    final now = DateTime.now();
    const profile = Author(
      did: 'did:web:alice',
      handle: 'alice.bsky.social',
      displayName: 'Alice',
    );
    final conversation = DmConversation(
      convoId: '123',
      members: [profile],
      lastMessageText: 'Hello, is this a scam?',
      lastMessageAt: now,
      unreadCount: 1,
      isAccepted: false,
      isMuted: false,
    );

    testWidgets('renders sender display name', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(conversation: conversation, onAccept: () {}, onDecline: () {}),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders sender handle', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(conversation: conversation, onAccept: () {}, onDecline: () {}),
        ),
      );

      expect(find.text('@alice.bsky.social'), findsOneWidget);
    });

    testWidgets('renders message preview', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(conversation: conversation, onAccept: () {}, onDecline: () {}),
        ),
      );

      expect(find.text('Hello, is this a scam?'), findsOneWidget);
    });

    testWidgets('renders accept and decline buttons', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(conversation: conversation, onAccept: () {}, onDecline: () {}),
        ),
      );

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('calls onAccept when accept button tapped', (tester) async {
      bool accepted = false;
      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(
            conversation: conversation,
            onAccept: () => accepted = true,
            onDecline: () {},
          ),
        ),
      );

      await tester.tap(find.text('Accept'));
      expect(accepted, isTrue);
    });

    testWidgets('calls onDecline when decline button tapped', (tester) async {
      bool declined = false;
      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(
            conversation: conversation,
            onAccept: () {},
            onDecline: () => declined = true,
          ),
        ),
      );

      await tester.tap(find.text('Decline'));
      expect(declined, isTrue);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(
            conversation: conversation,
            onAccept: () {},
            onDecline: () {},
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Alice'));
      expect(tapped, isTrue);
    });

    testWidgets('uses handle when display name is null', (tester) async {
      const profileNoName = Author(did: 'did:web:bob', handle: 'bob.bsky.social');
      final convoNoName = conversation.copyWith(members: [profileNoName]);

      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(conversation: convoNoName, onAccept: () {}, onDecline: () {}),
        ),
      );

      expect(find.text('bob.bsky.social'), findsOneWidget);
      expect(find.text('@bob.bsky.social'), findsOneWidget);
    });

    testWidgets('does not render message preview when null', (tester) async {
      final noMessage = DmConversation(
        convoId: '456',
        members: [profile],
        lastMessageText: null,
        lastMessageAt: now,
        unreadCount: 0,
        isAccepted: false,
        isMuted: false,
      );

      await tester.pumpApp(
        Scaffold(
          body: MessageRequestCard(conversation: noMessage, onAccept: () {}, onDecline: () {}),
        ),
      );

      expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
    });
  });
}
