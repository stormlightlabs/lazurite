import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());
  });

  Widget buildSubject() {
    final typeaheadRepository = _FakeTypeaheadRepository(
      searchHandler: ({required String query, int limit = 10}) async => const [],
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: LoginScreen(typeaheadRepository: typeaheadRepository),
          ),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const Scaffold(body: Text('terms-route')),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const Scaffold(body: Text('privacy-route')),
        ),
      ],
      initialLocation: '/login',
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows terms and privacy links', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Terms of Service'), 200, scrollable: scrollable);
    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: scrollable);
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('tapping Terms of Service opens terms route', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Terms of Service'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.text('terms-route'), findsOneWidget);
  });

  testWidgets('tapping Privacy Policy opens privacy route', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('privacy-route'), findsOneWidget);
  });

  testWidgets('login typeahead shows community results and selecting triggers OAuth login', (tester) async {
    final typeaheadRepository = _FakeTypeaheadRepository(
      searchHandler: ({required String query, int limit = 10}) async {
        if (query == 'ri') {
          return const [TypeaheadResult(did: 'did:plc:river', handle: 'river.bsky.social', displayName: 'River Tam')];
        }
        return const [];
      },
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: LoginScreen(typeaheadRepository: typeaheadRepository),
          ),
        ),
      ],
      initialLocation: '/login',
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'ri');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('River Tam'), findsOneWidget);
    await tester.tap(find.text('River Tam'));
    await tester.pumpAndSettle();

    verify(() => authBloc.add(const OAuthLoginRequested(handle: 'river.bsky.social'))).called(1);
  });
}

class _FakeTypeaheadRepository extends TypeaheadRepository {
  _FakeTypeaheadRepository({required this.searchHandler}) : super(provider: TypeaheadRepository.communityProvider);

  final Future<List<TypeaheadResult>> Function({required String query, int limit}) searchHandler;

  @override
  Future<List<TypeaheadResult>> search({required String query, int limit = 10}) {
    return searchHandler(query: query, limit: limit);
  }
}
