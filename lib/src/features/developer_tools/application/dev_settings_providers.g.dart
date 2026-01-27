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

/// Provides access to the 'allow other repos' developer setting.

@ProviderFor(AllowOtherRepos)
final allowOtherReposProvider = AllowOtherReposProvider._();

/// Provides access to the 'allow other repos' developer setting.
final class AllowOtherReposProvider extends $AsyncNotifierProvider<AllowOtherRepos, bool> {
  /// Provides access to the 'allow other repos' developer setting.
  AllowOtherReposProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allowOtherReposProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allowOtherReposHash();

  @$internal
  @override
  AllowOtherRepos create() => AllowOtherRepos();
}

String _$allowOtherReposHash() => r'f3aab48e3ec3c2b1e1c83107db2d3fef19d4ff0e';

/// Provides access to the 'allow other repos' developer setting.

abstract class _$AllowOtherRepos extends $AsyncNotifier<bool> {
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

/// Provides access to the 'enable record editing' developer setting.

@ProviderFor(EnableRecordEditing)
final enableRecordEditingProvider = EnableRecordEditingProvider._();

/// Provides access to the 'enable record editing' developer setting.
final class EnableRecordEditingProvider extends $AsyncNotifierProvider<EnableRecordEditing, bool> {
  /// Provides access to the 'enable record editing' developer setting.
  EnableRecordEditingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enableRecordEditingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enableRecordEditingHash();

  @$internal
  @override
  EnableRecordEditing create() => EnableRecordEditing();
}

String _$enableRecordEditingHash() => r'2e0353adeec87202ea73da1aa3fc36a895bb17b7';

/// Provides access to the 'enable record editing' developer setting.

abstract class _$EnableRecordEditing extends $AsyncNotifier<bool> {
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
