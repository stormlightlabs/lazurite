import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/dms/domain/dm_message.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/message_bubble.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

void main() {
  group('MessageBubble', () {
    late Profile testProfile;

    setUp(() {
      testProfile = const Profile(
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        displayName: 'Test User',
        avatar: null,
      );
    });

    AppDmMessage createMessage({
      MessageStatus status = MessageStatus.sent,
      String content = 'Hello world',
      bool isFromMe = false,
    }) {
      return AppDmMessage(
        messageId: 'msg-123',
        convoId: 'convo-456',
        sender: testProfile,
        content: content,
        sentAt: DateTime.now(),
        status: status,
      );
    }

    testWidgets('renders sent message aligned to the right', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubble(message: createMessage(), isFromMe: true)),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.end);

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('renders received message aligned to the left', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: createMessage(),
              isFromMe: false,
              senderProfile: testProfile,
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.start);

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('shows delivery status indicator for sent messages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: createMessage(status: MessageStatus.sent),
              isFromMe: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show delivery status for received messages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: createMessage(status: MessageStatus.sent),
              isFromMe: false,
              senderProfile: testProfile,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('shows error icon for failed messages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: createMessage(status: MessageStatus.failed),
              isFromMe: true,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('calls onRetry when retry is tapped', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: createMessage(status: MessageStatus.failed),
              isFromMe: true,
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.error_outline));
      expect(retryCalled, isTrue);
    });

    testWidgets('displays message content correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: createMessage(content: 'This is a test message'),
              isFromMe: false,
              senderProfile: testProfile,
            ),
          ),
        ),
      );

      expect(find.text('This is a test message'), findsOneWidget);
    });

    testWidgets('shows pending status icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: createMessage(status: MessageStatus.pending),
              isFromMe: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('has Semantics wrapper for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: createMessage(content: 'Test message'), isFromMe: true),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
