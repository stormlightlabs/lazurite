import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class AccountsCompanionFake extends Fake implements AccountsCompanion {}

void main() {
  late MockAppDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValue(AccountsCompanionFake());
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
  });

  Account makeAccount({required String did, String handle = 'user.bsky.social'}) {
    return Account(
      did: did,
      handle: handle,
      displayName: null,
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

  group('AccountSwitcherCubit', () {
    group('loadAccounts', () {
      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'emits loading then ready with accounts when accounts exist',
        build: () => AccountSwitcherCubit(database: mockDatabase),
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
        build: () => AccountSwitcherCubit(database: mockDatabase),
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
        build: () => AccountSwitcherCubit(database: mockDatabase),
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
        build: () => AccountSwitcherCubit(database: mockDatabase),
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
        'updates activeDid when switching accounts',
        build: () => AccountSwitcherCubit(database: mockDatabase),
        seed: () => AccountSwitcherState.ready(
          accounts: [
            makeAccount(did: 'did:plc:user1'),
            makeAccount(did: 'did:plc:user2'),
          ],
          activeDid: 'did:plc:user1',
        ),
        setUp: () {
          when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
        },
        act: (cubit) => cubit.switchAccount('did:plc:user2'),
        expect: () => [predicate<AccountSwitcherState>((state) => state.activeDid == 'did:plc:user2')],
        verify: (_) {
          verify(() => mockDatabase.setSetting('active_account_did', 'did:plc:user2')).called(1);
        },
      );

      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'does nothing when state is not ready',
        build: () => AccountSwitcherCubit(database: mockDatabase),
        act: (cubit) => cubit.switchAccount('did:plc:user1'),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockDatabase.setSetting(any(), any()));
        },
      );
    });

    group('addAccountCompleted', () {
      blocTest<AccountSwitcherCubit, AccountSwitcherState>(
        'inserts account, reloads, and activeDid is set to the new account',
        build: () => AccountSwitcherCubit(database: mockDatabase),
        setUp: () {
          when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
          when(
            () => mockDatabase.getAllAccounts(),
          ).thenAnswer((_) async => [makeAccount(did: 'did:plc:newuser', handle: 'new.bsky.social')]);
          when(() => mockDatabase.getSetting(any())).thenAnswer((_) async => null);
          when(() => mockDatabase.setSetting(any(), any())).thenAnswer((_) async => 1);
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
        build: () => AccountSwitcherCubit(database: mockDatabase),
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
  });
}
