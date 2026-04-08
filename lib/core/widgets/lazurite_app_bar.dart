import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';

/// Custom top app bar for the Lazurite shell screens.
///
/// Shows a hamburger button on the left and a section label (uppercase,
/// letterSpacing 3, labelSmall, onSurfaceVariant)
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
      actions: [...?actions, const _AppBarOfflineIndicator()],
      bottom: bottom,
      shape: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
    );
  }
}

class _AppBarOfflineIndicator extends StatelessWidget {
  const _AppBarOfflineIndicator();

  @override
  Widget build(BuildContext context) {
    ConnectivityCubit? connectivityCubit;
    try {
      connectivityCubit = context.read<ConnectivityCubit>();
    } catch (_) {
      log.d('showing app bar without connectivity indicator');
    }
    if (connectivityCubit == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      bloc: connectivityCubit,
      builder: (context, state) {
        if (!state.isOffline) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        SettingsCubit? settingsCubit;
        try {
          settingsCubit = context.read<SettingsCubit>();
        } catch (_) {}
        final canDisableSimulatedOffline = state.isSimulatedOffline && settingsCubit != null;
        final tooltip = canDisableSimulatedOffline ? 'Disable simulated offline mode' : 'You\'re offline';

        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Tooltip(
            message: tooltip,
            child: IconButton(
              tooltip: tooltip,
              onPressed: canDisableSimulatedOffline ? () => settingsCubit?.setSimulateOffline(false) : null,
              icon: Icon(Icons.cloud_off_outlined, color: theme.colorScheme.error),
            ),
          ),
        );
      },
    );
  }
}
