// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduling_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

/// Provides the background task-based scheduler implementation.

@ProviderFor(workmanagerScheduler)
final workmanagerSchedulerProvider = WorkmanagerSchedulerProvider._();

/// Provides the background task-based scheduler implementation.

final class WorkmanagerSchedulerProvider
    extends $FunctionalProvider<WorkmanagerScheduler, WorkmanagerScheduler, WorkmanagerScheduler>
    with $Provider<WorkmanagerScheduler> {
  /// Provides the background task-based scheduler implementation.
  WorkmanagerSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workmanagerSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workmanagerSchedulerHash();

  @$internal
  @override
  $ProviderElement<WorkmanagerScheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkmanagerScheduler create(Ref ref) {
    return workmanagerScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkmanagerScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkmanagerScheduler>(value),
    );
  }
}

String _$workmanagerSchedulerHash() => r'c9438a3de181e648b4864a7dbd6375868a40c553';

/// Manages the "Auto-post scheduled drafts" setting.
///
/// When enabled, scheduled posts are automatically published in the background.
/// When disabled (default), the app shows a notification when it's time to publish.

@ProviderFor(AutoPostEnabled)
final autoPostEnabledProvider = AutoPostEnabledProvider._();

/// Manages the "Auto-post scheduled drafts" setting.
///
/// When enabled, scheduled posts are automatically published in the background.
/// When disabled (default), the app shows a notification when it's time to publish.
final class AutoPostEnabledProvider extends $AsyncNotifierProvider<AutoPostEnabled, bool> {
  /// Manages the "Auto-post scheduled drafts" setting.
  ///
  /// When enabled, scheduled posts are automatically published in the background.
  /// When disabled (default), the app shows a notification when it's time to publish.
  AutoPostEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoPostEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoPostEnabledHash();

  @$internal
  @override
  AutoPostEnabled create() => AutoPostEnabled();
}

String _$autoPostEnabledHash() => r'e253916c1b48d121df1c4a5ef10fe80d1ebce695';

/// Manages the "Auto-post scheduled drafts" setting.
///
/// When enabled, scheduled posts are automatically published in the background.
/// When disabled (default), the app shows a notification when it's time to publish.

abstract class _$AutoPostEnabled extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provides the active scheduler instance.
///
/// Returns [WorkmanagerScheduler] if auto-post is enabled,
/// otherwise returns [NotificationScheduler].

@ProviderFor(scheduler)
final schedulerProvider = SchedulerProvider._();

/// Provides the active scheduler instance.
///
/// Returns [WorkmanagerScheduler] if auto-post is enabled,
/// otherwise returns [NotificationScheduler].

final class SchedulerProvider extends $FunctionalProvider<Scheduler, Scheduler, Scheduler>
    with $Provider<Scheduler> {
  /// Provides the active scheduler instance.
  ///
  /// Returns [WorkmanagerScheduler] if auto-post is enabled,
  /// otherwise returns [NotificationScheduler].
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

String _$schedulerHash() => r'e758cb3452fa5d2fb3f4d4000e78db2f4e8ccc3c';

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
