import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';

class DevToolsHomePage extends ConsumerWidget {
  const DevToolsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    final String did;
    final String pdsUrl;

    if (authState is AuthStateAuthenticated) {
      did = authState.session.did;
      pdsUrl = authState.session.pdsUrl;
    } else {
      did = 'Not authenticated';
      pdsUrl = 'Unknown';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Tools'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard(
            context,
            title: 'My DID',
            value: did,
            actionIcon: Icons.copy,
            onAction: () {
              Clipboard.setData(ClipboardData(text: did));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('DID copied to clipboard')));
            },
          ),
          const SizedBox(height: 16),
          _buildInfoCard(context, title: 'PDS Host', value: pdsUrl),
          const SizedBox(height: 16),
          Text('Quick Actions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            child: Padding(padding: EdgeInsets.all(16.0), child: Text('Coming soon...')),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (actionIcon != null && onAction != null)
                  IconButton(
                    icon: Icon(actionIcon, size: 20),
                    onPressed: onAction,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
