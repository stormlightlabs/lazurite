import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        height: 50,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        indicatorShape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(10)),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: _destinations,
      ),
    );
  }

  List<Widget> get _destinations => [
    const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(
      icon: BlocBuilder<UnreadCountCubit, UnreadCountState>(
        builder: (context, state) {
          return Badge(
            isLabelVisible: state.hasUnread,
            label: Text(state.count > 99 ? '99+' : state.count.toString(), style: const TextStyle(fontSize: 10)),
            child: const Icon(Icons.notifications_outlined),
          );
        },
      ),
      selectedIcon: BlocBuilder<UnreadCountCubit, UnreadCountState>(
        builder: (context, state) {
          return Badge(
            isLabelVisible: state.hasUnread,
            label: Text(state.count > 99 ? '99+' : state.count.toString(), style: const TextStyle(fontSize: 10)),
            child: const Icon(Icons.notifications),
          );
        },
      ),
      label: 'Notifications',
    ),
    const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];
}
