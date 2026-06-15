import 'package:bluesky_poptart/chat/bsky/group/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/request_join.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/join_link_preview_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/messages.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  late MockConvoRepository repository;

  setUp(() {
    repository = MockConvoRepository();
  });

  Widget buildSubject() => RepositoryProvider<ConvoRepository>.value(
    value: repository,
    child: BlocProvider(
      create: (_) => ConvoListBloc(convoRepository: repository),
      child: const MaterialApp(home: JoinLinkPreviewScreen(code: testJoinLinkCode)),
    ),
  );

  group('JoinLinkPreviewScreen', () {
    testWidgets('renders join link preview', (tester) async {
      when(
        () => repository.previewJoinLink(testJoinLinkCode),
      ).thenAnswer((_) async => JoinLinkPreviewView.fromJson(testJoinLinkPreviewJson()));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text(testGroupName), findsOneWidget);
      expect(find.text('3 members'), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Request to join'), findsOneWidget);
    });

    testWidgets('requests to join and shows pending state', (tester) async {
      when(
        () => repository.previewJoinLink(testJoinLinkCode),
      ).thenAnswer((_) async => JoinLinkPreviewView.fromJson(testJoinLinkPreviewJson()));
      when(() => repository.requestJoin(testJoinLinkCode)).thenAnswer(
        (_) async => const GroupRequestJoinOutput(
          status: GroupRequestJoinStatus.knownValue(data: KnownGroupRequestJoinStatus.pending),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('join_link_request_join_button')));
      await tester.pumpAndSettle();

      verify(() => repository.requestJoin(testJoinLinkCode)).called(1);
      expect(find.text('Request sent.'), findsOneWidget);
      expect(find.text('Request pending'), findsOneWidget);
      expect(
        find.text(
          'The server did not return a conversation for this request, so Lazurite cannot withdraw it from this link screen.',
        ),
        findsOneWidget,
      );
      expect(find.text('Waiting for approval'), findsOneWidget);
      expect(find.byKey(const ValueKey('join_link_request_join_button')), findsNothing);
    });

    testWidgets('withdraws pending request when preview includes request convo', (tester) async {
      when(() => repository.previewJoinLink(testJoinLinkCode)).thenAnswer(
        (_) async => JoinLinkPreviewView.fromJson(
          testJoinLinkPreviewJson(convo: testGroupConvoJson(extra: {'status': 'request'})),
        ),
      );
      when(() => repository.withdrawJoinRequest(testConvoId)).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('join_link_withdraw_request_button')));
      await tester.pumpAndSettle();

      verify(() => repository.withdrawJoinRequest(testConvoId)).called(1);
      expect(find.text('Request withdrawn.'), findsOneWidget);
    });

    testWidgets('shows disabled or invalid link error', (tester) async {
      when(() => repository.previewJoinLink(testJoinLinkCode)).thenAnswer((_) async => throw Exception('invalid'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('This join link is invalid or disabled.'), findsOneWidget);
    });
  });
}
