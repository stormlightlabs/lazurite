import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/domain/dm_message.dart' as dmm;
import 'package:lazurite/src/features/dms/presentation/conversation_list_screen.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/conversation_list_item.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/message_request_card.dart';
import 'package:lazurite/src/features/dms/providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('ConversationListScreen', () {
    late MockDmsRepository mockRepository;
    late Session testSession;
    late List<Override> baseOverrides;

    setUp(() {
      mockRepository = MockDmsRepository();
      when(
        () => mockRepository.fetchConversations(
          cursor: any(named: 'cursor'),
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) async => null);
      when(() => mockRepository.muteConversation(any(), any())).thenAnswer((_) async {});
      when(() => mockRepository.unmuteConversation(any(), any())).thenAnswer((_) async {});
      when(() => mockRepository.leaveConversation(any(), any())).thenAnswer((_) async {});
      when(
        () => mockRepository.fetchMessages(
          any(),
          limit: any(named: 'limit'),
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) async => null);
      when(() => mockRepository.watchMessages(any(), any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.updateReadState(
          convoId: any(named: 'convoId'),
          messageId: any(named: 'messageId'),
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) async {});
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
        dmsRepositoryProvider.overrideWithValue(mockRepository),
        authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      ];
    });

    const author = Author(did: 'did:web:alice', handle: 'alice.bsky.social', displayName: 'Alice');
    final conversation = DmConversation(
      convoId: '123',
      members: [author],
      lastMessageText: 'Hello',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      isAccepted: true,
      isMuted: false,
    );

    testWidgets('renders loading view initially', (tester) async {
      final controller = StreamController<List<DmConversation>>();
      addTearDown(controller.close);

      when(() => mockRepository.watchConversations(any())).thenAnswer((_) => controller.stream);

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no conversations', (tester) async {
      when(() => mockRepository.watchConversations(any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchConversations(ownerDid: any(named: 'ownerDid')),
      ).thenAnswer((_) async => null);

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('Start a conversation with someone!'), findsOneWidget);
    });

    testWidgets('renders conversation list', (tester) async {
      when(
        () => mockRepository.watchConversations(any()),
      ).thenAnswer((_) => Stream.value([conversation]));

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      expect(find.byType(ConversationListItem), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders message requests section', (tester) async {
      final requestConvo = conversation.copyWith(isAccepted: false, convoId: '456');
      when(
        () => mockRepository.watchConversations(any()),
      ).thenAnswer((_) => Stream.value([requestConvo, conversation]));

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      expect(find.text('Message Requests'), findsOneWidget);
      expect(find.text('All Messages'), findsOneWidget);
      expect(find.byType(MessageRequestCard), findsOneWidget);
      expect(find.byType(ConversationListItem), findsOneWidget);
    });

    testWidgets('triggers refresh on pull to refresh', (tester) async {
      when(
        () => mockRepository.watchConversations(any()),
      ).thenAnswer((_) => Stream.value([conversation]));
      when(
        () => mockRepository.fetchConversations(ownerDid: any(named: 'ownerDid')),
      ).thenAnswer((_) async => 'new-cursor');

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      verify(() => mockRepository.fetchConversations(ownerDid: any(named: 'ownerDid'))).called(1);
    });

    testWidgets('shows FAB', (tester) async {
      when(
        () => mockRepository.watchConversations(any()),
      ).thenAnswer((_) => Stream.value([conversation]));

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('triggers mark as read on swipe right', (tester) async {
      when(
        () => mockRepository.watchConversations(any()),
      ).thenAnswer((_) => Stream.value([conversation]));

      final message = dmm.AppDmMessage(
        messageId: 'msg1',
        convoId: '123',
        sender: author,
        content: 'Hi',
        sentAt: DateTime.now(),
        status: dmm.MessageStatus.sent,
      );

      when(
        () => mockRepository.watchMessages('123', any()),
      ).thenAnswer((_) => Stream.value([message]));

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ConversationListItem), const Offset(500, 0));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.fetchMessages('123', ownerDid: any(named: 'ownerDid'), limit: 1),
      ).called(1);
      verify(
        () => mockRepository.updateReadState(
          convoId: '123',
          messageId: 'msg1',
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    testWidgets('triggers leave conversation on swipe left and confirm', (tester) async {
      when(
        () => mockRepository.watchConversations(any()),
      ).thenAnswer((_) => Stream.value([conversation]));

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ConversationListItem), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Leave conversation?'), findsOneWidget);

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.leaveConversation('123', any())).called(1);
    });

    testWidgets('triggers mute/unmute on long press', (tester) async {
      when(
        () => mockRepository.watchConversations(any()),
      ).thenAnswer((_) => Stream.value([conversation]));

      await tester.pumpApp(const ConversationListScreen(), overrides: baseOverrides);
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(ConversationListItem));
      await tester.pumpAndSettle();

      expect(find.text('Mute'), findsOneWidget);

      await tester.tap(find.text('Mute'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.muteConversation('123', any())).called(1);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
