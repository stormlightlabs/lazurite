part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  const NotificationState._({
    required this.status,
    this.notifications = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  const NotificationState.initial() : this._(status: NotificationStatus.initial);

  const NotificationState.loading() : this._(status: NotificationStatus.loading);

  const NotificationState.loaded({required List<Notification> notifications, String? cursor, bool hasMore = false})
    : this._(status: NotificationStatus.loaded, notifications: notifications, cursor: cursor, hasMore: hasMore);

  const NotificationState.error(String message) : this._(status: NotificationStatus.error, errorMessage: message);

  final NotificationStatus status;
  final List<Notification> notifications;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationStatus? status,
    List<Notification>? notifications,
    String? cursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return NotificationState._(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, cursor, hasMore, isLoadingMore, isRefreshing, errorMessage];
}
