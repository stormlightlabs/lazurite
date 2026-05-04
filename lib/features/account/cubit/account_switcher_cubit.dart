import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

part 'account_switcher_state.dart';

class AccountSwitcherCubit extends Cubit<AccountSwitcherState> {
  AccountSwitcherCubit({required AppDatabase database, required AuthRepository authRepository})
    : _database = database,
      _authRepository = authRepository,
      super(const AccountSwitcherState.initial());

  final AppDatabase _database;
  final AuthRepository _authRepository;
  String? _lastAddAccountErrorMessage;

  String? get lastAddAccountErrorMessage => _lastAddAccountErrorMessage;

  Future<void> loadAccounts() async {
    emit(const AccountSwitcherState.loading());

    try {
      final accounts = await _database.getAllAccounts();
      final savedDid = await _database.getSetting(AppDatabase.activeAccountDidSettingKey);

      String? activeDid;
      if (savedDid != null && accounts.any((a) => a.did == savedDid)) {
        activeDid = savedDid;
      } else if (accounts.isNotEmpty) {
        activeDid = accounts.first.did;
      }

      emit(AccountSwitcherState.ready(accounts: accounts, activeDid: activeDid));
    } catch (error) {
      emit(const AccountSwitcherState.ready(accounts: []));
    }
  }

  Future<AuthTokens?> switchAccount(String did) async {
    if (state.status != AccountSwitcherStatus.ready) return null;

    final account = await _database.getAccount(did);
    if (account == null) return null;

    final tokens = AuthTokens(
      accessToken: account.accessToken,
      refreshToken: account.refreshToken,
      expiresAt: account.expiresAt,
      did: account.did,
      handle: account.handle,
      displayName: account.displayName,
      service: account.service,
      oauthService: account.oauthService,
      dpopNonce: account.dpopNonce,
      dpopPublicKey: account.dpopPublicKey,
      dpopPrivateKey: account.dpopPrivateKey,
      authMethod: account.dpopPrivateKey != null && account.dpopPublicKey != null
          ? AuthMethod.oauth
          : AuthMethod.appPassword,
    );

    try {
      final nextTokens = tokens.isExpired
          ? tokens.refreshToken == null
                ? null
                : await _authRepository.refreshSession(tokens)
          : tokens;

      if (nextTokens == null) {
        return null;
      }

      await _database.setSetting(AppDatabase.activeAccountDidSettingKey, did);
      emit(state.copyWith(activeDid: did));
      return nextTokens;
    } catch (_) {
      return null;
    }
  }

  Future<AuthTokens?> addAccountWithOAuth(String handle) async {
    _lastAddAccountErrorMessage = null;
    try {
      final tokens = await _authRepository.loginWithOAuth(handle);
      if (tokens == null) return null;
      await addAccountCompleted(tokens);
      return tokens;
    } on AuthIdentifierResolutionException catch (error) {
      _lastAddAccountErrorMessage = error.message;
      return null;
    } catch (error) {
      _lastAddAccountErrorMessage = error.toString();
      return null;
    }
  }

  Future<void> addAccountCompleted(AuthTokens tokens) async {
    await _database.insertAccount(
      AccountsCompanion(
        did: Value(tokens.did),
        handle: Value(tokens.handle),
        displayName: tokens.displayName != null ? Value(tokens.displayName!) : const Value.absent(),
        service: tokens.service != null ? Value(tokens.service!) : const Value.absent(),
        oauthService: tokens.oauthService != null ? Value(tokens.oauthService!) : const Value.absent(),
        accessToken: Value(tokens.accessToken),
        refreshToken: tokens.refreshToken != null ? Value(tokens.refreshToken!) : const Value.absent(),
        dpopPublicKey: tokens.dpopPublicKey != null ? Value(tokens.dpopPublicKey!) : const Value.absent(),
        dpopPrivateKey: tokens.dpopPrivateKey != null ? Value(tokens.dpopPrivateKey!) : const Value.absent(),
        dpopNonce: tokens.dpopNonce != null ? Value(tokens.dpopNonce!) : const Value.absent(),
        expiresAt: tokens.expiresAt != null ? Value(tokens.expiresAt!) : const Value.absent(),
      ),
    );

    await loadAccounts();
    await switchAccount(tokens.did);
  }
}
