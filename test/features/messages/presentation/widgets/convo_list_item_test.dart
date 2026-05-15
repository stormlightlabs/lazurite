import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/presentation/widgets/convo_list_item.dart';

void main() {
  const currentUserDid = 'did:plc:currentuser';
  const otherDid = 'did:plc:other';

  ProfileViewBasic makeProfile({
    String did = otherDid,
    String handle = 'other.bsky.social',
    String? displayName,
    String? avatar,
  }) => ProfileViewBasic(did: did, handle: handle, displayName: displayName, avatar: avatar);

  ConvoView makeConvo({
    String id = 'c1',
    bool muted = false,
    int unreadCount = 0,
    UConvoViewLastMessage? lastMessage,
    List<ProfileViewBasic>? members,
  }) => ConvoView(
    id: id,
    rev: 'rev-1',
    members: members ?? [makeProfile(did: currentUserDid, handle: 'me.bsky.social'), makeProfile()],
    muted: muted,
    unreadCount: unreadCount,
    lastMessage: lastMessage,
  );

  Widget buildSubject({required ConvoView convo, VoidCallback? onTap, VoidCallback? onMuteTap}) {
    return MaterialApp(
      home: Scaffold(
        body: ConvoListItem(
          convo: convo,
          currentUserDid: currentUserDid,
          onTap: onTap ?? () {},
          onMuteTap: onMuteTap ?? () {},
        ),
      ),
    );
  }

  group('ConvoListItem', () {
    testWidgets('displays the other member display name', (tester) async {
      final convo = makeConvo(
        members: [
          makeProfile(did: currentUserDid, handle: 'me.bsky.social'),
          makeProfile(displayName: 'Alice Smith'),
        ],
      );

      await tester.pumpWidget(buildSubject(convo: convo));

      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('falls back to handle when no display name', (tester) async {
      final convo = makeConvo(
        members: [
          makeProfile(did: currentUserDid, handle: 'me.bsky.social'),
          makeProfile(handle: 'alice.bsky.social'),
        ],
      );

      await tester.pumpWidget(buildSubject(convo: convo));

      expect(find.text('alice.bsky.social'), findsOneWidget);
    });

    testWidgets('shows last message text', (tester) async {
      final lastMsg = UConvoViewLastMessage.messageView(
        data: MessageView(
          id: 'msg-1',
          rev: 'rev-1',
          text: 'Hello there!',
          sender: const MessageViewSender(did: otherDid),
          sentAt: DateTime.utc(2026, 3, 15),
        ),
      );
      final convo = makeConvo(lastMessage: lastMsg);

      await tester.pumpWidget(buildSubject(convo: convo));

      expect(find.text('Hello there!'), findsOneWidget);
    });

    testWidgets('shows "Message deleted" for deleted last message', (tester) async {
      final lastMsg = UConvoViewLastMessage.deletedMessageView(
        data: DeletedMessageView(
          id: 'msg-1',
          rev: 'rev-1',
          sender: const MessageViewSender(did: otherDid),
          sentAt: DateTime.utc(2026, 3, 15),
        ),
      );
      final convo = makeConvo(lastMessage: lastMsg);

      await tester.pumpWidget(buildSubject(convo: convo));

      expect(find.text('Message deleted'), findsOneWidget);
    });

    testWidgets('shows mute icon when conversation is muted', (tester) async {
      final convo = makeConvo(muted: true);

      await tester.pumpWidget(buildSubject(convo: convo));

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('does not show mute icon when not muted', (tester) async {
      final convo = makeConvo(muted: false);

      await tester.pumpWidget(buildSubject(convo: convo));

      expect(find.byIcon(Icons.volume_off), findsNothing);
    });

    testWidgets('shows unread count badge', (tester) async {
      final convo = makeConvo(unreadCount: 5);

      await tester.pumpWidget(buildSubject(convo: convo));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final convo = makeConvo();

      await tester.pumpWidget(buildSubject(convo: convo, onTap: () => tapped = true));
      await tester.tap(find.byType(ListTile));

      expect(tapped, isTrue);
    });

    testWidgets('calls onMuteTap when mute menu item selected', (tester) async {
      var muteTapped = false;
      final convo = makeConvo(muted: false);

      await tester.pumpWidget(buildSubject(convo: convo, onMuteTap: () => muteTapped = true));

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mute'));
      await tester.pumpAndSettle();

      expect(muteTapped, isTrue);
    });

    testWidgets('shows Unmute option for muted conversation', (tester) async {
      final convo = makeConvo(muted: true);

      await tester.pumpWidget(buildSubject(convo: convo));

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Unmute'), findsOneWidget);
    });
  });
}
