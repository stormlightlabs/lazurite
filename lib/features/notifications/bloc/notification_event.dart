part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested({this.limit = 50});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class NotificationsRefreshed extends NotificationEvent {
  const NotificationsRefreshed();
}

class NotificationsPageLoaded extends NotificationEvent {
  const NotificationsPageLoaded({this.limit = 50});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class NotificationsMarkedRead extends NotificationEvent {
  const NotificationsMarkedRead();
}
