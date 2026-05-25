import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
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
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: _toolbarHeight,
    backgroundColor: context.colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: const AppShellMenuButton(),
    title: Text(
      sectionLabel.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(letterSpacing: 3, color: context.colorScheme.onSurfaceVariant),
    ),
    centerTitle: false,
    titleSpacing: 0,
    actions: [...?actions, const _AppBarOfflineIndicator()],
    bottom: bottom,
    shape: Border(bottom: BorderSide(color: context.colorScheme.outlineVariant)),
  );
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

        final canDisableSimulatedOffline = state.isSimulatedOffline && _hasSettingsCubit(context);
        final tooltip = canDisableSimulatedOffline ? 'Disable simulated offline mode' : 'You\'re offline';

        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Tooltip(
            message: tooltip,
            child: IconButton(
              tooltip: tooltip,
              onPressed: canDisableSimulatedOffline
                  ? () => context.read<SettingsCubit>().setSimulateOffline(false)
                  : null,
              icon: Icon(Icons.cloud_off_outlined, color: context.theme.colorScheme.error),
            ),
          ),
        );
      },
    );
  }

  bool _hasSettingsCubit(BuildContext context) {
    try {
      context.read<SettingsCubit>();
      return true;
    } catch (error, stackTrace) {
      log.d('showing offline indicator without simulated-offline controls', error: error, stackTrace: stackTrace);
      return false;
    }
  }
}
