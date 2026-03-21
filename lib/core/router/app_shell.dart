import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:provider/provider.dart';

class AppShellScope extends InheritedWidget {
  const AppShellScope({super.key, required super.child, required this.openMenu});

  final VoidCallback openMenu;

  static AppShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>();
  }

  @override
  bool updateShouldNotify(covariant AppShellScope oldWidget) => openMenu != oldWidget.openMenu;
}

class AppShellMenuButton extends StatelessWidget {
  const AppShellMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final shellScope = AppShellScope.maybeOf(context);
    final onPressed = shellScope?.openMenu ?? AppShell.openDrawer;
    return IconButton(tooltip: 'Open menu', onPressed: onPressed, icon: const Icon(Icons.menu));
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Global key for the shell [Scaffold]. Accessible from anywhere — even
  /// screens pushed onto the root navigator that are outside [AppShellScope].
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Opens the navigation drawer from any context.
  static void openDrawer() => AppShell.scaffoldKey.currentState?.openDrawer();

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  void _openMenu() => AppShell.openDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppShellScope(
      openMenu: _openMenu,
      child: Scaffold(
        key: AppShell.scaffoldKey,
        drawer: _AppMenu(navigationShell: widget.navigationShell, rootContext: context),
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.92),
            border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
          child: NavigationBar(
            height: 80,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) {
              widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex);
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: _destinations,
          ),
        ),
      ),
    );
  }

  List<Widget> get _destinations => [
    NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: Transform.scale(scale: 1.15, child: const Icon(Icons.home)),
      label: 'HOME',
    ),
    NavigationDestination(
      icon: const Icon(Icons.search_outlined),
      selectedIcon: Transform.scale(scale: 1.15, child: const Icon(Icons.search)),
      label: 'SEARCH',
    ),
    NavigationDestination(
      icon: const _NotificationDestinationIcon(selected: false),
      selectedIcon: Transform.scale(scale: 1.15, child: const _NotificationDestinationIcon(selected: true)),
      label: 'ALERTS',
    ),
    NavigationDestination(
      icon: const Icon(Icons.person_outline),
      selectedIcon: Transform.scale(scale: 1.15, child: const Icon(Icons.person)),
      label: 'PROFILE',
    ),
  ];
}

class _NotificationDestinationIcon extends StatelessWidget {
  const _NotificationDestinationIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final unreadCountCubit = Provider.of<UnreadCountCubit?>(context, listen: false);
    if (unreadCountCubit == null) {
      return Icon(selected ? Icons.notifications : Icons.notifications_outlined);
    }

    return BlocBuilder<UnreadCountCubit, UnreadCountState>(
      bloc: unreadCountCubit,
      builder: (context, state) {
        return Badge(
          isLabelVisible: state.hasUnread,
          label: Text(state.count > 99 ? '99+' : state.count.toString(), style: const TextStyle(fontSize: 10)),
          child: Icon(selected ? Icons.notifications : Icons.notifications_outlined),
        );
      },
    );
  }
}

class _AppMenu extends StatelessWidget {
  const _AppMenu({required this.navigationShell, required this.rootContext});

  final StatefulNavigationShell navigationShell;
  final BuildContext rootContext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPath = GoRouterState.of(rootContext).uri.path;
    final isMessagesRoute = currentPath.startsWith('/alerts/messages') || currentPath.startsWith('/alerts/requests');
    final isNotificationsRoute = currentPath.startsWith('/alerts') && !isMessagesRoute;
    final tokens = rootContext.watch<AuthBloc>().state.tokens;
    final displayName = tokens?.displayName ?? tokens?.handle ?? 'Guest';
    final handle = tokens?.handle ?? 'Sign in required';
    final did = tokens?.did;
    final initials = _initialsFor(tokens?.displayName ?? tokens?.handle ?? 'L');
    final drawerWidth = (MediaQuery.sizeOf(context).width * 0.82).clamp(280.0, 320.0).toDouble();

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    Text('Lazurite', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close menu',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _runAfterClose(context, () => navigationShell.goBranch(3, initialLocation: false)),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _MenuProfileAvatar(did: did, initials: initials),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@$handle',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _MenuTile(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home,
                      label: 'Home',
                      isSelected: navigationShell.currentIndex == 0,
                      onTap: () => _selectBranch(context, 0),
                    ),
                    _MenuTile(
                      icon: Icons.search_outlined,
                      selectedIcon: Icons.search,
                      label: 'Search',
                      isSelected: navigationShell.currentIndex == 1,
                      onTap: () => _selectBranch(context, 1),
                    ),
                    _MenuTile(
                      icon: Icons.rss_feed_outlined,
                      selectedIcon: Icons.rss_feed,
                      label: 'Feeds',
                      onTap: () => _pushRoute(context, '/feeds'),
                    ),
                    _MenuTile(
                      icon: Icons.notifications_outlined,
                      selectedIcon: Icons.notifications,
                      label: 'Notifications',
                      isSelected: isNotificationsRoute,
                      trailing: _notificationsBadge(),
                      onTap: () => _goRoute(context, '/alerts'),
                    ),
                    _MenuTile(
                      icon: Icons.chat_bubble_outline,
                      selectedIcon: Icons.chat_bubble,
                      label: 'Messages',
                      isSelected: isMessagesRoute,
                      onTap: () => _goRoute(context, '/alerts/messages'),
                    ),
                    _MenuTile(
                      icon: Icons.person_outline,
                      selectedIcon: Icons.person,
                      label: 'Profile',
                      isSelected: navigationShell.currentIndex == 3,
                      onTap: () => _selectBranch(context, 3),
                    ),
                    const Divider(height: 24),
                    _MenuTile(
                      icon: Icons.add_circle_outline,
                      selectedIcon: Icons.add_circle,
                      label: 'New Post',
                      onTap: () => _pushRoute(context, '/compose'),
                    ),
                    _MenuTile(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      label: 'Settings',
                      onTap: () => _pushRoute(context, '/settings'),
                    ),
                    const Divider(height: 24),
                    _MenuTile(
                      icon: Icons.logout,
                      selectedIcon: Icons.logout,
                      label: 'Log Out',
                      isDestructive: true,
                      onTap: () =>
                          _runAfterClose(context, () => rootContext.read<AuthBloc>().add(const LogoutRequested())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationsBadge() {
    try {
      rootContext.read<UnreadCountCubit>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<UnreadCountCubit, UnreadCountState>(
      builder: (context, state) {
        if (!state.hasUnread) {
          return const SizedBox.shrink();
        }

        return Badge(
          label: Text(state.count > 99 ? '99+' : state.count.toString(), style: const TextStyle(fontSize: 10)),
        );
      },
    );
  }

  void _selectBranch(BuildContext context, int index) {
    _runAfterClose(
      context,
      () => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
    );
  }

  void _pushRoute(BuildContext context, String location) {
    _runAfterClose(context, () => GoRouter.of(rootContext).push(location));
  }

  void _goRoute(BuildContext context, String location) {
    _runAfterClose(context, () => GoRouter.of(rootContext).go(location));
  }

  void _runAfterClose(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootContext.mounted) {
        action();
      }
    });
  }

  String _initialsFor(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2).toList();
    if (parts.isEmpty) {
      return 'L';
    }

    return parts.map((part) => part.characters.first.toUpperCase()).join();
  }
}

class _MenuProfileAvatar extends StatefulWidget {
  const _MenuProfileAvatar({required this.did, required this.initials});

  final String? did;
  final String initials;

  @override
  State<_MenuProfileAvatar> createState() => _MenuProfileAvatarState();
}

class _MenuProfileAvatarState extends State<_MenuProfileAvatar> {
  Future<String?>? _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant _MenuProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.did != widget.did) {
      _avatarFuture = _loadAvatar();
    }
  }

  Future<String?> _loadAvatar() async {
    final did = widget.did;
    if (did == null || did.isEmpty) {
      return null;
    }

    try {
      final profile = await context.read<ProfileRepository>().getProfile(did);
      return profile.avatar;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _avatarFuture,
      builder: (context, snapshot) {
        final avatarUrl = snapshot.data;
        return CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? Text(widget.initials) : null,
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isDestructive = false,
    this.trailing,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDestructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(isSelected ? selectedIcon : icon, color: color),
      title: Text(
        label.toUpperCase(),
        style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
      trailing: trailing,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
      onTap: onTap,
    );
  }
}
