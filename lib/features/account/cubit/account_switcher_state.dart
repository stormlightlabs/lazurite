part of 'account_switcher_cubit.dart';

enum AccountSwitcherStatus { initial, loading, ready }

const _accountSwitcherNoValue = Object();

class AccountSwitcherState extends Equatable {
  const AccountSwitcherState._({required this.status, this.accounts = const [], this.activeDid, this.activeAvatarUrl});

  const AccountSwitcherState.initial() : this._(status: AccountSwitcherStatus.initial);

  const AccountSwitcherState.loading() : this._(status: AccountSwitcherStatus.loading);

  const AccountSwitcherState.ready({required List<Account> accounts, String? activeDid, String? activeAvatarUrl})
    : this._(
        status: AccountSwitcherStatus.ready,
        accounts: accounts,
        activeDid: activeDid,
        activeAvatarUrl: activeAvatarUrl,
      );

  final AccountSwitcherStatus status;
  final List<Account> accounts;
  final String? activeDid;
  final String? activeAvatarUrl;

  Account? get activeAccount => accounts.where((a) => a.did == activeDid).firstOrNull;

  AccountSwitcherState copyWith({
    AccountSwitcherStatus? status,
    List<Account>? accounts,
    Object? activeDid = _accountSwitcherNoValue,
    Object? activeAvatarUrl = _accountSwitcherNoValue,
  }) => AccountSwitcherState._(
    status: status ?? this.status,
    accounts: accounts ?? this.accounts,
    activeDid: identical(activeDid, _accountSwitcherNoValue) ? this.activeDid : activeDid as String?,
    activeAvatarUrl: identical(activeAvatarUrl, _accountSwitcherNoValue)
        ? this.activeAvatarUrl
        : activeAvatarUrl as String?,
  );

  @override
  List<Object?> get props => [status, accounts, activeDid, activeAvatarUrl];
}
