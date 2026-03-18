part of 'account_switcher_cubit.dart';

enum AccountSwitcherStatus { initial, loading, ready }

class AccountSwitcherState extends Equatable {
  const AccountSwitcherState._({required this.status, this.accounts = const [], this.activeDid});

  const AccountSwitcherState.initial() : this._(status: AccountSwitcherStatus.initial);

  const AccountSwitcherState.loading() : this._(status: AccountSwitcherStatus.loading);

  const AccountSwitcherState.ready({required List<Account> accounts, String? activeDid})
    : this._(status: AccountSwitcherStatus.ready, accounts: accounts, activeDid: activeDid);

  final AccountSwitcherStatus status;
  final List<Account> accounts;
  final String? activeDid;

  Account? get activeAccount => accounts.where((a) => a.did == activeDid).firstOrNull;

  AccountSwitcherState copyWith({AccountSwitcherStatus? status, List<Account>? accounts, String? activeDid}) {
    return AccountSwitcherState._(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      activeDid: activeDid ?? this.activeDid,
    );
  }

  @override
  List<Object?> get props => [status, accounts, activeDid];
}
