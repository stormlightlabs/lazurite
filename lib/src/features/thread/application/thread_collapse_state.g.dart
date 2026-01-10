// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_collapse_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages collapse/expand state for thread posts.
///
/// State is session-only and keyed by post URI. Posts are expanded by default.

@ProviderFor(ThreadCollapseState)
final threadCollapseStateProvider = ThreadCollapseStateProvider._();

/// Manages collapse/expand state for thread posts.
///
/// State is session-only and keyed by post URI. Posts are expanded by default.
final class ThreadCollapseStateProvider
    extends $NotifierProvider<ThreadCollapseState, Map<String, bool>> {
  /// Manages collapse/expand state for thread posts.
  ///
  /// State is session-only and keyed by post URI. Posts are expanded by default.
  ThreadCollapseStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'threadCollapseStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$threadCollapseStateHash();

  @$internal
  @override
  ThreadCollapseState create() => ThreadCollapseState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, bool>>(value),
    );
  }
}

String _$threadCollapseStateHash() => r'e68ffefdf271e20807ee067a302979b277f3ad5a';

/// Manages collapse/expand state for thread posts.
///
/// State is session-only and keyed by post URI. Posts are expanded by default.

abstract class _$ThreadCollapseState extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, bool>, Map<String, bool>>,
              Map<String, bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
