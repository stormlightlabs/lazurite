import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/get_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/message_thread_screen.dart';
import 'package:lazurite/features/messages/presentation/widgets/message_bubble.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/assertion_helpers.dart';
import '../../../helpers/fixtures/messages.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  const currentUserDid = 'did:plc:me';
  const otherDid = 'did:plc:other';
  const convoId = 'convo-123';

  late MockConvoRepository mockRepository;

  setUp(() {
    mockRepository = MockConvoRepository();
  });

  MessageView makeMessageView({String id = 'msg-1', String text = 'Hello', String senderDid = otherDid}) => MessageView(
    id: id,
    rev: 'rev-1',
    text: text,
    sender: MessageViewSender(did: senderDid),
    sentAt: DateTime.utc(2026, 3, 15),
  );

  UConvoGetMessagesMessages makeMessage({String id = 'msg-1', String text = 'Hello', String senderDid = otherDid}) =>
      UConvoGetMessagesMessages.messageView(
        data: makeMessageView(id: id, text: text, senderDid: senderDid),
      );

  ConvoView makeGroupConvo({
    String id = convoId,
    String name = 'Release Planning',
    int memberCount = 4,
    String lockStatus = 'unlocked',
    String status = 'accepted',
  }) {
    final json = testGroupConvoJson(id: id, name: name, memberCount: memberCount);
    final kind = Map<String, Object?>.from(json['kind']! as Map<String, Object?>);
    kind['lockStatus'] = lockStatus;
    return ConvoView.fromJson({...json, 'kind': kind, 'status': status});
  }

  ConvoView makeDirectConvo({String status = 'accepted'}) {
    return ConvoView.fromJson(
      testDirectConvoJson(
        id: convoId,
        members: [
          testChatProfileJson(did: currentUserDid, handle: 'me.bsky.social', displayName: 'Me'),
          testChatProfileJson(did: otherDid, handle: 'other.bsky.social', displayName: 'Other'),
        ],
        extra: {'status': status},
      ),
    );
  }

  UConvoGetMessagesMessages makeSystemMessage(Map<String, Object?> json) =>
      UConvoGetMessagesMessages.systemMessageView(data: SystemMessageView.fromJson(json));

  Widget buildSubject({String title = 'Test Convo', ConvoView? convo, bool passConvo = true}) {
    return RepositoryProvider<String>.value(
      value: currentUserDid,
      child: MaterialApp(
        home: BlocProvider(
          create: (_) => MessageBloc(convoRepository: mockRepository, currentUserDid: currentUserDid),
          child: MessageThreadScreen(
            convoId: convoId,
            title: title,
            convo: passConvo ? (convo ?? makeDirectConvo()) : null,
          ),
        ),
      ),
    );
  }

  group('MessageThreadScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows appbar title', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(title: 'Alice'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('uses group name and member count for group conversations', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(title: 'Fallback title', convo: makeGroupConvo()));
      await tester.pumpAndSettle();

      expect(find.text('Release Planning'), findsOneWidget);
      expect(find.text('4 members'), findsOneWidget);
      expect(find.text('Fallback title'), findsNothing);
    });

    testWidgets('hydrates deep-linked group metadata before rendering title', (tester) async {
      final convo = makeGroupConvo(name: 'Deep Link Group', memberCount: 7);
      when(() => mockRepository.getConvo(convoId)).thenAnswer((_) async => convo);
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(title: 'Conversation', passConvo: false));
      await tester.pumpAndSettle();

      expect(find.text('Deep Link Group'), findsOneWidget);
      expect(find.text('7 members'), findsOneWidget);
      verify(() => mockRepository.getConvo(convoId)).called(1);
    });

    testWidgets('shows empty state when no messages', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('shows error and retry button on failure', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network error'));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expectErrorState('Failed to load messages');
    });

    testWidgets('renders messages as bubbles', (tester) async {
      final messages = [
        makeMessage(id: 'msg-1', text: 'Hi there', senderDid: otherDid),
        makeMessage(id: 'msg-2', text: 'Hello back', senderDid: currentUserDid),
      ];

      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: messages, cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(MessageBubble), findsNWidgets(2));
      expect(find.text('Hi there'), findsOneWidget);
      expect(find.text('Hello back'), findsOneWidget);
    });

    testWidgets('renders group system messages inline', (tester) async {
      final messages = [makeSystemMessage(testGroupSystemMessageJson())];

      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: messages, cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(convo: makeGroupConvo()));
      await tester.pumpAndSettle();

      expect(find.text('A member joined the group.'), findsOneWidget);
    });

    testWidgets('current user message is right-aligned', (tester) async {
      final messages = [makeMessage(id: 'msg-1', text: 'My message', senderDid: currentUserDid)];

      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: messages, cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final bubble = tester.widget<MessageBubble>(find.byType(MessageBubble));
      expect(bubble.isCurrentUser, isTrue);
    });

    testWidgets('other user message is left-aligned', (tester) async {
      final messages = [makeMessage(id: 'msg-1', text: 'Their message', senderDid: otherDid)];

      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: messages, cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final bubble = tester.widget<MessageBubble>(find.byType(MessageBubble));
      expect(bubble.isCurrentUser, isFalse);
    });

    testWidgets('sends message on send button tap', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});
      when(
        () => mockRepository.sendMessage(any(), any()),
      ).thenAnswer((_) async => makeMessageView(id: 'new-msg', text: 'New message', senderDid: currentUserDid));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'New message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      verify(() => mockRepository.sendMessage(convoId, 'New message')).called(1);
    });

    testWidgets('keeps normal sends enabled for unlocked accepted group conversations', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});
      when(
        () => mockRepository.sendMessage(any(), any()),
      ).thenAnswer((_) async => makeMessageView(id: 'new-msg', text: 'Group hello', senderDid: currentUserDid));

      await tester.pumpWidget(buildSubject(convo: makeGroupConvo()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Group hello');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      verify(() => mockRepository.sendMessage(convoId, 'Group hello')).called(1);
    });

    testWidgets('disables message input for locked group conversations', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(convo: makeGroupConvo(lockStatus: 'locked')));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
      expect(find.text('This group is locked.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      verifyNever(() => mockRepository.sendMessage(any(), any()));
    });

    testWidgets('disables message input for permanently locked group conversations', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(convo: makeGroupConvo(lockStatus: 'locked-permanently')));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
      expect(find.text('This group is permanently locked.'), findsOneWidget);
      verifyNever(() => mockRepository.sendMessage(any(), any()));
    });

    testWidgets('respects request status before allowing sends', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(convo: makeDirectConvo(status: 'request')));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
      expect(find.text('Accept the message request before replying.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      verifyNever(() => mockRepository.sendMessage(any(), any()));
    });

    testWidgets('does not send empty message', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      verifyNever(() => mockRepository.sendMessage(any(), any()));
    });

    testWidgets('clears input after send', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});
      when(
        () => mockRepository.sendMessage(any(), any()),
      ).thenAnswer((_) async => makeMessageView(id: 'new-msg', text: 'Hi', senderDid: currentUserDid));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hi');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('shows Copy All in overflow menu', (tester) async {
      final messages = [makeMessage(id: 'msg-1', text: 'Hello', senderDid: otherDid)];

      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: messages, cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Copy All'), findsOneWidget);
    });

    testWidgets('marks conversation as read on open', (tester) async {
      when(
        () => mockRepository.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => MessageListResult(messages: [], cursor: null));
      when(() => mockRepository.updateRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      verify(() => mockRepository.updateRead(convoId)).called(1);
    });
  });
}
