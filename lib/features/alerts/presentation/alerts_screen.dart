import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/presentation/widgets/convo_list_pane.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notifications_pane.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';

enum AlertsTab {
  notifications,
  messages,
  requests;

  String get target => switch (this) {
    AlertsTab.notifications => '/alerts',
    AlertsTab.messages => '/alerts/messages',
    AlertsTab.requests => '/alerts/requests',
  };
}

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
          sectionLabel: context.l10n.labelAlertsTitle,
          actions: currentTab == AlertsTab.notifications
              ? [TextButton(onPressed: () => _markAllRead(context), child: Text(context.l10n.buttonMarkAllRead))]
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
      final isRequest = status != null && status.isKnownValue && status.knownValue == KnownConvoStatus.request;
      if (!isRequest) {
        unread += convo.unreadCount;
      }
    }
    return unread;
  }

  Widget _buildTab(AlertsTab tab) => switch (tab) {
    AlertsTab.notifications => const NotificationsPane(),
    AlertsTab.messages => const ConvoListPane(tab: ConvoTab.primary),
    AlertsTab.requests => const ConvoListPane(tab: ConvoTab.requests),
  };

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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        _AlertsTabButton(
          tab: AlertsTab.notifications,
          label: context.l10n.labelNotifications,
          currentTab: currentTab,
          unreadCount: notificationsUnreadCount,
        ),
        _AlertsTabButton(
          tab: AlertsTab.messages,
          label: context.l10n.labelMessages,
          currentTab: currentTab,
          unreadCount: messagesUnreadCount,
        ),
        _AlertsTabButton(tab: AlertsTab.requests, label: context.l10n.labelMessageRequests, currentTab: currentTab),
      ],
    ),
  );
}

class _AlertsTabButton extends StatelessWidget {
  const _AlertsTabButton({required this.tab, required this.label, required this.currentTab, this.unreadCount = 0});

  final AlertsTab tab;
  final AlertsTab currentTab;
  final String label;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTab == tab;
    final textStyle = context.textTheme.bodyLarge?.copyWith(
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      color: isSelected ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant,
    );

    return Expanded(
      child: InkWell(
        onTap: () => _navigateToTab(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: isSelected ? context.colorScheme.primary : Colors.transparent, width: 2),
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
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onPrimary,
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
    if (GoRouterState.of(context).uri.path != tab.target) {
      context.go(tab.target);
    }
  }
}
