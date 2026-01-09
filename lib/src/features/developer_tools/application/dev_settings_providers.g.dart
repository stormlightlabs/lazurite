// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides access to developer tools settings.
///
/// Manages whether developer tools are enabled in production builds.
/// In kDebugMode, developer tools are always accessible regardless of this setting.

@ProviderFor(DevToolsEnabled)
final devToolsEnabledProvider = DevToolsEnabledProvider._();

/// Provides access to developer tools settings.
///
/// Manages whether developer tools are enabled in production builds.
/// In kDebugMode, developer tools are always accessible regardless of this setting.
final class DevToolsEnabledProvider extends $AsyncNotifierProvider<DevToolsEnabled, bool> {
  /// Provides access to developer tools settings.
  ///
  /// Manages whether developer tools are enabled in production builds.
  /// In kDebugMode, developer tools are always accessible regardless of this setting.
  DevToolsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devToolsEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devToolsEnabledHash();

  @$internal
  @override
  DevToolsEnabled create() => DevToolsEnabled();
}

String _$devToolsEnabledHash() => r'2a5ff517a0ce9c0bbe8e41b3b64b9563fbec4712';

/// Provides access to developer tools settings.
///
/// Manages whether developer tools are enabled in production builds.
/// In kDebugMode, developer tools are always accessible regardless of this setting.

abstract class _$DevToolsEnabled extends $AsyncNotifier<bool> {
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
