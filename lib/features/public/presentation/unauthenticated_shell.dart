import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';

class UnauthenticatedShell extends StatelessWidget {
  const UnauthenticatedShell({
    super.key,
    required this.child,
    required this.location,
    this.publicProviderKey,
    this.publicHomeLocation,
  });

  final Widget child;
  final String location;
  final String? publicProviderKey;
  final String? publicHomeLocation;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withValues(alpha: 0.94),
        border: Border(top: BorderSide(color: context.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: NavigationBar(
                key: const ValueKey<String>('unauthenticated-navigation-bar'),
                height: 72,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: context.colorScheme.secondaryContainer,
                selectedIndex: _selectedIndex,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (index) => _goDestination(context, index),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                    label: context.l10n.labelHome,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.explore_outlined),
                    selectedIcon: const Icon(Icons.explore),
                    label: context.l10n.labelAtExplorer,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: context.l10n.labelSettings,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                key: const ValueKey<String>('unauthenticated-login-button'),
                onPressed: () => context.go('/login?provider=${_loginProvider(context)}'),
                icon: const Icon(Icons.login),
                label: Text(context.l10n.buttonSignIn),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  int get _selectedIndex {
    if (location == '/settings/devtools') {
      return 1;
    } else if (location == '/settings') {
      return 2;
    }
    return 0;
  }

  void _goDestination(BuildContext context, int index) => switch (index) {
    0 => context.go(
      publicHomeLocation ??
          const PublicRouteState(
            providerKey: AppViewProviders.blueskyKey,
            contentTab: PublicContentTab.discover,
          ).location,
    ),
    1 => context.go('/settings/devtools'),
    2 => context.go('/settings'),
    _ => null,
  };

  String _loginProvider(BuildContext context) => (publicProviderKey != null)
      ? PublicRouteState.normalizeProvider(publicProviderKey)
      : PublicRouteState.normalizeProvider(context.read<SettingsCubit>().state.appViewProvider);
}
