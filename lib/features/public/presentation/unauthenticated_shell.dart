import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/bottom_navigation_labels.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';

class UnauthenticatedShell extends StatelessWidget {
  const UnauthenticatedShell({
    super.key,
    required this.location,
    required this.navigationShell,
    this.publicProviderKey,
    this.publicHomeLocation,
  });

  final String location;
  final StatefulNavigationShell navigationShell;
  final String? publicProviderKey;
  final String? publicHomeLocation;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withValues(alpha: 0.94),
        border: Border(top: BorderSide(color: context.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          key: const ValueKey<String>('unauthenticated-navigation-bar'),
          height: 72,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: context.colorScheme.secondaryContainer,
          selectedIndex: navigationShell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) => _goDestination(context, index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.l10n.bottomNavHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore),
              label: context.l10n.bottomNavAtExplorer,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.l10n.bottomNavSettings,
            ),
            NavigationDestination(
              key: const ValueKey<String>('unauthenticated-login-button'),
              icon: const Icon(Icons.login_outlined),
              selectedIcon: const Icon(Icons.login),
              label: context.l10n.bottomNavSignIn,
            ),
          ],
        ),
      ),
    ),
  );

  String get _homeLocation =>
      publicHomeLocation ??
      const PublicRouteState(providerKey: AppViewProviders.blueskyKey, contentTab: PublicContentTab.discover).location;

  void _goDestination(BuildContext context, int index) => switch (index) {
    0 => context.go(_homeLocation),
    1 => context.go(_routeWithPublicHome('/settings/devtools')),
    2 => context.go(_routeWithPublicHome('/settings')),
    3 => context.go(_routeWithPublicHome('/login', provider: _loginProvider(context))),
    _ => null,
  };

  String _routeWithPublicHome(String path, {String? provider}) {
    final queryParameters = {'publicHome': _homeLocation};
    if (provider != null) {
      queryParameters['provider'] = provider;
    }
    return Uri(path: path, queryParameters: queryParameters).toString();
  }

  String _loginProvider(BuildContext context) => (publicProviderKey != null)
      ? PublicRouteState.normalizeProvider(publicProviderKey)
      : PublicRouteState.normalizeProvider(context.read<SettingsCubit>().state.appViewProvider);
}
