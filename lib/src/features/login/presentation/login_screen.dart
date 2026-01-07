import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/app_app_bar.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/login/presentation/account_switcher_sheet.dart';
import 'package:lazurite/src/features/login/presentation/auth_button.dart';
import 'package:lazurite/src/features/login/presentation/auth_progress_view.dart';
import 'package:lazurite/src/infrastructure/auth/handle_storage.dart';

/// Login screen for user authentication.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a login screen.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _handleController = TextEditingController();

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
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final handle = _handleController.text.trim();
    if (handle.isEmpty) return;

    final handleStorage = await ref.read(handleStorageProvider.future);
    await handleStorage.saveHandle(handle);
    await ref.read(authProvider.notifier).login(handle);
  }

  void _showAccountSwitcher() {
    showModalBottomSheet(context: context, builder: (context) => const AccountSwitcherSheet());
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
      appBar: AppAppBar(
        title: 'Login',
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: switch (authState) {
          AuthStateLoading() => const Center(child: AuthProgressView()),
          _ => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.cloud_outlined, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Sign in to Bluesky',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
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
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 24),
                AuthButton(text: 'Continue with Bluesky', onPressed: _handleLogin),
                const SizedBox(height: 16),
                TextButton(onPressed: _showAccountSwitcher, child: const Text('Switch account')),
                const Spacer(),
                TextButton(
                  onPressed: () => context.pushNamed('login_app_password'),
                  child: Text(
                    'Use App Password (Dev)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(102),
                    ),
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
