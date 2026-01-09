// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides current system information.
///
/// This provider collects platform and device information for display
/// in the debug overlay's System Info tab.

@ProviderFor(systemInfo)
final systemInfoProvider = SystemInfoProvider._();

/// Provides current system information.
///
/// This provider collects platform and device information for display
/// in the debug overlay's System Info tab.

final class SystemInfoProvider extends $FunctionalProvider<SystemInfo, SystemInfo, SystemInfo>
    with $Provider<SystemInfo> {
  /// Provides current system information.
  ///
  /// This provider collects platform and device information for display
  /// in the debug overlay's System Info tab.
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
  $ProviderElement<SystemInfo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SystemInfo create(Ref ref) {
    return systemInfo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SystemInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SystemInfo>(value),
    );
  }
}

String _$systemInfoHash() => r'890621785c05180fa804c5f9db9c80e496ed3a9f';
