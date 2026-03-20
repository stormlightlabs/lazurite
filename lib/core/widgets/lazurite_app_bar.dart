import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';

/// Custom top app bar for the Lazurite shell screens.
///
/// Shows a hamburger button on the left, a section label (uppercase,
/// letterSpacing 3, labelSmall, onSurfaceVariant), and a square user
/// avatar thumbnail on the right.
///
/// Pass [bottom] to add an additional row below the toolbar (e.g., for the
/// home-screen feed-switcher tabs).
class LazuriteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LazuriteAppBar({super.key, required this.sectionLabel, this.bottom, this.actions});

  final String sectionLabel;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  static const double _toolbarHeight = 64;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      toolbarHeight: _toolbarHeight,
      backgroundColor: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const AppShellMenuButton(),
      title: Text(
        sectionLabel.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 3, color: theme.colorScheme.onSurfaceVariant),
      ),
      centerTitle: false,
      titleSpacing: 0,
      actions: [...?actions, const _AppBarAvatar(), const SizedBox(width: 8)],
      bottom: bottom,
      shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
    );
  }
}

class _AppBarAvatar extends StatelessWidget {
  const _AppBarAvatar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AuthState? authState;
    try {
      authState = context.watch<AuthBloc>().state;
    } catch (_) {
      // AuthBloc not provided — show default avatar
    }
    final tokens = authState?.tokens;
    final initials = _initialsFor(tokens?.displayName ?? tokens?.handle ?? 'L');

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(initials, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _initialsFor(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2).toList();
    if (parts.isEmpty) return 'L';
    return parts.map((p) => p[0].toUpperCase()).join();
  }
}
