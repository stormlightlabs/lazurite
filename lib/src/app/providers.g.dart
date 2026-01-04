// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app's [GoRouter] instance.
///
/// This is the primary router provider.
/// Use it to access navigation from anywhere in the app via `ref.read(goRouterProvider)`.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// Provides the app's [GoRouter] instance.
///
/// This is the primary router provider.
/// Use it to access navigation from anywhere in the app via `ref.read(goRouterProvider)`.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the app's [GoRouter] instance.
  ///
  /// This is the primary router provider.
  /// Use it to access navigation from anywhere in the app via `ref.read(goRouterProvider)`.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'0f11f06525444b252219f9683a0bddc514a3daa3';
