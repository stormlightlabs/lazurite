import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
import 'package:lazurite/core/logging/app_logger.dart';

class UnreadCountCubit extends Cubit<UnreadCountState> {
  UnreadCountCubit({
    NotificationDomainService? notificationDomainService,
    NotificationRepository? notificationRepository,
  }) : _notificationDomainService =
           notificationDomainService ??
           NotificationDomainService(
             notificationRepository: notificationRepository ??
                 (throw ArgumentError('Either notificationDomainService or notificationRepository is required')),
           ),
      super(const UnreadCountState(0)) {
    _startPolling();
  }

  final NotificationDomainService _notificationDomainService;
  Timer? _pollingTimer;

  static const _pollingInterval = Duration(seconds: 30);

  void _startPolling() {
    _pollUnreadCount();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _pollUnreadCount());
  }

  Future<void> _pollUnreadCount() async {
    try {
      final count = await _notificationDomainService.getUnreadCount();
      emit(UnreadCountState(count));
    } catch (_) {
      log.w('Failed to poll unread count');
    }
  }

  Future<void> refresh() async {
    await _pollUnreadCount();
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}

class UnreadCountState extends Equatable {
  const UnreadCountState(this.count);

  final int count;

  bool get hasUnread => count > 0;

  @override
  List<Object?> get props => [count];
}
