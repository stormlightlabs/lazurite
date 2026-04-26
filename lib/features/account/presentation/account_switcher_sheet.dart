import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';

void showAccountSwitcherSheet(BuildContext context) {
  final cubit = context.read<AccountSwitcherCubit>();
  final authBloc = context.read<AuthBloc>();

  showAppBottomSheet<void>(
    context: context,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: _AccountSwitcherSheet(authBloc: authBloc),
    ),
  );
}

class _AccountSwitcherSheet extends StatelessWidget {
  const _AccountSwitcherSheet({required this.authBloc});

  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Accounts', style: textTheme.titleMedium),
          ),
          const Divider(),
          BlocBuilder<AccountSwitcherCubit, AccountSwitcherState>(
            builder: (context, state) {
              if (state.status == AccountSwitcherStatus.loading || state.status == AccountSwitcherStatus.initial) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.accounts.isEmpty) return _buildEmptyState(colorScheme, textTheme);

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  final isActive = account.did == state.activeDid;
                  final label = account.displayName ?? account.handle;

                  return ListTile(
                    leading: ProfileAvatar(size: 40, fallbackText: label),
                    title: Text(label),
                    subtitle: Text('@${account.handle}'),
                    trailing: isActive ? const Icon(Icons.check) : null,
                    onTap: isActive ? null : () => _onSwitchAccount(context, account.did),
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: const Text('Add Account'),
            onTap: () => _onAddAccount(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Row(
        children: [
          Icon(Icons.swap_horiz_outlined, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No other signed-in accounts yet. Add an account to switch between profiles.',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSwitchAccount(BuildContext context, String did) async {
    final cubit = context.read<AccountSwitcherCubit>();
    Navigator.pop(context);
    final tokens = await cubit.switchAccount(did);
    if (tokens != null) {
      authBloc.add(SessionRestored(tokens: tokens));
      return;
    }

    if (context.mounted) {
      showAppSnackBar(context, 'Unable to switch accounts. Sign in again for that account.');
    }
  }

  Future<void> _onAddAccount(BuildContext context) async {
    final cubit = context.read<AccountSwitcherCubit>();
    Navigator.pop(context);

    final controller = TextEditingController();
    final handle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: const Text('Add Account'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Handle or DID'),
          autofocus: true,
        ),
        confirmLabel: 'Continue',
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () => Navigator.pop(dialogContext, controller.text.trim()),
      ),
    );
    controller.dispose();

    if (handle == null || handle.isEmpty) return;

    final tokens = await cubit.addAccountWithOAuth(handle);
    if (tokens != null) {
      authBloc.add(SessionRestored(tokens: tokens));
    } else if (context.mounted) {
      showAppSnackBar(context, 'Failed to add account', isError: true);
    }
  }
}
