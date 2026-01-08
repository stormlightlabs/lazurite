// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing notification list state.
///
/// Watches the notifications stream and provides methods for
/// refresh and load more pagination. Returns grouped notifications
/// for compact display.

@ProviderFor(NotificationsNotifier)
final notificationsProvider = NotificationsNotifierProvider._();

/// Notifier for managing notification list state.
///
/// Watches the notifications stream and provides methods for
/// refresh and load more pagination. Returns grouped notifications
/// for compact display.
final class NotificationsNotifierProvider
    extends $StreamNotifierProvider<NotificationsNotifier, List<GroupedNotification>> {
  /// Notifier for managing notification list state.
  ///
  /// Watches the notifications stream and provides methods for
  /// refresh and load more pagination. Returns grouped notifications
  /// for compact display.
  NotificationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsNotifierHash();

  @$internal
  @override
  NotificationsNotifier create() => NotificationsNotifier();
}

String _$notificationsNotifierHash() => r'650ebb9034f46b19f7440fa0b1ceb5aff49d4431';

/// Notifier for managing notification list state.
///
/// Watches the notifications stream and provides methods for
/// refresh and load more pagination. Returns grouped notifications
/// for compact display.

abstract class _$NotificationsNotifier extends $StreamNotifier<List<GroupedNotification>> {
  Stream<List<GroupedNotification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<GroupedNotification>>, List<GroupedNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GroupedNotification>>, List<GroupedNotification>>,
              AsyncValue<List<GroupedNotification>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
