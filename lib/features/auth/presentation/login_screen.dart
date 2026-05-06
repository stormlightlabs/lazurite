import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/features/typeahead/presentation/typeahead_text_field.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({this.typeaheadRepository, super.key});

  final TypeaheadRepository? typeaheadRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _handleController = TextEditingController();
  final _appPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Map<String, Future<String?>> _avatarFutureByDid = <String, Future<String?>>{};
  bool _showDebugForm = false;
  bool _isPersistingProvider = false;
  bool _didRequestAccountsLoad = false;
  bool _didLogMissingAccountSwitcherProvider = false;
  bool _didLogAvatarLookupFailure = false;
  late final TypeaheadRepository _typeaheadRepository;

  AccountSwitcherCubit? _maybeAccountSwitcherCubit(BuildContext context) {
    try {
      return context.read<AccountSwitcherCubit>();
    } catch (_) {
      if (kDebugMode && !_didLogMissingAccountSwitcherProvider) {
        debugPrint('LoginScreen: AccountSwitcherCubit unavailable for login route.');
        _didLogMissingAccountSwitcherProvider = true;
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _typeaheadRepository =
        widget.typeaheadRepository ?? TypeaheadRepository(provider: TypeaheadRepository.communityProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRequestAccountsLoad) {
      return;
    }

    final accountSwitcherCubit = _maybeAccountSwitcherCubit(context);
    if (accountSwitcherCubit == null) {
      return;
    }

    _didRequestAccountsLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(accountSwitcherCubit.loadAccounts());
    });
  }

  @override
  void dispose() {
    _handleController.dispose();
    _appPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onOAuthLogin() async {
    if (!_isHandleValid()) {
      return;
    }

    final persisted = await _persistSelectedProvider();
    if (!persisted) {
      return;
    }
    if (!mounted) {
      return;
    }
    context.read<AuthBloc>().add(OAuthLoginRequested(handle: _handleController.text.trim()));
  }

  Future<void> _onAppPasswordLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final persisted = await _persistSelectedProvider();
    if (!persisted) {
      return;
    }
    if (!mounted) {
      return;
    }
    context.read<AuthBloc>().add(
      LoginRequested(handle: _handleController.text.trim(), appPassword: _appPasswordController.text.trim()),
    );
  }

  bool _isHandleValid() => _formKey.currentState?.validate() ?? false;

  void _onTypeaheadSelected(TypeaheadResult result) {
    _handleController.text = result.handle;
    unawaited(_onOAuthLogin());
  }

  Future<bool> _persistSelectedProvider() async {
    final settingsCubit = context.read<SettingsCubit>();
    if (_isPersistingProvider) {
      return false;
    }

    setState(() {
      _isPersistingProvider = true;
    });
    try {
      await settingsCubit.setAppViewProvider(settingsCubit.state.appViewProvider);
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save provider selection: $error')));
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isPersistingProvider = false;
        });
      }
    }
  }

  Future<void> _onRemoveSavedAccount(Account account) async {
    final cubit = _maybeAccountSwitcherCubit(context);
    if (cubit == null) {
      return;
    }

    final remove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Account'),
        content: Text('Remove @${account.handle} from this device?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Remove')),
        ],
      ),
    );

    if (remove != true) {
      return;
    }

    final result = await cubit.removeAccount(account.did);
    if (!result.removed) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to remove account right now.')));
      return;
    }

    final switchedTokens = result.switchedTokens;
    if (switchedTokens != null && mounted) {
      context.read<AuthBloc>().add(SessionRestored(tokens: switchedTokens));
    }

    if (result.requiresSignIn && mounted) {
      context.read<AuthBloc>().add(const SessionCleared());
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        router.go('/login?reauth=1');
      }
    }
  }

  Future<String?> _loadCachedAvatarUrlForDid(String did) async {
    try {
      final database = context.read<AppDatabase>();
      final profile = await (database.select(
        database.cachedProfiles,
      )..where((profile) => profile.did.equals(did))).getSingleOrNull();
      if (profile == null) {
        return null;
      }

      final json = jsonDecode(profile.payload);
      if (json is! Map<String, dynamic>) {
        return null;
      }

      final avatar = json['avatar'];
      if (avatar is String && avatar.isNotEmpty) {
        return avatar;
      }
      return null;
    } catch (_) {
      if (kDebugMode && !_didLogAvatarLookupFailure) {
        debugPrint('LoginScreen: cached avatar lookup unavailable.');
        _didLogAvatarLookupFailure = true;
      }
      return null;
    }
  }

  Future<String?> _avatarFutureForDid(String did) =>
      _avatarFutureByDid.putIfAbsent(did, () => _loadCachedAvatarUrlForDid(did));

  void _pruneAvatarFutureCache(Iterable<String> activeDids) {
    final activeDidSet = activeDids.toSet();
    _avatarFutureByDid.removeWhere((did, _) => !activeDidSet.contains(did));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountSwitcherCubit = _maybeAccountSwitcherCubit(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.surface, colorScheme.surfaceContainerLowest],
          ),
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.isAuthenticated) {
                context.go('/');
                return;
              }
              if (state.hasError && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _LogoCard(colorScheme: colorScheme),
                        const SizedBox(height: 24),
                        Text(
                          'Lazurite',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Roam the ATmosphere',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<SettingsCubit, SettingsState>(
                          builder: (context, settingsState) {
                            final selectedProvider = settingsState.appViewProvider;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Choose your portal',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment<String>(
                                        value: AppViewProviders.blueskyKey,
                                        label: _ProviderTabLabel(assetPath: 'assets/bluesky.svg', name: 'BlueSky'),
                                      ),
                                      ButtonSegment<String>(
                                        value: AppViewProviders.blackskyKey,
                                        label: _ProviderTabLabel(assetPath: 'assets/blacksky.svg', name: 'BlackSky'),
                                      ),
                                    ],
                                    selected: {selectedProvider},
                                    onSelectionChanged: (selection) {
                                      unawaited(context.read<SettingsCubit>().setAppViewProvider(selection.first));
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final busy = state.isLoading || _isPersistingProvider;
                            final border = OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
                            );

                            return TypeaheadTextField(
                              controller: _handleController,
                              repository: _typeaheadRepository,
                              onSelected: _onTypeaheadSelected,
                              minChars: 2,
                              debounceMs: 300,
                              limit: 8,
                              decoration: InputDecoration(
                                hintText: 'username.bsky.social or did:plc:...',
                                prefixIcon: const Icon(Icons.person_outline),
                                filled: true,
                                fillColor: colorScheme.surface,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                border: border,
                                enabledBorder: border,
                                focusedBorder: border.copyWith(
                                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                                ),
                                suffixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: FilledButton(
                                    key: const ValueKey<String>('login-continue-button'),
                                    onPressed: busy
                                        ? null
                                        : () {
                                            unawaited(_onOAuthLogin());
                                          },
                                    style: FilledButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(40, 40),
                                      maximumSize: const Size(40, 40),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: busy
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ),
                                ),
                              ),
                              autocorrect: false,
                              textInputAction: TextInputAction.go,
                              onFieldSubmitted: (_) => unawaited(_onOAuthLogin()),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter your BlueSky handle or DID';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (accountSwitcherCubit != null)
                          BlocProvider.value(
                            value: accountSwitcherCubit,
                            child: BlocBuilder<AccountSwitcherCubit, AccountSwitcherState>(
                              builder: (context, state) {
                                if (state.status == AccountSwitcherStatus.loading ||
                                    state.status == AccountSwitcherStatus.initial) {
                                  return const _SavedAccountsLoading();
                                }

                                if (state.accounts.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                _pruneAvatarFutureCache(state.accounts.map((account) => account.did));
                                return _SavedAccountsSection(
                                  accounts: state.accounts,
                                  avatarFutureForDid: _avatarFutureForDid,
                                  onSelect: (account) {
                                    _handleController.text = account.handle;
                                    _handleController.selection = TextSelection.collapsed(
                                      offset: _handleController.text.length,
                                    );
                                  },
                                  onRemove: (account) {
                                    unawaited(_onRemoveSavedAccount(account));
                                  },
                                );
                              },
                            ),
                          ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('Debug', style: theme.textTheme.labelMedium),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Card.outlined(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.bug_report_outlined),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('App Password Login', style: theme.textTheme.titleMedium)),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _showDebugForm = !_showDebugForm;
                                          });
                                        },
                                        child: Text(_showDebugForm ? 'Hide' : 'Show'),
                                      ),
                                    ],
                                  ),
                                  if (_showDebugForm) ...[
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _appPasswordController,
                                      decoration: const InputDecoration(
                                        labelText: 'App Password',
                                        hintText: 'xxxx-xxxx-xxxx-xxxx',
                                        prefixIcon: Icon(Icons.lock_outline),
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (_showDebugForm && (value == null || value.trim().isEmpty)) {
                                          return 'Enter your app password';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (_) => _onAppPasswordLogin(),
                                    ),
                                    const SizedBox(height: 12),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        final busy = state.isLoading || _isPersistingProvider;
                                        return OutlinedButton.icon(
                                          onPressed: busy
                                              ? null
                                              : () {
                                                  unawaited(_onAppPasswordLogin());
                                                },
                                          icon: const Icon(Icons.login),
                                          label: const Text('Sign In'),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Can be generated via BlueSky\'s App Passwords section at bsky.app.',
                                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            TextButton(onPressed: () => context.push('/terms'), child: const Text('Terms of Service')),
                            Text('•', style: theme.textTheme.bodySmall),
                            TextButton(onPressed: () => context.push('/privacy'), child: const Text('Privacy Policy')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderTabLabel extends StatelessWidget {
  const _ProviderTabLabel({required this.assetPath, required this.name});

  static const _blackSkyAssetPath = 'assets/blacksky.svg';
  static const _blackSkyDarkModeColor = Color(0xFF6868B6);

  final String assetPath;
  final String name;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset(
        assetPath,
        height: 16,
        colorFilter: assetPath == _blackSkyAssetPath && Theme.of(context).brightness == Brightness.dark
            ? const ColorFilter.mode(_blackSkyDarkModeColor, BlendMode.srcIn)
            : null,
      ),
      const SizedBox(width: 8),
      Text(name),
    ],
  );
}

class _SavedAccountsSection extends StatelessWidget {
  const _SavedAccountsSection({
    required this.accounts,
    required this.avatarFutureForDid,
    required this.onSelect,
    required this.onRemove,
  });

  final List<Account> accounts;
  final Future<String?> Function(String did) avatarFutureForDid;
  final ValueChanged<Account> onSelect;
  final ValueChanged<Account> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Saved accounts', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              for (var index = 0; index < accounts.length; index++) ...[
                _SavedAccountTile(
                  key: ValueKey<String>('saved-account-${accounts[index].did}'),
                  account: accounts[index],
                  avatarFutureForDid: avatarFutureForDid,
                  onTap: () => onSelect(accounts[index]),
                  onRemove: () => onRemove(accounts[index]),
                ),
                if (index != accounts.length - 1) Divider(height: 1, color: colorScheme.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SavedAccountsLoading extends StatelessWidget {
  const _SavedAccountsLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Saved accounts', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 10),
                Text('Loading saved accounts...'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SavedAccountTile extends StatelessWidget {
  const _SavedAccountTile({
    required this.account,
    required this.avatarFutureForDid,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final Account account;
  final Future<String?> Function(String did) avatarFutureForDid;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final label = account.displayName ?? account.handle;
    return FutureBuilder<String?>(
      future: avatarFutureForDid(account.did),
      builder: (context, snapshot) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          leading: ProfileAvatar(size: 36, fallbackText: label, imageUrl: snapshot.data),
          title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('@${account.handle}', maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(tooltip: 'Remove account', icon: const Icon(Icons.close_rounded), onPressed: onRemove),
          onTap: onTap,
        );
      },
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
        boxShadow: [
          BoxShadow(color: colorScheme.primary.withValues(alpha: 0.24), blurRadius: 28, offset: const Offset(0, 12)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SvgPicture.asset('assets/logo.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
      ),
    ),
  );
}
