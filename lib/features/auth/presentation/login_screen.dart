import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/features/typeahead/presentation/typeahead_text_field.dart';

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
  bool _showDebugForm = false;
  bool _isPersistingProvider = false;
  late final TypeaheadRepository _typeaheadRepository;

  @override
  void initState() {
    super.initState();
    _typeaheadRepository =
        widget.typeaheadRepository ?? TypeaheadRepository(provider: TypeaheadRepository.communityProvider);
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

  bool _isHandleValid() {
    return _formKey.currentState?.validate() ?? false;
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AppView Provider',
                                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment<String>(value: AppViewProviders.blueskyKey, label: Text('Bluesky')),
                                    ButtonSegment<String>(value: AppViewProviders.blackskyKey, label: Text('Blacksky')),
                                  ],
                                  selected: {selectedProvider},
                                  onSelectionChanged: (selection) {
                                    unawaited(context.read<SettingsCubit>().setAppViewProvider(selection.first));
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedProvider == AppViewProviders.blackskyKey
                                      ? 'Sign-in will use Blacksky entryway defaults.'
                                      : 'Sign-in will use Bluesky entryway defaults.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                        TypeaheadTextField(
                          controller: _handleController,
                          repository: _typeaheadRepository,
                          onSelected: _onTypeaheadSelected,
                          minChars: 2,
                          debounceMs: 300,
                          limit: 8,
                          decoration: const InputDecoration(
                            labelText: 'Handle or DID',
                            hintText: 'username.bsky.social or did:plc:...',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your BlueSky handle or DID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final busy = state.isLoading || _isPersistingProvider;
                            return FilledButton.icon(
                              onPressed: busy
                                  ? null
                                  : () {
                                      unawaited(_onOAuthLogin());
                                    },
                              icon: busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.language),
                              label: Text(busy ? 'Starting sign in...' : 'Continue'),
                              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                            );
                          },
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

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
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
          child: SvgPicture.asset(
            'assets/logo.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
