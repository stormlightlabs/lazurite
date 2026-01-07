// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the label filter service with current user preferences.
///
/// Returns null if preferences are still loading or unavailable.

@ProviderFor(labelFilterService)
final labelFilterServiceProvider = LabelFilterServiceProvider._();

/// Provides the label filter service with current user preferences.
///
/// Returns null if preferences are still loading or unavailable.

final class LabelFilterServiceProvider
    extends $FunctionalProvider<LabelFilterService?, LabelFilterService?, LabelFilterService?>
    with $Provider<LabelFilterService?> {
  /// Provides the label filter service with current user preferences.
  ///
  /// Returns null if preferences are still loading or unavailable.
  LabelFilterServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelFilterServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelFilterServiceHash();

  @$internal
  @override
  $ProviderElement<LabelFilterService?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LabelFilterService? create(Ref ref) {
    return labelFilterService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LabelFilterService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LabelFilterService?>(value),
    );
  }
}

String _$labelFilterServiceHash() => r'd4917446fd714fd9ec2b0453b7eefed7f0ce87e2';
