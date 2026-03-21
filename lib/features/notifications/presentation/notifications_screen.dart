import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notifications_pane.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LazuriteAppBar(
        sectionLabel: 'Alerts',
        actions: [TextButton(onPressed: () => _markAllRead(context), child: const Text('Mark All Read'))],
      ),
      body: const NotificationsPane(),
    );
  }

  void _markAllRead(BuildContext context) {
    context.read<NotificationBloc>().add(const NotificationsMarkedRead());
    context.read<UnreadCountCubit>().refresh();
  }
}
