import 'package:bloc_test/bloc_test.dart';
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
  }) {
    return Account(
      did: did,
      handle: handle,
      displayName: null,
      service: null,
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

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'defaults to first account when no saved active did',
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
            (state) => state.status == AccountSwitcherStatus.ready && state.activeDid == 'did:plc:user1',
          ),
        ],
      );

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'defaults to first account when saved did not in accounts',
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
            (state) => state.status == AccountSwitcherStatus.ready && state.activeDid == 'did:plc:user1',
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

        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
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
      });

      test('returns null when account is expired and has no refresh token', () async {
        final expiredAt = DateTime.now().subtract(const Duration(hours: 1));

        when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
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
          verify(() => mockDatabase.setSetting('active_account_did', 'did:plc:user2')).called(1);
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
                state.status == AccountSwitcherStatus.ready &&
                state.accounts.length == 1 &&
                state.activeDid == 'did:plc:newuser',
          ),
        ],
        verify: (_) {
          verify(() => mockDatabase.insertAccount(any())).called(1);
          verify(() => mockDatabase.setSetting('active_account_did', 'did:plc:newuser')).called(1);
        },
      );

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
        when(() => mockAuthRepository.loginWithOAuth(any())).thenThrow(Exception('OAuth failed'));

        final cubit = buildCubit();
        final result = await cubit.addAccountWithOAuth('bad.handle');

        expect(result, isNull);
        verifyNever(() => mockDatabase.insertAccount(any()));
      });
    });
  });
}
