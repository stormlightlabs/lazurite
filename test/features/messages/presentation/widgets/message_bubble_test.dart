import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/presentation/widgets/message_bubble.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

import '../../../../helpers/router_harness.dart';

void main() {
  MessageView makeMessage({String id = 'msg-1', String text = 'Hello', String senderDid = 'did:plc:sender'}) =>
      MessageView(
        id: id,
        rev: 'rev-1',
        text: text,
        sender: MessageViewSender(did: senderDid),
        sentAt: DateTime.utc(2026, 3, 15),
      );

  const senderProfile = ProfileViewBasic(
    did: 'did:plc:sender',
    handle: 'sender.bsky.social',
    displayName: 'Sender',
    avatar: 'https://cdn.example/avatar.jpg',
  );

  group('MessageBubble', () {
    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: makeMessage(text: 'Test message'), isCurrentUser: false),
          ),
        ),
      );

      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('renders sender avatar from profile data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: makeMessage(), isCurrentUser: false, senderProfile: senderProfile),
          ),
        ),
      );

      final avatar = tester.widget<ProfileAvatar>(find.byType(ProfileAvatar));
      expect(avatar.imageUrl, senderProfile.avatar);
      expect(avatar.fallbackText, senderProfile.displayName);
    });

    testWidgets('opens sender profile when avatar is tapped', (tester) async {
      Uri? profileRoute;
      final harness = TestRouterHarness(
        home: Scaffold(
          body: MessageBubble(message: makeMessage(), isCurrentUser: false, senderProfile: senderProfile),
        ),
        routes: [profileCaptureRoute(onRoute: (uri) => profileRoute = uri)],
      );

      await harness.pump(tester);

      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();

      expect(profileRoute?.path, '/profile/${Uri.encodeComponent(senderProfile.did)}');
    });

    testWidgets('right-aligns current user bubble', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubble(message: makeMessage(), isCurrentUser: true)),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('left-aligns other user bubble', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubble(message: makeMessage(), isCurrentUser: false)),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('shows snackbar on long press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: makeMessage(text: 'Copy me'), isCurrentUser: false),
          ),
        ),
      );

      await tester.longPress(find.text('Copy me'));
      await tester.pumpAndSettle();

      expect(find.text('Message copied'), findsOneWidget);
    });
  });

  group('DeletedMessageBubble', () {
    testWidgets('displays deleted message text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DeletedMessageBubble(isCurrentUser: false))));

      expect(find.text('Message deleted'), findsOneWidget);
    });

    testWidgets('right-aligns current user deleted bubble', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DeletedMessageBubble(isCurrentUser: true))));

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });
  });
}
