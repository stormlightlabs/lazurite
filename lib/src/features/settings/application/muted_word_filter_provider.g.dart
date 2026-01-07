// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muted_word_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the muted word filter service with current user preferences.
///
/// Returns null if preferences are still loading or unavailable.
/// Only includes active (non-expired) muted words.

@ProviderFor(mutedWordFilterService)
final mutedWordFilterServiceProvider = MutedWordFilterServiceProvider._();

/// Provides the muted word filter service with current user preferences.
///
/// Returns null if preferences are still loading or unavailable.
/// Only includes active (non-expired) muted words.

final class MutedWordFilterServiceProvider
    extends
        $FunctionalProvider<
          MutedWordFilterService?,
          MutedWordFilterService?,
          MutedWordFilterService?
        >
    with $Provider<MutedWordFilterService?> {
  /// Provides the muted word filter service with current user preferences.
  ///
  /// Returns null if preferences are still loading or unavailable.
  /// Only includes active (non-expired) muted words.
  MutedWordFilterServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mutedWordFilterServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mutedWordFilterServiceHash();

  @$internal
  @override
  $ProviderElement<MutedWordFilterService?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MutedWordFilterService? create(Ref ref) {
    return mutedWordFilterService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MutedWordFilterService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MutedWordFilterService?>(value),
    );
  }
}

String _$mutedWordFilterServiceHash() => r'f21f307d213538a53618f9be274ddfe43bb38df9';
