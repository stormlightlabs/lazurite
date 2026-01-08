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
/// refresh and load more pagination.

@ProviderFor(NotificationsNotifier)
final notificationsProvider = NotificationsNotifierProvider._();

/// Notifier for managing notification list state.
///
/// Watches the notifications stream and provides methods for
/// refresh and load more pagination.
final class NotificationsNotifierProvider
    extends $StreamNotifierProvider<NotificationsNotifier, List<AppNotification>> {
  /// Notifier for managing notification list state.
  ///
  /// Watches the notifications stream and provides methods for
  /// refresh and load more pagination.
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

String _$notificationsNotifierHash() => r'4c8135e870f771092ea4d88fbdde28fd426b7d3f';

/// Notifier for managing notification list state.
///
/// Watches the notifications stream and provides methods for
/// refresh and load more pagination.

abstract class _$NotificationsNotifier extends $StreamNotifier<List<AppNotification>> {
  Stream<List<AppNotification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AppNotification>>, List<AppNotification>>,
              AsyncValue<List<AppNotification>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
