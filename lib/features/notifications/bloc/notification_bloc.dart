import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    NotificationDomainService? notificationDomainService,
    NotificationRepository? notificationRepository,
  }) : _notificationDomainService =
           notificationDomainService ??
           NotificationDomainService(
             notificationRepository:
                 notificationRepository ??
                 (throw ArgumentError('Either notificationDomainService or notificationRepository is required')),
           ),
       super(const NotificationState.initial()) {
    on<NotificationsRequested>(_onNotificationsRequested);
    on<NotificationsRefreshed>(_onNotificationsRefreshed);
    on<NotificationsPageLoaded>(_onNotificationsPageLoaded);
    on<NotificationsMarkedRead>(_onNotificationsMarkedRead);
  }

  final NotificationDomainService _notificationDomainService;

  Future<void> _onNotificationsRequested(NotificationsRequested event, Emitter<NotificationState> emit) async {
    emit(const NotificationState.loading());

    try {
      final result = await _notificationDomainService.listNotifications(limit: event.limit);

      emit(
        NotificationState.loaded(
          notifications: result.notifications,
          cursor: result.cursor,
          hasMore: result.cursor != null,
        ),
      );
    } catch (error) {
      emit(NotificationState.error('Failed to load notifications: $error'));
    }
  }

  Future<void> _onNotificationsRefreshed(NotificationsRefreshed event, Emitter<NotificationState> emit) async {
    if (state.status != NotificationStatus.loaded) {
      return;
    }

    emit(state.copyWith(isRefreshing: true));

    try {
      final result = await _notificationDomainService.listNotifications(limit: 50);

      emit(
        state.copyWith(
          notifications: result.notifications,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isRefreshing: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> _onNotificationsPageLoaded(NotificationsPageLoaded event, Emitter<NotificationState> emit) async {
    if (state.status != NotificationStatus.loaded || state.cursor == null || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _notificationDomainService.listNotifications(cursor: state.cursor, limit: event.limit);

      emit(
        state.copyWith(
          notifications: [...state.notifications, ...result.notifications],
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  Future<void> _onNotificationsMarkedRead(NotificationsMarkedRead event, Emitter<NotificationState> emit) async {
    try {
      await _notificationDomainService.markSeen();
      if (state.status == NotificationStatus.loaded && state.notifications.isNotEmpty) {
        emit(
          state.copyWith(
            notifications: state.notifications.map((notification) => notification.copyWith(isRead: true)).toList(),
          ),
        );
      }
    } catch (error, stackTrace) {
      log.w('Failed to mark notifications as read/seen', error: error, stackTrace: stackTrace);
    }
  }
}
