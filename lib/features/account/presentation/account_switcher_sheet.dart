import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/atproto_identifier.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/features/typeahead/presentation/typeahead_text_field.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';

String? validateAtProtoIdentifierInput(String? value) {
  final normalized = normalizeAtProtoIdentifierForAuth(value ?? '');
  final validationError = validateAtProtoIdentifierForAuth(normalized);
  if (validationError == null) {
    return null;
  }

  return switch (validationError.code) {
    AtProtoIdentifierValidationErrorCode.empty => 'Enter a Bluesky handle or DID',
    AtProtoIdentifierValidationErrorCode.unsupportedDid => 'Use a did:plc:... or did:web:... identifier',
    AtProtoIdentifierValidationErrorCode.invalidHandle => 'Enter a full handle like username.bsky.social',
  };
}

void showAccountSwitcherSheet(BuildContext context) {
  final cubit = context.read<AccountSwitcherCubit>();
  final authBloc = context.read<AuthBloc>();
  final typeaheadRepository = context.read<TypeaheadRepository>();
  final parentContext = context;
  unawaited(cubit.loadAccounts());

  showAppBottomSheet<void>(
    context: context,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: _AccountSwitcherSheet(
        authBloc: authBloc,
        parentContext: parentContext,
        typeaheadRepository: typeaheadRepository,
      ),
    ),
  );
}

class _AccountSwitcherSheet extends StatelessWidget {
  const _AccountSwitcherSheet({required this.authBloc, required this.parentContext, required this.typeaheadRepository});

  final AuthBloc authBloc;
  final BuildContext parentContext;
  final TypeaheadRepository typeaheadRepository;

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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive) const Icon(Icons.check),
                        IconButton(
                          tooltip: 'Remove account',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _onRemoveAccount(context, account.did, account.handle),
                        ),
                      ],
                    ),
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

    if (parentContext.mounted) {
      showAppSnackBar(parentContext, 'Please sign in again for that account.');
      final router = GoRouter.maybeOf(parentContext);
      if (router != null) {
        unawaited(Future<void>.delayed(Duration.zero, () => router.go('/login?reauth=1')));
      }
    }
  }

  Future<void> _onAddAccount(BuildContext context) async {
    final cubit = context.read<AccountSwitcherCubit>();
    Navigator.pop(context);

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final focusNode = FocusNode();
    final handle = await showDialog<String>(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => ConfirmationDialog(
          title: const Text('Add Account'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: TypeaheadTextField(
                controller: controller,
                focusNode: focusNode,
                repository: typeaheadRepository,
                onSelected: (TypeaheadResult result) {
                  controller.text = result.handle;
                  setDialogState(() {});
                },
                minChars: 2,
                debounceMs: 300,
                limit: 8,
                decoration: const InputDecoration(labelText: 'Handle or DID', hintText: 'username.bsky.social'),
                textInputAction: TextInputAction.done,
                validator: validateAtProtoIdentifierInput,
                onChanged: (_) => setDialogState(() {}),
                onFieldSubmitted: (_) {
                  if ((formKey.currentState?.validate() ?? false)) {
                    Navigator.pop(dialogContext, controller.text.trim());
                  }
                },
              ),
            ),
          ),
          confirmEnabled: controller.text.trim().isNotEmpty,
          confirmLabel: 'Continue',
          onCancel: () => Navigator.pop(dialogContext),
          onConfirm: () {
            if (!(formKey.currentState?.validate() ?? false)) {
              return;
            }
            Navigator.pop(dialogContext, controller.text.trim());
          },
        ),
      ),
    );
    controller.dispose();
    focusNode.dispose();

    if (handle == null || handle.isEmpty) return;

    final tokens = await cubit.addAccountWithOAuth(handle);
    if (tokens != null) {
      authBloc.add(SessionRestored(tokens: tokens));
    } else if (parentContext.mounted) {
      showAppSnackBar(parentContext, cubit.lastAddAccountErrorMessage ?? 'Failed to add account', isError: true);
    }
  }

  Future<void> _onRemoveAccount(BuildContext context, String did, String handle) async {
    final cubit = context.read<AccountSwitcherCubit>();
    final remove = await showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) => ConfirmationDialog(
        title: const Text('Remove Account'),
        content: Text('Remove @$handle from this device?'),
        confirmLabel: 'Remove',
        onCancel: () => Navigator.pop(dialogContext, false),
        onConfirm: () => Navigator.pop(dialogContext, true),
      ),
    );

    if (remove != true) {
      return;
    }

    final result = await cubit.removeAccount(did);
    if (!result.removed) {
      if (parentContext.mounted) {
        showAppSnackBar(parentContext, 'Unable to remove account right now.', isError: true);
      }
      return;
    }

    final switchedTokens = result.switchedTokens;
    if (switchedTokens != null) {
      authBloc.add(SessionRestored(tokens: switchedTokens));
    }

    if (result.requiresSignIn && parentContext.mounted) {
      Navigator.pop(context);
      final router = GoRouter.maybeOf(parentContext);
      if (router != null) {
        router.go('/login?reauth=1');
      }
    }
  }
}
