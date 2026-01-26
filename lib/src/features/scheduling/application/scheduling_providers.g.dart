// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduling_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the session storage for scheduling operations.

@ProviderFor(sessionStorage)
final sessionStorageProvider = SessionStorageProvider._();

/// Provides the session storage for scheduling operations.

final class SessionStorageProvider
    extends $FunctionalProvider<SessionStorage, SessionStorage, SessionStorage>
    with $Provider<SessionStorage> {
  /// Provides the session storage for scheduling operations.
  SessionStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStorageHash();

  @$internal
  @override
  $ProviderElement<SessionStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionStorage create(Ref ref) {
    return sessionStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStorage>(value),
    );
  }
}

String _$sessionStorageHash() => r'c054ab7018eab1db05df3ce70acf916f8770e07d';

/// Provides the notification-based scheduler implementation.
///
/// This is the default scheduler for the app, using local notifications
/// to trigger post publishing at scheduled times.

@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = NotificationSchedulerProvider._();

/// Provides the notification-based scheduler implementation.
///
/// This is the default scheduler for the app, using local notifications
/// to trigger post publishing at scheduled times.

final class NotificationSchedulerProvider
    extends
        $FunctionalProvider<NotificationScheduler, NotificationScheduler, NotificationScheduler>
    with $Provider<NotificationScheduler> {
  /// Provides the notification-based scheduler implementation.
  ///
  /// This is the default scheduler for the app, using local notifications
  /// to trigger post publishing at scheduled times.
  NotificationSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSchedulerHash();

  @$internal
  @override
  $ProviderElement<NotificationScheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationScheduler create(Ref ref) {
    return notificationScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationScheduler>(value),
    );
  }
}

String _$notificationSchedulerHash() => r'7c8762242a85e0a610845470905b414473cd8d54';

/// Provides the active scheduler instance.
///
/// Currently returns the notification-based scheduler, but can be
/// swapped to use background task scheduling in the future.

@ProviderFor(scheduler)
final schedulerProvider = SchedulerProvider._();

/// Provides the active scheduler instance.
///
/// Currently returns the notification-based scheduler, but can be
/// swapped to use background task scheduling in the future.

final class SchedulerProvider extends $FunctionalProvider<Scheduler, Scheduler, Scheduler>
    with $Provider<Scheduler> {
  /// Provides the active scheduler instance.
  ///
  /// Currently returns the notification-based scheduler, but can be
  /// swapped to use background task scheduling in the future.
  SchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schedulerHash();

  @$internal
  @override
  $ProviderElement<Scheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Scheduler create(Ref ref) {
    return scheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Scheduler value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Scheduler>(value));
  }
}

String _$schedulerHash() => r'fd52e1237e7b838371ce497a3da0fb2672410dba';

/// Provides the post publisher service.
///
/// This service handles the actual publishing of scheduled drafts,
/// including session refresh, record creation, and status updates.

@ProviderFor(postPublisher)
final postPublisherProvider = PostPublisherProvider._();

/// Provides the post publisher service.
///
/// This service handles the actual publishing of scheduled drafts,
/// including session refresh, record creation, and status updates.

final class PostPublisherProvider
    extends $FunctionalProvider<PostPublisher, PostPublisher, PostPublisher>
    with $Provider<PostPublisher> {
  /// Provides the post publisher service.
  ///
  /// This service handles the actual publishing of scheduled drafts,
  /// including session refresh, record creation, and status updates.
  PostPublisherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postPublisherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postPublisherHash();

  @$internal
  @override
  $ProviderElement<PostPublisher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostPublisher create(Ref ref) {
    return postPublisher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostPublisher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostPublisher>(value),
    );
  }
}

String _$postPublisherHash() => r'dff5e47c8839fff052233bf4e80490612151fb81';

/// Provides the schedule repository.
///
/// This repository handles database operations for scheduled posts,
/// including CRUD operations and status management.

@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = ScheduleRepositoryProvider._();

/// Provides the schedule repository.
///
/// This repository handles database operations for scheduled posts,
/// including CRUD operations and status management.

final class ScheduleRepositoryProvider
    extends $FunctionalProvider<ScheduleRepository, ScheduleRepository, ScheduleRepository>
    with $Provider<ScheduleRepository> {
  /// Provides the schedule repository.
  ///
  /// This repository handles database operations for scheduled posts,
  /// including CRUD operations and status management.
  ScheduleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleRepositoryHash();

  @$internal
  @override
  $ProviderElement<ScheduleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScheduleRepository create(Ref ref) {
    return scheduleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleRepository>(value),
    );
  }
}

String _$scheduleRepositoryHash() => r'09e32051f360cdda20e0b4b84f9f510e5dccd113';
