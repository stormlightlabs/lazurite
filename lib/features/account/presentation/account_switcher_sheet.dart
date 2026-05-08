import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/atproto_identifier.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/features/typeahead/presentation/typeahead_text_field.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

String? validateAtProtoIdentifierInput(String? value) {
  final normalized = normalizeAtProtoIdentifierForAuth(value ?? '');
  final validationError = validateAtProtoIdentifierForAuth(normalized);
  if (validationError == null) {
    return null;
  }

  final code = validationError.code;
  return code.message;
}

String? validateAtProtoIdentifierInputLocalized(BuildContext context, String? value) {
  final normalized = normalizeAtProtoIdentifierForAuth(value ?? '');
  final validationError = validateAtProtoIdentifierForAuth(normalized);
  if (validationError == null) {
    return null;
  }

  return _localizedAtProtoIdentifierValidationMessage(context, validationError.code);
}

String _localizedAtProtoIdentifierValidationMessage(BuildContext context, AtProtoIdentifierValidationErrorCode code) {
  return switch (code) {
    AtProtoIdentifierValidationErrorCode.empty => context.l10n.validationEnterBlueskyHandleOrDid,
    AtProtoIdentifierValidationErrorCode.unsupportedDid => context.l10n.validationUseSupportedDid,
    AtProtoIdentifierValidationErrorCode.invalidDid => context.l10n.validationEnterCompleteDid,
    AtProtoIdentifierValidationErrorCode.invalidHandle => context.l10n.validationEnterFullHandle,
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

  static bool _isIdentifierInputValid(String value) => validateAtProtoIdentifierInput(value) == null;

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
            child: Text(context.l10n.labelAccounts, style: textTheme.titleMedium),
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

              if (state.accounts.isEmpty) return _buildEmptyState(context, colorScheme, textTheme);

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
                          tooltip: context.l10n.labelRemoveAccount,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _onRemoveAccount(context, account.did, account.handle),
                        ),
                      ],
                    ),
                    onTap: isActive ? null : () => _onSwitchAccount(context, account),
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: Text(context.l10n.buttonAddAccount),
            onTap: () => _onAddAccount(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
    child: Row(
      children: [
        Icon(Icons.swap_horiz_outlined, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            context.l10n.accountSwitcherNoOtherAccounts,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    ),
  );

  Future<void> _onSwitchAccount(BuildContext context, Account account) async {
    final cubit = context.read<AccountSwitcherCubit>();
    Navigator.pop(context);
    final tokens = await cubit.switchAccount(account.did);
    if (tokens != null) {
      authBloc.add(SessionRestored(tokens: tokens));
      return;
    }

    if (parentContext.mounted) {
      showAppSnackBar(parentContext, parentContext.l10n.messagePleaseSignInAgainForAccount);
      final router = GoRouter.maybeOf(parentContext);
      if (router != null) {
        unawaited(Future<void>.delayed(Duration.zero, () => router.go(_reauthLoginLocation(account.handle))));
      }
    }
  }

  String _reauthLoginLocation(String handle) =>
      Uri(path: '/login', queryParameters: {'reauth': '1', 'handle': handle}).toString();

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
          title: Text(parentContext.l10n.buttonAddAccount),
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
                decoration: InputDecoration(
                  labelText: parentContext.l10n.promptHandleOrDid,
                  hintText: parentContext.l10n.placeholderUsernameBskySocial,
                ),
                textInputAction: TextInputAction.done,
                validator: (value) => validateAtProtoIdentifierInputLocalized(parentContext, value),
                onChanged: (_) => setDialogState(() {}),
                onFieldSubmitted: (_) {
                  if ((formKey.currentState?.validate() ?? false)) {
                    Navigator.pop(dialogContext, controller.text.trim());
                  }
                },
              ),
            ),
          ),
          confirmEnabled: _isIdentifierInputValid(controller.text.trim()),
          confirmLabel: parentContext.l10n.buttonContinue,
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
      showAppSnackBar(
        parentContext,
        cubit.lastAddAccountErrorMessage ?? parentContext.l10n.errorFailedToAddAccount,
        isError: true,
      );
    }
  }

  Future<void> _onRemoveAccount(BuildContext context, String did, String handle) async {
    final cubit = context.read<AccountSwitcherCubit>();
    final remove = await showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) => ConfirmationDialog(
        title: Text(parentContext.l10n.dialogRemoveAccountTitle),
        content: Text(parentContext.l10n.formatRemoveAccountContent(handle)),
        confirmLabel: parentContext.l10n.buttonRemove,
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
        showAppSnackBar(parentContext, parentContext.l10n.errorUnableToRemoveAccountNow, isError: true);
      }
      return;
    }

    final switchedTokens = result.switchedTokens;
    if (switchedTokens != null) {
      authBloc.add(SessionRestored(tokens: switchedTokens));
    }

    if (result.requiresSignIn && parentContext.mounted) {
      authBloc.add(const SessionCleared());
      Navigator.pop(context);
      final router = GoRouter.maybeOf(parentContext);
      if (router != null) {
        router.go('/login?reauth=1');
      }
    }
  }
}
