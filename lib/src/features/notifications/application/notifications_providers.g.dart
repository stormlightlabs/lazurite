// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the NotificationsRepository instance.

@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider = NotificationsRepositoryProvider._();

/// Provides the NotificationsRepository instance.

final class NotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationsRepository,
          NotificationsRepository,
          NotificationsRepository
        >
    with $Provider<NotificationsRepository> {
  /// Provides the NotificationsRepository instance.
  NotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationsRepository create(Ref ref) {
    return notificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsRepository>(value),
    );
  }
}

String _$notificationsRepositoryHash() => r'4720900eecda437b9f4be3df1b0f85112169290b';

/// Provides the MarkAsSeenService instance.
///
/// This service batches mark as seen operations to avoid excessive API calls.

@ProviderFor(markAsSeenService)
final markAsSeenServiceProvider = MarkAsSeenServiceProvider._();

/// Provides the MarkAsSeenService instance.
///
/// This service batches mark as seen operations to avoid excessive API calls.

final class MarkAsSeenServiceProvider
    extends $FunctionalProvider<MarkAsSeenService, MarkAsSeenService, MarkAsSeenService>
    with $Provider<MarkAsSeenService> {
  /// Provides the MarkAsSeenService instance.
  ///
  /// This service batches mark as seen operations to avoid excessive API calls.
  MarkAsSeenServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markAsSeenServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markAsSeenServiceHash();

  @$internal
  @override
  $ProviderElement<MarkAsSeenService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MarkAsSeenService create(Ref ref) {
    return markAsSeenService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarkAsSeenService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarkAsSeenService>(value),
    );
  }
}

String _$markAsSeenServiceHash() => r'a963d364ce0b5d226d42add1152044bc846e502b';
