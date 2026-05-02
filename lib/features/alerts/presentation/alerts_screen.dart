import 'package:flutter/material.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/presentation/widgets/convo_list_pane.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notifications_pane.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';

enum AlertsTab { notifications, messages, requests }

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, this.initialTab = AlertsTab.notifications});

  final AlertsTab initialTab;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    final convoBloc = context.read<ConvoListBloc>();
    if (convoBloc.state.status == ConvoListStatus.initial) {
      convoBloc.add(const ConvosRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = widget.initialTab;
    final notificationsUnread = context.select<UnreadCountCubit, int>((cubit) => cubit.state.count);
    final messagesUnread = context.select<ConvoListBloc, int>((bloc) => _primaryMessagesUnreadCount(bloc.state));

    return AppScreenEntrance(
      child: Scaffold(
        appBar: LazuriteAppBar(
          sectionLabel: 'Alerts',
          actions: currentTab == AlertsTab.notifications
              ? [TextButton(onPressed: () => _markAllRead(context), child: const Text('Mark All Read'))]
              : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: _AlertsTabs(
              currentTab: currentTab,
              notificationsUnreadCount: notificationsUnread,
              messagesUnreadCount: messagesUnread,
            ),
          ),
        ),
        body: KeyedSubtree(key: ValueKey(currentTab), child: _buildTab(currentTab)),
      ),
    );
  }

  int _primaryMessagesUnreadCount(ConvoListState state) {
    var unread = 0;
    for (final convo in state.convos) {
      final status = convo.status;
      final isRequest = status != null && status.isKnownValue && status.knownValue == KnownConvoViewStatus.request;
      if (!isRequest) {
        unread += convo.unreadCount;
      }
    }
    return unread;
  }

  Widget _buildTab(AlertsTab tab) {
    switch (tab) {
      case AlertsTab.notifications:
        return const NotificationsPane();
      case AlertsTab.messages:
        return const ConvoListPane(tab: ConvoTab.primary);
      case AlertsTab.requests:
        return const ConvoListPane(tab: ConvoTab.requests);
    }
  }

  void _markAllRead(BuildContext context) {
    context.read<NotificationBloc>().add(const NotificationsMarkedRead());
    context.read<UnreadCountCubit>().refresh();
  }
}

class _AlertsTabs extends StatelessWidget {
  const _AlertsTabs({
    required this.currentTab,
    required this.notificationsUnreadCount,
    required this.messagesUnreadCount,
  });

  final AlertsTab currentTab;
  final int notificationsUnreadCount;
  final int messagesUnreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          _AlertsTabButton(
            tab: AlertsTab.notifications,
            label: 'Notifications',
            currentTab: currentTab,
            unreadCount: notificationsUnreadCount,
          ),
          _AlertsTabButton(
            tab: AlertsTab.messages,
            label: 'Messages',
            currentTab: currentTab,
            unreadCount: messagesUnreadCount,
          ),
          _AlertsTabButton(tab: AlertsTab.requests, label: 'Requests', currentTab: currentTab),
        ],
      ),
    );
  }
}

class _AlertsTabButton extends StatelessWidget {
  const _AlertsTabButton({required this.tab, required this.label, required this.currentTab, this.unreadCount = 0});

  final AlertsTab tab;
  final String label;
  final AlertsTab currentTab;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTab == tab;
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
    );

    return Expanded(
      child: InkWell(
        onTap: () => _navigateToTab(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, textAlign: TextAlign.center, style: textStyle),
              if (unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  key: ValueKey('alerts-tab-unread-${tab.name}'),
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context) {
    final target = switch (tab) {
      AlertsTab.notifications => '/alerts',
      AlertsTab.messages => '/alerts/messages',
      AlertsTab.requests => '/alerts/requests',
    };

    if (GoRouterState.of(context).uri.path != target) {
      context.go(target);
    }
  }
}
