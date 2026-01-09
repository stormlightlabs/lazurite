import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_state.dart';

/// Tab displaying ATProto session information.
///
/// Shows:
/// - Current DID and handle (when authenticated)
/// - PDS host URL
/// - Session status (authenticated, expired, or none)
///
/// **Security**: Never displays access tokens, refresh tokens, or DPoP keys.
class AtprotoSessionTab extends ConsumerWidget {
  const AtprotoSessionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusBanner(theme, authState),
        const SizedBox(height: 16),
        _buildSessionSection(theme, authState),
      ],
    );
  }

  Widget _buildStatusBanner(ThemeData theme, AuthState authState) {
    final String status;
    final IconData icon;
    final Color backgroundColor;
    final Color foregroundColor;

    switch (authState) {
      case AuthStateAuthenticated():
        status = 'Authenticated';
        icon = Icons.check_circle;
        backgroundColor = theme.colorScheme.primaryContainer;
        foregroundColor = theme.colorScheme.onPrimaryContainer;
      case AuthStateUnauthenticated():
        status = 'Not authenticated';
        icon = Icons.error_outline;
        backgroundColor = theme.colorScheme.errorContainer;
        foregroundColor = theme.colorScheme.onErrorContainer;
      case AuthStateLoading():
      case AuthStateUnknown():
        status = 'Loading...';
        icon = Icons.hourglass_empty;
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        foregroundColor = theme.colorScheme.onSurface;
      case AuthStateError():
        status = 'Error';
        icon = Icons.warning;
        backgroundColor = theme.colorScheme.errorContainer;
        foregroundColor = theme.colorScheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: theme.textTheme.titleSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSection(ThemeData theme, AuthState authState) {
    if (authState is! AuthStateAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Sign in to view session details.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final session = authState.session;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Details',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildInfoRow(theme: theme, label: 'DID', value: session.did, showDivider: true),
              _buildInfoRow(
                theme: theme,
                label: 'Handle',
                value: session.handle,
                showDivider: true,
              ),
              _buildInfoRow(
                theme: theme,
                label: 'PDS Host',
                value: session.pdsUrl,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSecurityNote(theme),
      ],
    );
  }

  Widget _buildInfoRow({
    required ThemeData theme,
    required String label,
    required String value,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 12,
            endIndent: 12,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  Widget _buildSecurityNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tokens and keys are stored securely and never displayed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
