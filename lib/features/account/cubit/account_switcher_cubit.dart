import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

part 'account_switcher_state.dart';

class AccountSwitcherCubit extends Cubit<AccountSwitcherState> {
  AccountSwitcherCubit({required AppDatabase database})
    : _database = database,
      super(const AccountSwitcherState.initial());

  final AppDatabase _database;

  static const String _keyActiveAccountDid = 'active_account_did';

  Future<void> loadAccounts() async {
    emit(const AccountSwitcherState.loading());

    try {
      final accounts = await _database.getAllAccounts();
      final savedDid = await _database.getSetting(_keyActiveAccountDid);

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

  Future<void> switchAccount(String did) async {
    if (state.status != AccountSwitcherStatus.ready) return;

    await _database.setSetting(_keyActiveAccountDid, did);
    emit(state.copyWith(activeDid: did));
  }

  Future<void> addAccountCompleted(AuthTokens tokens) async {
    await _database.insertAccount(
      AccountsCompanion(
        did: Value(tokens.did),
        handle: Value(tokens.handle),
        displayName: tokens.displayName != null ? Value(tokens.displayName!) : const Value.absent(),
        service: tokens.service != null ? Value(tokens.service!) : const Value.absent(),
        accessToken: Value(tokens.accessToken),
        refreshToken: tokens.refreshToken != null ? Value(tokens.refreshToken!) : const Value.absent(),
        dpopPublicKey: tokens.dpopPublicKey != null ? Value(tokens.dpopPublicKey!) : const Value.absent(),
        dpopNonce: tokens.dpopNonce != null ? Value(tokens.dpopNonce!) : const Value.absent(),
        expiresAt: tokens.expiresAt != null ? Value(tokens.expiresAt!) : const Value.absent(),
      ),
    );

    await loadAccounts();
    await switchAccount(tokens.did);
  }
}
