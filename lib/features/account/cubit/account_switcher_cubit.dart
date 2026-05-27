import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

part 'account_switcher_state.dart';

class AccountRemovalResult {
  const AccountRemovalResult._({required this.removed, required this.requiresSignIn, this.switchedTokens});

  const AccountRemovalResult.removed() : this._(removed: true, requiresSignIn: false);

  const AccountRemovalResult.switched(AuthTokens tokens)
    : this._(removed: true, requiresSignIn: false, switchedTokens: tokens);

  const AccountRemovalResult.requiresSignIn() : this._(removed: true, requiresSignIn: true);

  const AccountRemovalResult.failed() : this._(removed: false, requiresSignIn: false);

  final bool removed;
  final bool requiresSignIn;
  final AuthTokens? switchedTokens;
}

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
      }

      emit(
        AccountSwitcherState.ready(
          accounts: accounts,
          activeDid: activeDid,
          activeAvatarUrl: await _cachedAvatarUrlForDid(activeDid),
        ),
      );
    } catch (error) {
      emit(const AccountSwitcherState.ready(accounts: []));
    }
  }

  Future<AuthTokens?> switchAccount(String did) async {
    if (state.status != AccountSwitcherStatus.ready) return null;

    final account = await _database.getAccount(did);
    if (account == null) return null;

    return _switchToAccount(account, allowRefresh: true);
  }

  Future<AuthTokens?> _switchToAccount(Account account, {required bool allowRefresh}) async {
    final did = account.did;
    final tokens = _tokensFromAccount(account);

    try {
      final nextTokens = tokens.isExpired
          ? !allowRefresh || tokens.refreshToken == null
                ? null
                : await _authRepository.refreshSession(tokens)
          : tokens;

      if (nextTokens == null) {
        return null;
      }

      await _database.setSetting(AppDatabase.activeAccountDidSettingKey, did);
      emit(state.copyWith(activeDid: did, activeAvatarUrl: await _cachedAvatarUrlForDid(did)));
      return nextTokens;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _cachedAvatarUrlForDid(String? did) async {
    if (did == null) {
      return null;
    }

    try {
      final cachedProfile = await (_database.select(
        _database.cachedProfiles,
      )..where((profile) => profile.did.equals(did))).getSingleOrNull();
      final payload = cachedProfile?.payload;
      if (payload == null) {
        return null;
      }
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final avatar = decoded['avatar'];
      return avatar is String && avatar.isNotEmpty ? avatar : null;
    } catch (error, stackTrace) {
      log.d('AccountSwitcherCubit: Failed to read cached avatar for $did', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  AuthTokens _tokensFromAccount(Account account) => AuthTokens(
    accessToken: account.accessToken,
    refreshToken: account.refreshToken,
    expiresAt: account.expiresAt,
    did: account.did,
    handle: account.handle,
    displayName: account.displayName,
    service: account.service,
    oauthService: account.oauthService,
    oauthClientId: account.oauthClientId,
    oauthTokenType: account.oauthTokenType,
    oauthScope: account.oauthScope,
    dpopNonce: account.dpopNonce,
    dpopPublicKey: account.dpopPublicKey,
    dpopPrivateKey: account.dpopPrivateKey,
    authMethod: account.dpopPrivateKey != null && account.dpopPublicKey != null
        ? AuthMethod.oauth
        : AuthMethod.appPassword,
  );

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
    } catch (error, _) {
      _lastAddAccountErrorMessage = _userFacingAddAccountErrorMessage(error);
      return null;
    }
  }

  String _userFacingAddAccountErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Sign-in timed out before completion. Please try again.';
    }
    return 'Unable to add account right now. Please try again.';
  }

  Future<void> addAccountCompleted(AuthTokens tokens) async {
    await _database.insertAccount(
      AccountsCompanion(
        did: Value(tokens.did),
        handle: Value(tokens.handle),
        displayName: tokens.displayName != null ? Value(tokens.displayName!) : const Value.absent(),
        service: tokens.service != null ? Value(tokens.service!) : const Value.absent(),
        oauthService: tokens.oauthService != null ? Value(tokens.oauthService!) : const Value.absent(),
        oauthClientId: tokens.oauthClientId != null ? Value(tokens.oauthClientId!) : const Value.absent(),
        oauthTokenType: tokens.oauthTokenType != null ? Value(tokens.oauthTokenType!) : const Value.absent(),
        oauthScope: tokens.oauthScope != null ? Value(tokens.oauthScope!) : const Value.absent(),
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

  Future<AccountRemovalResult> removeAccount(String did) async {
    try {
      if (state.status != AccountSwitcherStatus.ready) {
        return const AccountRemovalResult.failed();
      }

      final account = await _database.getAccount(did);
      if (account == null) {
        return const AccountRemovalResult.failed();
      }

      final wasActive = state.activeDid == did;
      await _database.deleteAccount(did);

      if (!wasActive) {
        await loadAccounts();
        return const AccountRemovalResult.removed();
      }

      final remainingAccounts = await _database.getAllAccounts();
      if (remainingAccounts.isEmpty) {
        await _database.deleteSetting(AppDatabase.activeAccountDidSettingKey);
        await loadAccounts();
        return const AccountRemovalResult.requiresSignIn();
      }

      for (final remaining in remainingAccounts) {
        final switchedTokens = await _switchToAccount(remaining, allowRefresh: false);
        if (switchedTokens != null) {
          await loadAccounts();
          return AccountRemovalResult.switched(switchedTokens);
        }
      }

      await _database.deleteSetting(AppDatabase.activeAccountDidSettingKey);
      await loadAccounts();
      return const AccountRemovalResult.requiresSignIn();
    } catch (error, stackTrace) {
      log.w('AccountSwitcherCubit: Failed to remove account $did', error: error, stackTrace: stackTrace);
      return const AccountRemovalResult.failed();
    }
  }
}
