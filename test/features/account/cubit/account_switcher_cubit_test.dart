import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class AccountsCompanionFake extends Fake implements AccountsCompanion {}

void main() {
  late MockAppDatabase mockDatabase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(AccountsCompanionFake());
    registerFallbackValue(
      const AuthTokens(accessToken: 'token', did: 'did:plc:fallback', handle: 'fallback.bsky.social'),
    );
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockAuthRepository = MockAuthRepository();
  });

  AccountSwitcherCubit buildCubit() => AccountSwitcherCubit(database: mockDatabase, authRepository: mockAuthRepository);

  Account makeAccount({
    required String did,
    String handle = 'user.bsky.social',
    String accessToken = 'token',
    String? refreshToken,
    DateTime? expiresAt,
    String? dpopPrivateKey,
    String? dpopPublicKey,
    String? oauthService,
    String? oauthClientId,
    String? oauthTokenType,
    String? oauthScope,
  }) {
    return Account(
      did: did,
      handle: handle,
      displayName: null,
      service: null,
      oauthService: oauthService,
      oauthClientId: oauthClientId,
      oauthTokenType: oauthTokenType,
      oauthScope: oauthScope,
      accessToken: accessToken,
      refreshToken: refreshToken,
      dpopPublicKey: dpopPublicKey,
      dpopPrivateKey: dpopPrivateKey,
      dpopNonce: null,
      expiresAt: expiresAt,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  group('AccountSwitcherCubit', () {
    group('loadAccounts', () {
      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'emits loading then ready with accounts when accounts exist',
        build: buildCubit,
        setUp: () {
          final accounts = [makeAccount(did: 'did:plc:user1'), makeAccount(did: 'did:plc:user2')];
          when(() => mockDatabase.getAllAccounts()).thenAnswer((_) async => accounts);
          when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => 'did:plc:user1');
        },
        act: (cubit) => cubit.loadAccounts(),
        expect: () => [
          const AccountSwitcherState.loading(),
          predicate<AccountSwitcherState>(
            (state) =>
                state.status == AccountSwitcherStatus.ready &&
                state.accounts.length == 2 &&
                state.activeDid == 'did:plc:user1',
          ),
        ],
      );

      test('loads cached avatar URL for active account', () async {
        final database = AppDatabase(executor: NativeDatabase.memory());
        addTearDown(database.close);
        await database.insertAccount(
          AccountsCompanion.insert(did: 'did:plc:user1', handle: 'user1.bsky.social', accessToken: 'token'),
        );
        await database.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:user1');
        await database.cacheProfile(
          did: 'did:plc:user1',
          handle: 'user1.bsky.social',
          payload: '{"did":"did:plc:user1","handle":"user1.bsky.social","avatar":"https://cdn.example/avatar.jpg"}',
        );

        final cubit = AccountSwitcherCubit(database: database, authRepository: mockAuthRepository);
        addTearDown(cubit.close);
        await cubit.loadAccounts();

        expect(cubit.state.activeDid, 'did:plc:user1');
        expect(cubit.state.activeAvatarUrl, 'https://cdn.example/avatar.jpg');
      });

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'keeps activeDid null when no active account is saved',
        build: buildCubit,
        setUp: () {
          final accounts = [makeAccount(did: 'did:plc:user1'), makeAccount(did: 'did:plc:user2')];
          when(() => mockDatabase.getAllAccounts()).thenAnswer((_) async => accounts);
          when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => null);
        },
        act: (cubit) => cubit.loadAccounts(),
        expect: () => [
          const AccountSwitcherState.loading(),
          predicate<AccountSwitcherState>(
            (state) =>
                state.status == AccountSwitcherStatus.ready && state.accounts.length == 2 && state.activeDid == null,
          ),
        ],
      );

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'keeps activeDid null when saved did is not in accounts',
        build: buildCubit,
        setUp: () {
          final accounts = [makeAccount(did: 'did:plc:user1')];
          when(() => mockDatabase.getAllAccounts()).thenAnswer((_) async => accounts);
          when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => 'did:plc:unknown');
        },
        act: (cubit) => cubit.loadAccounts(),
        expect: () => [
          const AccountSwitcherState.loading(),
          predicate<AccountSwitcherState>(
            (state) =>
                state.status == AccountSwitcherStatus.ready && state.accounts.length == 1 && state.activeDid == null,
          ),
        ],
      );

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'emits ready with empty accounts on failure',
        build: buildCubit,
        setUp: () {
          when(() => mockDatabase.getAllAccounts()).thenThrow(Exception('DB error'));
        },
        act: (cubit) => cubit.loadAccounts(),
        expect: () => [
          const AccountSwitcherState.loading(),
          predicate<AccountSwitcherState>(
            (state) => state.status == AccountSwitcherStatus.ready && state.accounts.isEmpty,
          ),
        ],
      );
    });

    group('switchAccount', () {
      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'does nothing when state is not ready',
        build: buildCubit,
        act: (cubit) => cubit.switchAccount('did:plc:user1'),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockDatabase.setSetting(any(), any()));
        },
      );

      test('returns tokens for valid (non-expired) account', () async {
        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer((_) async => makeAccount(did: 'did:plc:user1'));

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [makeAccount(did: 'did:plc:user1')],
            activeDid: 'did:plc:user1',
          ),
        );

        final tokens = await cubit.switchAccount('did:plc:user1');
        expect(tokens, isNotNull);
        expect(tokens!.did, 'did:plc:user1');
        verifyNever(() => mockAuthRepository.refreshSession(any()));
      });

      test('preserves complete OAuth metadata when switching accounts', () async {
        final account = makeAccount(
          did: 'did:plc:user1',
          oauthService: 'bsky.social',
          oauthClientId: 'client-id',
          oauthTokenType: 'DPoP',
          oauthScope: 'atproto transition:generic',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
        );
        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer((_) async => account);

        final cubit = buildCubit();
        cubit.emit(AccountSwitcherState.ready(accounts: [account], activeDid: 'did:plc:user1'));

        final tokens = await cubit.switchAccount('did:plc:user1');

        expect(tokens, isNotNull);
        expect(tokens!.authMethod, AuthMethod.oauth);
        expect(tokens.oauthService, 'bsky.social');
        expect(tokens.oauthClientId, 'client-id');
        expect(tokens.oauthTokenType, 'DPoP');
        expect(tokens.oauthScope, 'atproto transition:generic');
      });

      test('calls refreshSession when account is expired with refresh token', () async {
        final expiredAt = DateTime.now().subtract(const Duration(hours: 1));
        final refreshedTokens = AuthTokens(
          accessToken: 'new-token',
          did: 'did:plc:user1',
          handle: 'user.bsky.social',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer(
          (_) async => makeAccount(did: 'did:plc:user1', expiresAt: expiredAt, refreshToken: 'refresh-token'),
        );
        when(() => mockAuthRepository.refreshSession(any())).thenAnswer((_) async => refreshedTokens);

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [makeAccount(did: 'did:plc:user1')],
            activeDid: 'did:plc:user1',
          ),
        );

        final tokens = await cubit.switchAccount('did:plc:user1');
        expect(tokens, refreshedTokens);
        verify(() => mockAuthRepository.refreshSession(any())).called(1);
      });

      test('returns null when account is expired and refresh throws', () async {
        final expiredAt = DateTime.now().subtract(const Duration(hours: 1));

        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer(
          (_) async => makeAccount(did: 'did:plc:user1', expiresAt: expiredAt, refreshToken: 'refresh-token'),
        );
        when(() => mockAuthRepository.refreshSession(any())).thenThrow(Exception('refresh failed'));

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [makeAccount(did: 'did:plc:user1')],
            activeDid: 'did:plc:user1',
          ),
        );

        final tokens = await cubit.switchAccount('did:plc:user1');
        expect(tokens, isNull);
        verifyNever(() => mockDatabase.setSetting(any(), any()));
      });

      test('returns null when account is expired and has no refresh token', () async {
        final expiredAt = DateTime.now().subtract(const Duration(hours: 1));

        when(
          () => mockDatabase.getAccount('did:plc:user1'),
        ).thenAnswer((_) async => makeAccount(did: 'did:plc:user1', expiresAt: expiredAt));

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [makeAccount(did: 'did:plc:user1')],
            activeDid: 'did:plc:user1',
          ),
        );

        final tokens = await cubit.switchAccount('did:plc:user1');
        expect(tokens, isNull);
        verifyNever(() => mockAuthRepository.refreshSession(any()));
        verifyNever(() => mockDatabase.setSetting(any(), any()));
      });

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'updates activeDid when switching accounts',
        build: buildCubit,
        seed: () => AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1'),
            makeAccount(did: 'did:plc:user2'),
          ],
          activeDid: 'did:plc:user1',
        ),
        setUp: () {
          when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
          when(
            () => mockDatabase.getAccount('did:plc:user2'),
          ).thenAnswer((_) async => makeAccount(did: 'did:plc:user2'));
        },
        act: (cubit) => cubit.switchAccount('did:plc:user2'),
        expect: () => [predicate<AccountSwitcherState>((state) => state.activeDid == 'did:plc:user2')],
        verify: (_) {
          verify(() => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:user2')).called(1);
        },
      );
    });

    group('addAccountCompleted', () {
      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'inserts account, reloads, and activeDid is set to the new account',
        build: buildCubit,
        setUp: () {
          when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
          when(
            () => mockDatabase.getAllAccounts(),
          ).thenAnswer((_) async => [makeAccount(did: 'did:plc:newuser', handle: 'new.bsky.social')]);
          when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => null);
          when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
          when(
            () => mockDatabase.getAccount('did:plc:newuser'),
          ).thenAnswer((_) async => makeAccount(did: 'did:plc:newuser', handle: 'new.bsky.social'));
        },
        act: (cubit) => cubit.addAccountCompleted(
          const AuthTokens(accessToken: 'token', did: 'did:plc:newuser', handle: 'new.bsky.social'),
        ),
        expect: () => [
          const AccountSwitcherState.loading(),
          predicate<AccountSwitcherState>(
            (state) =>
                state.status == AccountSwitcherStatus.ready && state.accounts.length == 1 && state.activeDid == null,
          ),
          predicate<AccountSwitcherState>(
            (state) =>
                state.status == AccountSwitcherStatus.ready &&
                state.accounts.length == 1 &&
                state.activeDid == 'did:plc:newuser',
          ),
        ],
        verify: (_) {
          verify(() => mockDatabase.insertAccount(any())).called(1);
          verify(() => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:newuser')).called(1);
        },
      );

      test('persists complete OAuth metadata when adding an account', () async {
        final captured = <AccountsCompanion>[];
        const tokens = AuthTokens(
          accessToken: 'token',
          did: 'did:plc:newuser',
          handle: 'new.bsky.social',
          oauthService: 'bsky.social',
          oauthClientId: 'client-id',
          oauthTokenType: 'DPoP',
          oauthScope: 'atproto transition:generic',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );

        when(() => mockDatabase.insertAccount(any())).thenAnswer((invocation) async {
          captured.add(invocation.positionalArguments.first as AccountsCompanion);
          return 1;
        });
        when(() => mockDatabase.getAllAccounts()).thenAnswer(
          (_) async => [makeAccount(did: 'did:plc:newuser', handle: 'new.bsky.social', dpopPublicKey: 'public-key')],
        );
        when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => null);
        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getAccount('did:plc:newuser'),
        ).thenAnswer((_) async => makeAccount(did: 'did:plc:newuser', handle: 'new.bsky.social'));

        await buildCubit().addAccountCompleted(tokens);

        expect(captured, hasLength(1));
        expect(captured.single.dpopPublicKey.value, 'public-key');
        expect(captured.single.dpopPrivateKey.value, 'private-key');
        expect(captured.single.oauthService.value, 'bsky.social');
        expect(captured.single.oauthClientId.value, 'client-id');
        expect(captured.single.oauthTokenType.value, 'DPoP');
        expect(captured.single.oauthScope.value, 'atproto transition:generic');
      });

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'switches to newly added account even when another was active',
        build: buildCubit,
        seed: () => AccountSwitcherState.ready(
          accounts: [makeAccount(did: 'did:plc:user1')],
          activeDid: 'did:plc:user1',
        ),
        setUp: () {
          when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
          when(() => mockDatabase.getAllAccounts()).thenAnswer(
            (_) async => [
              makeAccount(did: 'did:plc:user1'),
              makeAccount(did: 'did:plc:user2', handle: 'user2.bsky.social'),
            ],
          );
          when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => 'did:plc:user1');
          when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
          when(
            () => mockDatabase.getAccount('did:plc:user2'),
          ).thenAnswer((_) async => makeAccount(did: 'did:plc:user2', handle: 'user2.bsky.social'));
        },
        act: (cubit) => cubit.addAccountCompleted(
          const AuthTokens(accessToken: 'token', did: 'did:plc:user2', handle: 'user2.bsky.social'),
        ),
        expect: () => [
          const AccountSwitcherState.loading(),
          predicate<AccountSwitcherState>(
            (state) =>
                state.status == AccountSwitcherStatus.ready &&
                state.accounts.length == 2 &&
                state.activeDid == 'did:plc:user1',
          ),
          predicate<AccountSwitcherState>((state) => state.activeDid == 'did:plc:user2'),
        ],
      );
    });

    group('addAccountWithOAuth', () {
      test('calls addAccountCompleted and returns tokens on success', () async {
        const tokens = AuthTokens(accessToken: 'new-token', did: 'did:plc:newuser', handle: 'new.bsky.social');

        when(() => mockAuthRepository.loginWithOAuth(any())).thenAnswer((_) async => tokens);
        when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getAllAccounts(),
        ).thenAnswer((_) async => [makeAccount(did: 'did:plc:newuser', handle: 'new.bsky.social')]);
        when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => null);
        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getAccount('did:plc:newuser'),
        ).thenAnswer((_) async => makeAccount(did: 'did:plc:newuser', handle: 'new.bsky.social'));

        final cubit = buildCubit();
        final result = await cubit.addAccountWithOAuth('new.bsky.social');

        expect(result, tokens);
        verify(() => mockAuthRepository.loginWithOAuth('new.bsky.social')).called(1);
        verify(() => mockDatabase.insertAccount(any())).called(1);
      });

      test('returns null when loginWithOAuth throws', () async {
        when(
          () => mockAuthRepository.loginWithOAuth(any()),
        ).thenThrow(const AuthIdentifierResolutionException('Unable to resolve "bad.handle".'));

        final cubit = buildCubit();
        final result = await cubit.addAccountWithOAuth('bad.handle');

        expect(result, isNull);
        expect(cubit.lastAddAccountErrorMessage, equals('Unable to resolve "bad.handle".'));
        verifyNever(() => mockDatabase.insertAccount(any()));
      });

      test('returns curated message when loginWithOAuth fails unexpectedly', () async {
        when(() => mockAuthRepository.loginWithOAuth(any())).thenThrow(Exception('network stack exploded'));

        final cubit = buildCubit();
        final result = await cubit.addAccountWithOAuth('new.bsky.social');

        expect(result, isNull);
        expect(cubit.lastAddAccountErrorMessage, equals('Unable to add account right now. Please try again.'));
        verifyNever(() => mockDatabase.insertAccount(any()));
      });
    });

    group('removeAccount', () {
      test('removes inactive account and reloads accounts', () async {
        when(() => mockDatabase.getAccount('did:plc:user2')).thenAnswer((_) async => makeAccount(did: 'did:plc:user2'));
        when(() => mockDatabase.deleteAccount('did:plc:user2')).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getAllAccounts(),
        ).thenAnswer((_) async => [makeAccount(did: 'did:plc:user1'), makeAccount(did: 'did:plc:user3')]);
        when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => 'did:plc:user1');

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [
              makeAccount(did: 'did:plc:user1'),
              makeAccount(did: 'did:plc:user2'),
            ],
            activeDid: 'did:plc:user1',
          ),
        );

        final result = await cubit.removeAccount('did:plc:user2');

        expect(result.removed, isTrue);
        expect(result.requiresSignIn, isFalse);
        expect(result.switchedTokens, isNull);
        verify(() => mockDatabase.deleteAccount('did:plc:user2')).called(1);
      });

      test('removing active account switches to remaining account', () async {
        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer((_) async => makeAccount(did: 'did:plc:user1'));
        when(() => mockDatabase.deleteAccount('did:plc:user1')).thenAnswer((_) async => 1);
        when(() => mockDatabase.getAllAccounts()).thenAnswer((_) async => [makeAccount(did: 'did:plc:user2')]);
        when(() => mockDatabase.getAccount('did:plc:user2')).thenAnswer((_) async => makeAccount(did: 'did:plc:user2'));
        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
        when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => 'did:plc:user2');

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [
              makeAccount(did: 'did:plc:user1'),
              makeAccount(did: 'did:plc:user2'),
            ],
            activeDid: 'did:plc:user1',
          ),
        );

        final result = await cubit.removeAccount('did:plc:user1');

        expect(result.removed, isTrue);
        expect(result.requiresSignIn, isFalse);
        expect(result.switchedTokens?.did, equals('did:plc:user2'));
      });

      test('removing active account does not refresh/invalidate remaining expired accounts', () async {
        final expiredAt = DateTime.now().subtract(const Duration(hours: 1));
        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer((_) async => makeAccount(did: 'did:plc:user1'));
        when(() => mockDatabase.deleteAccount('did:plc:user1')).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getAllAccounts(),
        ).thenAnswer((_) async => [makeAccount(did: 'did:plc:user2', expiresAt: expiredAt, refreshToken: 'refresh')]);
        when(() => mockDatabase.deleteSetting(any())).thenAnswer((_) async => 1);
        when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => null);

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [
              makeAccount(did: 'did:plc:user1'),
              makeAccount(did: 'did:plc:user2'),
            ],
            activeDid: 'did:plc:user1',
          ),
        );

        final result = await cubit.removeAccount('did:plc:user1');

        expect(result.removed, isTrue);
        expect(result.requiresSignIn, isTrue);
        verifyNever(() => mockAuthRepository.refreshSession(any()));
      });

      test('removing last account requires sign-in', () async {
        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer((_) async => makeAccount(did: 'did:plc:user1'));
        when(() => mockDatabase.deleteAccount('did:plc:user1')).thenAnswer((_) async => 1);
        when(() => mockDatabase.getAllAccounts()).thenAnswer((_) async => []);
        when(() => mockDatabase.deleteSetting(any())).thenAnswer((_) async => 1);
        when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => null);

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [makeAccount(did: 'did:plc:user1')],
            activeDid: 'did:plc:user1',
          ),
        );

        final result = await cubit.removeAccount('did:plc:user1');

        expect(result.removed, isTrue);
        expect(result.requiresSignIn, isTrue);
        expect(result.switchedTokens, isNull);
      });

      test('returns failed when removeAccount hits database exception', () async {
        when(() => mockDatabase.getAccount('did:plc:user1')).thenAnswer((_) async => makeAccount(did: 'did:plc:user1'));
        when(() => mockDatabase.deleteAccount('did:plc:user1')).thenThrow(Exception('db write failed'));

        final cubit = buildCubit();
        cubit.emit(
          AccountSwitcherState.ready(
            accounts: [makeAccount(did: 'did:plc:user1')],
            activeDid: 'did:plc:user1',
          ),
        );

        final result = await cubit.removeAccount('did:plc:user1');

        expect(result.removed, isFalse);
        expect(result.requiresSignIn, isFalse);
      });
    });
  });
}
