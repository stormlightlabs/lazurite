// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides current system information.
///
/// This provider collects platform and device information for display in the
/// debug overlay's System Info tab.

@ProviderFor(systemInfo)
final systemInfoProvider = SystemInfoProvider._();

/// Provides current system information.
///
/// This provider collects platform and device information for display in the
/// debug overlay's System Info tab.

final class SystemInfoProvider
    extends $FunctionalProvider<AsyncValue<SystemInfo>, SystemInfo, FutureOr<SystemInfo>>
    with $FutureModifier<SystemInfo>, $FutureProvider<SystemInfo> {
  /// Provides current system information.
  ///
  /// This provider collects platform and device information for display in the
  /// debug overlay's System Info tab.
  SystemInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemInfoHash();

  @$internal
  @override
  $FutureProviderElement<SystemInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SystemInfo> create(Ref ref) {
    return systemInfo(ref);
  }
}

String _$systemInfoHash() => r'3d8c64eeada1894c729201718b6e0e226c84455f';
