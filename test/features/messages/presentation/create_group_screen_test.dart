import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/bloc/group_create_cubit.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/create_group_screen.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/messages.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

class MockTypeaheadRepository extends Mock implements TypeaheadRepository {}

void main() {
  const currentUserDid = testViewerDid;
  late MockConvoRepository convoRepository;
  late MockTypeaheadRepository typeaheadRepository;
  late GoRouter router;

  setUp(() {
    convoRepository = MockConvoRepository();
    typeaheadRepository = MockTypeaheadRepository();
  });

  tearDown(() {
    router.dispose();
  });

  ConvoView groupConvo({String id = testConvoId, String name = testGroupName}) {
    return ConvoView.fromJson(testGroupConvoJson(id: id, name: name));
  }

  Widget buildSubject() {
    router = GoRouter(
      initialLocation: '/alerts/messages/new-group',
      routes: [
        GoRoute(
          path: '/alerts/messages/new-group',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => GroupCreateCubit(convoRepository: convoRepository, currentUserDid: currentUserDid),
              child: const CreateGroupScreen(),
            );
          },
        ),
        GoRoute(
          path: '/alerts/messages/:id',
          builder: (context, state) => Scaffold(body: Text('Thread ${state.pathParameters['id']}')),
        ),
      ],
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ConvoRepository>.value(value: convoRepository),
        RepositoryProvider<TypeaheadRepository>.value(value: typeaheadRepository),
        RepositoryProvider<String>.value(value: currentUserDid),
      ],
      child: BlocProvider(
        create: (_) => ConvoListBloc(convoRepository: convoRepository),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('disables create until a valid name and selected member are present', (tester) async {
    when(() => typeaheadRepository.search(query: 'river', limit: 10)).thenAnswer(
      (_) async => const [TypeaheadResult(did: testMemberDid, handle: 'river.bsky.social', displayName: 'River Tam')],
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    TextButton createButton() => tester.widget<TextButton>(find.byKey(const ValueKey('create_group_submit_button')));

    expect(createButton().onPressed, isNull);

    await tester.enterText(find.byKey(const ValueKey('create_group_name_field')), 'Release Planning');
    await tester.pump();
    expect(createButton().onPressed, isNull);

    await tester.enterText(find.byKey(const ValueKey('create_group_member_search_field')), 'river');
    await tester.pumpAndSettle();

    expect(find.text('River Tam'), findsOneWidget);

    await tester.tap(find.byTooltip('Add river.bsky.social'));
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsOneWidget);
    expect(createButton().onPressed, isNotNull);
  });

  testWidgets('creates the group and navigates to the created thread', (tester) async {
    when(() => typeaheadRepository.search(query: 'river', limit: 10)).thenAnswer(
      (_) async => const [TypeaheadResult(did: testMemberDid, handle: 'river.bsky.social', displayName: 'River Tam')],
    );
    when(
      () => convoRepository.createGroup(name: 'Release Planning', memberDids: [testMemberDid]),
    ).thenAnswer((_) async => groupConvo(name: 'Release Planning'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('create_group_name_field')), 'Release Planning');
    await tester.enterText(find.byKey(const ValueKey('create_group_member_search_field')), 'river');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add river.bsky.social'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create_group_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Thread $testConvoId'), findsOneWidget);
    verify(() => convoRepository.createGroup(name: 'Release Planning', memberDids: [testMemberDid])).called(1);
  });

  testWidgets('shows actionable create errors', (tester) async {
    when(() => typeaheadRepository.search(query: 'river', limit: 10)).thenAnswer(
      (_) async => const [TypeaheadResult(did: testMemberDid, handle: 'river.bsky.social', displayName: 'River Tam')],
    );
    when(
      () => convoRepository.createGroup(name: 'Release Planning', memberDids: [testMemberDid]),
    ).thenThrow(Exception('network'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('create_group_name_field')), 'Release Planning');
    await tester.enterText(find.byKey(const ValueKey('create_group_member_search_field')), 'river');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add river.bsky.social'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create_group_submit_button')));
    await tester.pump();

    expect(find.text('Failed to create group. Check the selected members and try again.'), findsOneWidget);
  });

  testWidgets('shows member search errors without an empty catch', (tester) async {
    when(() => typeaheadRepository.search(query: 'river', limit: 10)).thenThrow(Exception('offline'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('create_group_member_search_field')), 'river');
    await tester.pumpAndSettle();

    expect(find.text('Search failed. Try a handle or display name again.'), findsOneWidget);
  });

  testWidgets('selected member chips can be removed', (tester) async {
    when(() => typeaheadRepository.search(query: 'river', limit: 10)).thenAnswer(
      (_) async => const [TypeaheadResult(did: testMemberDid, handle: 'river.bsky.social', displayName: 'River Tam')],
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('create_group_name_field')), 'Release Planning');
    await tester.enterText(find.byKey(const ValueKey('create_group_member_search_field')), 'river');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add river.bsky.social'));
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsOneWidget);

    final chip = tester.widget<Chip>(find.byType(Chip));
    chip.onDeleted!();
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsNothing);
    final createButton = tester.widget<TextButton>(find.byKey(const ValueKey('create_group_submit_button')));
    expect(createButton.onPressed, isNull);
  });
}
