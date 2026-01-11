import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/domain/dm_message.dart' as dmm;
import 'package:lazurite/src/features/dms/presentation/conversation_detail_screen.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/message_bubble.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/message_composer.dart';
import 'package:lazurite/src/features/dms/providers.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('ConversationDetailScreen', () {
    late MockDmsRepository mockDmsRepository;
    late MockOutboxRepository mockOutboxRepository;
    late Session testSession;
    late List<Override> baseOverrides;

    setUp(() {
      mockDmsRepository = MockDmsRepository();
      mockOutboxRepository = MockOutboxRepository();

      when(
        () => mockDmsRepository.getConversation(any(), any()),
      ).thenAnswer((_) async => _testConversation);
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => mockDmsRepository.fetchMessages(
          any(),
          ownerDid: any(named: 'ownerDid'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Future<String?>.value(null));
      when(
        () => mockDmsRepository.updateReadState(
          convoId: any(named: 'convoId'),
          ownerDid: any(named: 'ownerDid'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockOutboxRepository.enqueueSend(any(), any(), any()),
      ).thenAnswer((_) async => 'test-outbox-id');
      when(() => mockOutboxRepository.processOutbox(any())).thenAnswer((_) async {});
      when(() => mockOutboxRepository.retryMessage(any(), any())).thenAnswer((_) async {});

      testSession = Session(
        did: 'did:web:test',
        handle: 'handle',
        pdsUrl: 'https://pds',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: const <String, dynamic>{},
      );
      baseOverrides = [
        dmsRepositoryProvider.overrideWithValue(mockDmsRepository),
        outboxRepositoryProvider.overrideWithValue(mockOutboxRepository),
        authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      ];
    });

    const convoId = 'test-convo-123';
    final testMessages = [
      dmm.AppDmMessage(
        messageId: 'msg1',
        convoId: convoId,
        sender: _testProfile,
        content: 'Hello from Alice',
        sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
        status: dmm.MessageStatus.sent,
      ),
      dmm.AppDmMessage(
        messageId: 'msg2',
        convoId: convoId,
        sender: _testProfile.copyWith(did: 'did:web:test', handle: 'test.bsky.social'),
        content: 'Hi there!',
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
        status: dmm.MessageStatus.sent,
      ),
    ];

    testWidgets('renders loading view initially', (tester) async {
      final controller = StreamController<List<dmm.AppDmMessage>>();
      addTearDown(controller.close);

      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no messages', (tester) async {
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('Start the conversation!'), findsOneWidget);
    });

    testWidgets('renders conversation title from conversation', (tester) async {
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders messages in reverse chronological order', (tester) async {
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value(testMessages));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      expect(find.byType(MessageBubble), findsNWidgets(2));
    });

    testWidgets('distinguishes own messages from others', (tester) async {
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value(testMessages));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      final bubbles = tester.widgetList<MessageBubble>(find.byType(MessageBubble));
      expect(bubbles.first.isFromMe, isTrue);
      expect(bubbles.last.isFromMe, isFalse);
    });

    testWidgets('shows avatar for first message in group', (tester) async {
      final messages = [
        dmm.AppDmMessage(
          messageId: 'msg1',
          convoId: convoId,
          sender: _testProfile,
          content: 'Message 1',
          sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
          status: dmm.MessageStatus.sent,
        ),
        dmm.AppDmMessage(
          messageId: 'msg2',
          convoId: convoId,
          sender: _testProfile,
          content: 'Message 2',
          sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: dmm.MessageStatus.sent,
        ),
        dmm.AppDmMessage(
          messageId: 'msg3',
          convoId: convoId,
          sender: _testProfile.copyWith(did: 'did:web:test', handle: 'test.bsky.social'),
          content: 'My reply',
          sentAt: DateTime.now(),
          status: dmm.MessageStatus.sent,
        ),
      ];

      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value(messages));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      final bubbles = tester.widgetList<MessageBubble>(find.byType(MessageBubble)).toList();
      expect(bubbles[0].showAvatar, isTrue);
      expect(bubbles[1].showAvatar, isFalse);
      expect(bubbles[2].showAvatar, isTrue);
    });

    testWidgets('renders message composer', (tester) async {
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      expect(find.byType(MessageComposer), findsOneWidget);
    });

    testWidgets('sends message via composer', (tester) async {
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      final composerFinder = find.byType(MessageComposer);
      expect(composerFinder, findsOneWidget);

      final composer = tester.widget<MessageComposer>(composerFinder);
      composer.onSend('Test message');
      await tester.pump();

      verify(
        () => mockOutboxRepository.enqueueSend(convoId, 'Test message', 'did:web:test'),
      ).called(1);
      verify(() => mockOutboxRepository.processOutbox('did:web:test')).called(1);
    });

    testWidgets('triggers refresh on pull to refresh', (tester) async {
      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value(testMessages));
      when(
        () => mockDmsRepository.fetchMessages(any(), ownerDid: any(named: 'ownerDid')),
      ).thenAnswer((_) async => 'new-cursor');

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();

      verify(() => mockDmsRepository.fetchMessages(convoId, ownerDid: 'did:web:test')).called(1);
    });

    testWidgets('shows retry option for failed messages', (tester) async {
      final failedMessage = dmm.AppDmMessage(
        messageId: 'pending:abc123',
        convoId: convoId,
        sender: _testProfile.copyWith(did: 'did:web:test', handle: 'test.bsky.social'),
        content: 'Failed message',
        sentAt: DateTime.now(),
        status: dmm.MessageStatus.failed,
      );

      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([failedMessage]));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      final bubbleFinder = find.byType(MessageBubble);
      expect(bubbleFinder, findsOneWidget);

      final bubble = tester.widget<MessageBubble>(bubbleFinder);
      expect(bubble.onRetry, isNotNull);
    });

    testWidgets('retries failed message when retry tapped', (tester) async {
      final failedMessage = dmm.AppDmMessage(
        messageId: 'pending:abc123',
        convoId: convoId,
        sender: _testProfile.copyWith(did: 'did:web:test', handle: 'test.bsky.social'),
        content: 'Failed message',
        sentAt: DateTime.now(),
        status: dmm.MessageStatus.failed,
      );

      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([failedMessage]));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pumpAndSettle();

      final bubbleFinder = find.byType(MessageBubble);
      final bubble = tester.widget<MessageBubble>(bubbleFinder);

      if (bubble.onRetry != null) {
        bubble.onRetry!();
        await tester.pump();

        verify(() => mockOutboxRepository.retryMessage('abc123', 'did:web:test')).called(1);
      }
    });

    testWidgets('renders error view when message loading fails', (tester) async {
      final controller = StreamController<List<dmm.AppDmMessage>>();
      addTearDown(controller.close);

      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: baseOverrides,
      );
      await tester.pump();

      controller.addError(Exception('Failed to load'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load messages'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('does not show conversation when not authenticated', (tester) async {
      final unauthenticatedOverrides = [
        dmsRepositoryProvider.overrideWithValue(mockDmsRepository),
        outboxRepositoryProvider.overrideWithValue(mockOutboxRepository),
        authProvider.overrideWith(() => _UnauthenticatedAuthNotifier()),
      ];

      when(
        () => mockDmsRepository.watchMessages(any(), any()),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpApp(
        const ConversationDetailScreen(convoId: convoId),
        overrides: unauthenticatedOverrides,
      );
      await tester.pump();

      expect(find.text('Conversation'), findsOneWidget);
    });
  });
}

const _testProfile = Profile(
  did: 'did:web:alice',
  handle: 'alice.bsky.social',
  displayName: 'Alice',
);

final _testConversation = DmConversation(
  convoId: 'test-convo-123',
  members: [_testProfile],
  lastMessageText: 'Hello',
  lastMessageAt: DateTime.now(),
  unreadCount: 0,
  isAccepted: true,
  isMuted: false,
);

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}

class _UnauthenticatedAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
}
