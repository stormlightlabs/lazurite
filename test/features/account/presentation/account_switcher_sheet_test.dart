import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/account/presentation/account_switcher_sheet.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/assertion_helpers.dart';

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockTypeaheadRepository extends Mock implements TypeaheadRepository {}

void main() {
  late MockAccountSwitcherCubit cubit;
  late MockAuthBloc authBloc;
  late MockTypeaheadRepository typeaheadRepository;

  const tokens = AuthTokens(accessToken: 'token', did: 'did:plc:me', handle: 'me.bsky.social');

  setUpAll(() {
    registerFallbackValue(const LogoutRequested());
    registerFallbackValue(const SessionRestored(tokens: tokens));
  });

  setUp(() {
    cubit = MockAccountSwitcherCubit();
    authBloc = MockAuthBloc();
    typeaheadRepository = MockTypeaheadRepository();
    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));
    when(() => cubit.loadAccounts()).thenAnswer((_) async {});
    when(
      () => typeaheadRepository.search(
        query: any(named: 'query'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const <TypeaheadResult>[]);
  });

  Account makeAccount({required String did, String handle = 'user.bsky.social', String? displayName}) {
    return Account(
      did: did,
      handle: handle,
      displayName: displayName,
      service: null,
      accessToken: 'token',
      refreshToken: null,
      dpopPublicKey: null,
      dpopPrivateKey: null,
      dpopNonce: null,
      expiresAt: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AccountSwitcherCubit>.value(value: cubit),
      ],
      child: RepositoryProvider<TypeaheadRepository>.value(
        value: typeaheadRepository,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  TextButton(onPressed: () => showAccountSwitcherSheet(context), child: const Text('Open')),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubjectWithRouter(GoRouter router) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AccountSwitcherCubit>.value(value: cubit),
      ],
      child: RepositoryProvider<TypeaheadRepository>.value(
        value: typeaheadRepository,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('AccountSwitcherSheet', () {
    group('identifier validation', () {
      test('accepts valid handle', () {
        expect(validateAtProtoIdentifierInput('alice.bsky.social'), isNull);
      });

      test('rejects malformed handle', () {
        expect(validateAtProtoIdentifierInput('not-a-handle'), equals('Enter a full handle like username.bsky.social'));
      });

      test('accepts supported did methods', () {
        expect(validateAtProtoIdentifierInput('did:plc:ewvi7nxzyoun6zhxrhs64oiz'), isNull);
        expect(validateAtProtoIdentifierInput('did:web:example.com'), isNull);
      });

      test('rejects unsupported did methods', () {
        expect(validateAtProtoIdentifierInput('did:key:z6Mk'), equals('Use a did:plc:... or did:web:... identifier'));
      });
    });

    testWidgets('shows CircularProgressIndicator during loading state', (tester) async {
      when(() => cubit.state).thenReturn(const AccountSwitcherState.loading());

      await openSheet(tester);

      verify(() => cubit.loadAccounts()).called(1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders account rows from cubit state', (tester) async {
      when(() => cubit.state).thenReturn(
        AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1', handle: 'alice.bsky.social', displayName: 'Alice'),
            makeAccount(did: 'did:plc:user2', handle: 'bob.bsky.social'),
          ],
          activeDid: 'did:plc:user1',
        ),
      );

      await openSheet(tester);

      expectAccountRow(displayName: 'Alice', handle: 'alice.bsky.social');
      expectAccountRow(displayName: 'bob.bsky.social', handle: 'bob.bsky.social');
    });

    testWidgets('shows checkmark only on active account', (tester) async {
      when(() => cubit.state).thenReturn(
        AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1', handle: 'alice.bsky.social'),
            makeAccount(did: 'did:plc:user2', handle: 'bob.bsky.social'),
          ],
          activeDid: 'did:plc:user1',
        ),
      );

      await openSheet(tester);

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows empty state and Add Account tile when there are no switchable accounts', (tester) async {
      when(() => cubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));

      await openSheet(tester);

      expect(find.text('No other signed-in accounts yet. Add an account to switch between profiles.'), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_outlined), findsOneWidget);
      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
    });

    testWidgets('tapping inactive account calls switchAccount and dispatches SessionRestored', (tester) async {
      const switchedTokens = AuthTokens(accessToken: 'token2', did: 'did:plc:user2', handle: 'bob.bsky.social');

      when(() => cubit.state).thenReturn(
        AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1', handle: 'alice.bsky.social'),
            makeAccount(did: 'did:plc:user2', handle: 'bob.bsky.social'),
          ],
          activeDid: 'did:plc:user1',
        ),
      );
      when(() => cubit.switchAccount('did:plc:user2')).thenAnswer((_) async => switchedTokens);

      await openSheet(tester);
      await tester.tap(find.text('bob.bsky.social'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => cubit.switchAccount('did:plc:user2')).called(1);
      verify(() => authBloc.add(any(that: isA<SessionRestored>()))).called(1);
    });

    testWidgets('shows an error when switchAccount returns null', (tester) async {
      when(() => cubit.state).thenReturn(
        AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1', handle: 'alice.bsky.social'),
            makeAccount(did: 'did:plc:user2', handle: 'bob.bsky.social'),
          ],
          activeDid: 'did:plc:user1',
        ),
      );
      when(() => cubit.switchAccount('did:plc:user2')).thenAnswer((_) async => null);

      await openSheet(tester);
      await tester.tap(find.text('bob.bsky.social'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verifyNever(() => authBloc.add(any(that: isA<LogoutRequested>())));
      verify(() => cubit.switchAccount('did:plc:user2')).called(1);
    });

    testWidgets('reauth fallback routes to login with selected account handle', (tester) async {
      late GoRouter router;
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: TextButton(onPressed: () => showAccountSwitcherSheet(context), child: const Text('Open')),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => Scaffold(body: Text('reauth:${state.uri.queryParameters['handle'] ?? ''}')),
          ),
        ],
      );
      addTearDown(router.dispose);

      when(() => cubit.state).thenReturn(
        AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1', handle: 'alice.bsky.social'),
            makeAccount(did: 'did:plc:user2', handle: 'bob.bsky.social'),
          ],
          activeDid: 'did:plc:user1',
        ),
      );
      when(() => cubit.switchAccount('did:plc:user2')).thenAnswer((_) async => null);

      await tester.pumpWidget(buildSubjectWithRouter(router));
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('bob.bsky.social'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/login');
      expect(router.routeInformationProvider.value.uri.queryParameters['reauth'], '1');
      expect(router.routeInformationProvider.value.uri.queryParameters['handle'], 'bob.bsky.social');
      expect(find.text('reauth:bob.bsky.social'), findsOneWidget);
    });

    testWidgets('tapping active account does nothing', (tester) async {
      when(() => cubit.state).thenReturn(
        AccountSwitcherState.ready(
          accounts: [makeAccount(did: 'did:plc:user1', handle: 'alice.bsky.social')],
          activeDid: 'did:plc:user1',
        ),
      );

      await openSheet(tester);
      await tester.tap(find.text('alice.bsky.social'));
      await tester.pump();

      verifyNever(() => cubit.switchAccount(any()));
    });

    testWidgets('invalid add-account handle is blocked with inline validation', (tester) async {
      when(() => cubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));

      await openSheet(tester);
      await tester.tap(find.text('Add Account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(find.byType(TextFormField), 'not-a-handle');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      verifyNever(() => cubit.addAccountWithOAuth(any()));
    });

    testWidgets('add-account Continue button stays disabled for invalid identifier', (tester) async {
      when(() => cubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));

      await openSheet(tester);
      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'not-a-handle');
      await tester.pump();

      final continueButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'));
      expect(continueButton.onPressed, isNull);
      verifyNever(() => cubit.addAccountWithOAuth(any()));
    });

    testWidgets('remove account action removes account from sheet flow', (tester) async {
      when(() => cubit.state).thenReturn(
        AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1', handle: 'alice.bsky.social'),
            makeAccount(did: 'did:plc:user2', handle: 'bob.bsky.social'),
          ],
          activeDid: 'did:plc:user1',
        ),
      );
      when(() => cubit.removeAccount('did:plc:user2')).thenAnswer((_) async => const AccountRemovalResult.removed());

      await openSheet(tester);
      await tester.tap(find.byTooltip('Remove account').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      verify(() => cubit.removeAccount('did:plc:user2')).called(1);
    });
  });
}
