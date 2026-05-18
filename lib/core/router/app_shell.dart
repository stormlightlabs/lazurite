import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_consent_gate.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/account/presentation/account_switcher_sheet.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
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
    return IconButton(tooltip: context.l10n.labelOpenMenu, onPressed: onPressed, icon: const Icon(Icons.menu));
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell, required this.branchNavigatorKeys});

  final StatefulNavigationShell navigationShell;
  final List<GlobalKey<NavigatorState>> branchNavigatorKeys;

  /// Global key for the shell [Scaffold]. Accessible from any screen, even
  /// screens pushed onto the root navigator that are outside [AppShellScope].
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Opens the navigation drawer from any context.
  static void openDrawer() => AppShell.scaffoldKey.currentState?.openDrawer();

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  void _openMenu() => AppShell.openDrawer();

  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;

  NavigatorState? get _activeBranchNavigator {
    final index = widget.navigationShell.currentIndex;
    if (index < 0 || index >= widget.branchNavigatorKeys.length) {
      return null;
    }
    return widget.branchNavigatorKeys[index].currentState;
  }

  bool _activeBranchCanPop() => _activeBranchNavigator?.canPop() ?? false;

  bool _isAndroidHomeRoot() => _isAndroid && widget.navigationShell.currentIndex == 0 && !_activeBranchCanPop();

  Future<void> _handleAndroidBack() async {
    final activeNavigator = _activeBranchNavigator;
    if (activeNavigator != null && activeNavigator.canPop()) {
      await activeNavigator.maybePop();
      return;
    }

    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    CrashReportingService? crashReportingService;
    try {
      crashReportingService = context.read<CrashReportingService>();
    } catch (error, stackTrace) {
      log.d('showing app shell without crash reporting consent gate', error: error, stackTrace: stackTrace);
      crashReportingService = null;
    }
    return AppShellScope(
      openMenu: _openMenu,
      child: PopScope(
        canPop: !_isAndroid || _isAndroidHomeRoot(),
        onPopInvokedWithResult: (didPop, _) {
          if (didPop || !_isAndroid) {
            return;
          }
          unawaited(_handleAndroidBack());
        },
        child: Scaffold(
          key: AppShell.scaffoldKey,
          drawer: _AppMenu(navigationShell: widget.navigationShell, rootContext: context),
          body: crashReportingService == null
              ? widget.navigationShell
              : CrashReportingConsentGate(crashReportingService: crashReportingService, child: widget.navigationShell),
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
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: _destinations(l10n),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _destinations(AppLocalizations l10n) => [
    NavigationDestination(
      icon: const _AnimatedNavIcon(selected: false, outlined: Icons.home_outlined, filled: Icons.home),
      selectedIcon: const _AnimatedNavIcon(selected: true, outlined: Icons.home_outlined, filled: Icons.home),
      label: l10n.labelHome,
    ),
    NavigationDestination(
      icon: const _AnimatedNavIcon(selected: false, outlined: Icons.search_outlined, filled: Icons.search),
      selectedIcon: const _AnimatedNavIcon(selected: true, outlined: Icons.search_outlined, filled: Icons.search),
      label: l10n.labelSearchNav,
    ),
    NavigationDestination(
      icon: const _AnimatedNotificationNavIcon(selected: false),
      selectedIcon: const _AnimatedNotificationNavIcon(selected: true),
      label: l10n.labelAlerts,
    ),
    NavigationDestination(
      icon: const _AnimatedNavIcon(selected: false, outlined: Icons.person_outline, filled: Icons.person),
      selectedIcon: const _AnimatedNavIcon(selected: true, outlined: Icons.person_outline, filled: Icons.person),
      label: l10n.labelProfile,
    ),
  ];
}

class _AnimatedNavIcon extends StatelessWidget {
  const _AnimatedNavIcon({required this.selected, required this.outlined, required this.filled});

  final bool selected;
  final IconData outlined;
  final IconData filled;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(selected ? filled : outlined, key: ValueKey(selected), size: selected ? 26 : 24);
    final transitioned = AnimatedSwitcher(
      duration: Anim.fast,
      switchInCurve: Anim.enter,
      switchOutCurve: Anim.exit,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: icon,
    );

    return transitioned.animateIfAllowed(
      context,
      effects: selected
          ? const [ScaleEffect(begin: Offset(1, 1), end: Offset(1.15, 1.15), duration: Anim.fast, curve: Anim.enter)]
          : const [],
    );
  }
}

class _AnimatedNotificationNavIcon extends StatelessWidget {
  const _AnimatedNotificationNavIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = _NotificationDestinationIcon(selected: selected, key: ValueKey(selected));
    return AnimatedSwitcher(
      duration: Anim.fast,
      switchInCurve: Anim.enter,
      switchOutCurve: Anim.exit,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: icon,
    ).animateIfAllowed(
      context,
      effects: selected
          ? const [ScaleEffect(begin: Offset(1, 1), end: Offset(1.15, 1.15), duration: Anim.fast, curve: Anim.enter)]
          : const [],
    );
  }
}

class _NotificationDestinationIcon extends StatelessWidget {
  const _NotificationDestinationIcon({super.key, required this.selected});

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
    final isComposeRoute = currentPath == '/compose';
    final isHomeRoute = currentPath == '/';
    final isSearchRoute = currentPath == '/search';
    final isFeedsRoute = currentPath == '/feeds';
    final isProfileRoute = currentPath.startsWith('/profile/');
    final isSettingsRoute = currentPath == '/settings' || currentPath.startsWith('/settings/');
    final isDevToolsRoute = currentPath == '/settings/devtools';
    final isCleanFollowsRoute = currentPath == '/settings/clean-follows';
    final isMessagesRoute = currentPath.startsWith('/alerts/messages') || currentPath.startsWith('/alerts/requests');
    final isNotificationsRoute = currentPath.startsWith('/alerts') && !isMessagesRoute;
    final isOffline = rootContext.read<ConnectivityCubit>().state.isOffline;
    final l10n = context.l10n;
    final tokens = rootContext.watch<AuthBloc>().state.tokens;
    final displayName = tokens?.displayName ?? tokens?.handle ?? l10n.labelGuest;
    final handle = tokens?.handle ?? l10n.labelSignInRequired;
    final did = tokens?.did;
    final initials = _initialsFor(tokens?.displayName ?? tokens?.handle ?? 'L');
    final drawerWidth = (MediaQuery.sizeOf(context).width * 0.82).clamp(280.0, 320.0).toDouble();

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    child: Row(
                      children: [
                        Text(l10n.appTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.buttonCancel,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  _buildProfileTag(context, displayName, handle, initials, did),
                ],
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: ClipRect(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _MenuTile(
                        icon: Icons.add_circle_outline,
                        selectedIcon: Icons.add_circle,
                        label: l10n.labelNewPost,
                        isSelected: isComposeRoute,
                        tooltip: isOffline ? offlineActionMessage('compose a post') : null,
                        onTap: isOffline ? null : () => _pushRoute(context, '/compose'),
                      ),
                      const Divider(height: 24),
                      _MenuSectionLabel(label: l10n.labelNavigation),
                      _MenuTile(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                        label: l10n.labelHome,
                        isSelected: isHomeRoute,
                        onTap: () => _selectBranch(context, 0),
                      ),
                      _MenuTile(
                        icon: Icons.search_outlined,
                        selectedIcon: Icons.search,
                        label: l10n.labelSearch,
                        isSelected: isSearchRoute,
                        onTap: () => _selectBranch(context, 1),
                      ),
                      _MenuTile(
                        icon: Icons.rss_feed_outlined,
                        selectedIcon: Icons.rss_feed,
                        label: l10n.labelFeeds,
                        isSelected: isFeedsRoute,
                        onTap: () => _pushRoute(context, '/feeds'),
                      ),
                      _MenuTile(
                        icon: Icons.notifications_outlined,
                        selectedIcon: Icons.notifications,
                        label: l10n.labelNotifications,
                        isSelected: isNotificationsRoute,
                        trailing: _notificationsBadge(),
                        onTap: () => _goRoute(context, '/alerts'),
                      ),
                      _MenuTile(
                        icon: Icons.chat_bubble_outline,
                        selectedIcon: Icons.chat_bubble,
                        label: l10n.labelMessages,
                        isSelected: isMessagesRoute,
                        onTap: () => _goRoute(context, '/alerts/messages'),
                      ),
                      _MenuTile(
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                        label: l10n.labelProfile,
                        isSelected: isProfileRoute,
                        onTap: () => _selectBranch(context, 3),
                      ),
                      const Divider(height: 24),
                      _MenuSectionLabel(label: l10n.labelAdvanced),
                      _MenuTile(
                        icon: Icons.explore_outlined,
                        selectedIcon: Icons.explore,
                        label: l10n.labelAtExplorer,
                        isSelected: isDevToolsRoute,
                        onTap: () => _pushRoute(context, '/settings/devtools'),
                      ),
                      _MenuTile(
                        icon: Icons.cleaning_services_outlined,
                        selectedIcon: Icons.cleaning_services,
                        label: l10n.labelAuditFollows,
                        isSelected: isCleanFollowsRoute,
                        onTap: () => _pushRoute(context, '/settings/clean-follows'),
                      ),
                      const Divider(height: 24),
                      _MenuTile(
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings,
                        label: l10n.labelSettings,
                        isSelected: isSettingsRoute,
                        onTap: () => _pushRoute(context, '/settings'),
                      ),
                      _MenuTile(
                        icon: Icons.logout,
                        selectedIcon: Icons.logout,
                        label: l10n.labelLogOut,
                        isDestructive: true,
                        onTap: () =>
                            _runAfterClose(context, () => rootContext.read<AuthBloc>().add(const LogoutRequested())),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTag(ThemeData theme, String content, bool isLabel) {
    final style = isLabel
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Text(content, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
  }

  Widget _buildProfileTag(BuildContext context, String displayName, String handle, String initials, String? did) {
    final theme = Theme.of(context);
    final deco = BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(20));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _runAfterClose(context, () => showAccountSwitcherSheet(rootContext)),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: deco,
          child: Row(
            children: [
              _MenuProfileAvatar(did: did, initials: initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileTag(theme, displayName, true),
                    const SizedBox(height: 2),
                    _profileTag(theme, '@$handle', false),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
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

class _MenuSectionLabel extends StatelessWidget {
  const _MenuSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );
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
          backgroundColor: context.colorScheme.surfaceContainerHighest,
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
    this.tooltip,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDestructive;
  final Widget? trailing;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    Widget tile = ListTile(
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

    if (tooltip != null) {
      tile = Tooltip(message: tooltip!, child: tile);
    }

    return tile;
  }
}
