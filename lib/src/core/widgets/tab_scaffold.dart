import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/global_compose_fab.dart';
import 'package:lazurite/src/features/notifications/application/unread_count_notifier.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/unread_badge.dart';

/// Bottom navigation scaffold that wraps the tab content.
///
/// Uses [StatefulNavigationShell] to preserve state across tab switches.
/// Shows different tabs based on authentication state:
/// - Unauthenticated: Home, Login
/// - Authenticated: Home, Search, Notifications, Messages, Profile
class TabScaffold extends ConsumerStatefulWidget {
  const TabScaffold({required this.navigationShell, super.key});

  /// The navigation shell from [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends ConsumerState<TabScaffold> {
  bool _resetScheduled = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthStateAuthenticated;
    final unreadCountAsync = ref.watch(unreadCountProvider);

    _ensureHomeBranchWhenUnauthenticated(isAuthenticated);

    final unreadCount = unreadCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, _) => 0,
    );

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: isAuthenticated ? widget.navigationShell.currentIndex : 0,
        onDestinationSelected: (index) {
          if (isAuthenticated) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          } else if (index == 1) {
            context.go(AppRoutes.login);
          } else {
            widget.navigationShell.goBranch(0, initialLocation: true);
          }
        },
        destinations: isAuthenticated
            ? _buildAuthenticatedDestinations(context, unreadCount)
            : _unauthenticatedDestinations,
      ),
      floatingActionButton: _shouldShowFab(context, isAuthenticated)
          ? const GlobalComposeFab()
          : null,
    );
  }

  /// Determines whether the compose FAB should be shown.
  ///
  /// The FAB is visible on main tab screens (Home, Search, Notifications, Profile)
  /// but hidden on other screens like Composer, Login, Drafts, and Settings.
  bool _shouldShowFab(BuildContext context, bool isAuthenticated) {
    if (!isAuthenticated) return false;

    final location = GoRouterState.of(context).matchedLocation;

    final showOnRoutes = [
      AppRoutes.home,
      AppRoutes.search,
      AppRoutes.notifications,
      AppRoutes.profile,
    ];

    return showOnRoutes.any((route) => location.startsWith(route));
  }

  void _ensureHomeBranchWhenUnauthenticated(bool isAuthenticated) {
    if (isAuthenticated) {
      _resetScheduled = false;
      return;
    }

    if (_resetScheduled || widget.navigationShell.currentIndex == 0) {
      return;
    }

    _resetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.navigationShell.goBranch(0, initialLocation: true);
      _resetScheduled = false;
    });
  }
}

/// Builds authenticated navigation destinations with unread count badge.
List<NavigationDestination> _buildAuthenticatedDestinations(
  BuildContext context,
  int unreadCount,
) {
  return [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: UnreadBadge(count: unreadCount, child: const Icon(Icons.notifications_outlined)),
      selectedIcon: UnreadBadge(count: unreadCount, child: const Icon(Icons.notifications)),
      label: 'Notifications',
    ),
    const NavigationDestination(
      icon: Icon(Icons.mail_outlined),
      selectedIcon: Icon(Icons.mail),
      label: 'Messages',
    ),
    NavigationDestination(
      icon: GestureDetector(
        onLongPress: () => _showProfileMenu(context),
        child: const Icon(Icons.person_outlined),
      ),
      selectedIcon: GestureDetector(
        onLongPress: () => _showProfileMenu(context),
        child: const Icon(Icons.person),
      ),
      label: 'Profile',
    ),
  ];
}

void _showProfileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.drafts_outlined),
            title: const Text('Drafts'),
            onTap: () {
              Navigator.pop(context);
              context.push('/drafts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text('Bookmarks'),
            onTap: () {
              Navigator.pop(context);
              context.push('/bookmarks');
            },
          ),
        ],
      ),
    ),
  );
}

const _unauthenticatedDestinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.login_outlined),
    selectedIcon: Icon(Icons.login),
    label: 'Login',
  ),
];
