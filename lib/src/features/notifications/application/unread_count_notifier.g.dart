// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing unread notification count.
///
/// Watches the unread count stream from the database and provides
/// reactive updates when notifications are marked as read.

@ProviderFor(UnreadCountNotifier)
final unreadCountProvider = UnreadCountNotifierProvider._();

/// Notifier for managing unread notification count.
///
/// Watches the unread count stream from the database and provides
/// reactive updates when notifications are marked as read.
final class UnreadCountNotifierProvider extends $StreamNotifierProvider<UnreadCountNotifier, int> {
  /// Notifier for managing unread notification count.
  ///
  /// Watches the unread count stream from the database and provides
  /// reactive updates when notifications are marked as read.
  UnreadCountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountNotifierHash();

  @$internal
  @override
  UnreadCountNotifier create() => UnreadCountNotifier();
}

String _$unreadCountNotifierHash() => r'd92a51e1927057acc715ca32c4371e16e56b8707';

/// Notifier for managing unread notification count.
///
/// Watches the unread count stream from the database and provides
/// reactive updates when notifications are marked as read.

abstract class _$UnreadCountNotifier extends $StreamNotifier<int> {
  Stream<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
