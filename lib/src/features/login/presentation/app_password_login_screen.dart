import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/app_app_bar.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/login/presentation/auth_button.dart';
import 'package:lazurite/src/features/login/presentation/auth_progress_view.dart';
import 'package:lazurite/src/infrastructure/auth/handle_storage.dart';

class AppPasswordLoginScreen extends ConsumerStatefulWidget {
  const AppPasswordLoginScreen({super.key});

  @override
  ConsumerState<AppPasswordLoginScreen> createState() => _AppPasswordLoginScreenState();
}

class _AppPasswordLoginScreenState extends ConsumerState<AppPasswordLoginScreen> {
  final _handleController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadLastHandle();
  }

  Future<void> _loadLastHandle() async {
    final handleStorage = await ref.read(handleStorageProvider.future);
    final lastHandle = handleStorage.getLastHandle();
    if (lastHandle != null && mounted) {
      _handleController.text = lastHandle;
    }
  }

  @override
  void dispose() {
    _handleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final handle = _handleController.text.trim();
    final password = _passwordController.text.trim();

    if (handle.isEmpty || password.isEmpty) return;

    final handleStorage = await ref.read(handleStorageProvider.future);
    await handleStorage.saveHandle(handle);
    await ref.read(authProvider.notifier).loginWithAppPassword(handle, password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      switch (next) {
        case AuthStateError(error: final err):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $err'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        case _:
          break;
      }
    });

    return Scaffold(
      appBar: const AppAppBar(title: 'App Password'),
      body: SafeArea(
        child: switch (authState) {
          AuthStateLoading() => const Center(
            child: AuthProgressView(message: 'Logging in with App Password...'),
          ),
          _ => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your handle and app password used for third-party clients.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _handleController,
                  decoration: const InputDecoration(
                    labelText: 'Handle',
                    hintText: 'yourname.bsky.social',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'App Password',
                    hintText: 'xxxx-xxxx-xxxx-xxxx',
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 32),
                AuthButton(text: 'Sign In', onPressed: _handleLogin),
                const SizedBox(height: 16),
                Text(
                  'Note: This does not use standard OAuth and bypasses 2FA checks if not strictly enforced. Use only for testing.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error.withAlpha(204),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
