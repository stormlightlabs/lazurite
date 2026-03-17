import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _handleController = TextEditingController();
  final _appPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showDebugForm = false;

  @override
  void dispose() {
    _handleController.dispose();
    _appPasswordController.dispose();
    super.dispose();
  }

  void _onOAuthLogin() {
    if (!_isHandleValid()) {
      return;
    }

    context.read<AuthBloc>().add(OAuthLoginRequested(handle: _handleController.text.trim()));
  }

  void _onAppPasswordLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(handle: _handleController.text.trim(), appPassword: _appPasswordController.text.trim()),
    );
  }

  bool _isHandleValid() {
    return _formKey.currentState?.validate() ?? false;
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
                          'Connect with BlueSky',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _handleController,
                          decoration: const InputDecoration(
                            labelText: 'Handle or DID',
                            hintText: 'username.bsky.social or did:plc:...',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
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
                            return FilledButton.icon(
                              onPressed: state.isLoading ? null : _onOAuthLogin,
                              icon: state.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.language),
                              label: Text(state.isLoading ? 'Starting sign in...' : 'Continue with BlueSky OAuth'),
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
                                      Text('App Password Login', style: theme.textTheme.titleMedium),
                                      const Spacer(),
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
                                        return OutlinedButton.icon(
                                          onPressed: state.isLoading ? null : _onAppPasswordLogin,
                                          icon: const Icon(Icons.login),
                                          label: const Text('Sign In'),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Generate app passwords from BlueSky Settings -> App Passwords.',
                                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
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
