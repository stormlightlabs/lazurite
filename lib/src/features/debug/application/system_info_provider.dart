import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_info_provider.g.dart';

/// Information about the current system and app state.
class SystemInfo {
  const SystemInfo({
    required this.flutterVersion,
    required this.buildMode,
    required this.platform,
    required this.osVersion,
    required this.screenSize,
    required this.pixelRatio,
    required this.safeAreaInsets,
    required this.appVersion,
    required this.buildNumber,
    this.gitVersion,
    this.memoryUsage,
    this.currentFps,
  });

  /// Flutter framework version.
  final String flutterVersion;

  /// Build mode: debug, profile, or release.
  final String buildMode;

  /// Target platform name.
  final String platform;

  /// Operating system version.
  final String osVersion;

  /// Current screen size.
  final Size screenSize;

  /// Device pixel ratio.
  final double pixelRatio;

  /// Safe area insets.
  final EdgeInsets safeAreaInsets;

  /// App version (e.g. 1.0.0).
  final String appVersion;

  /// Build number (e.g. 1).
  final String buildNumber;

  /// Git version string (from --dart-define=GIT_VERSION=...).
  final String? gitVersion;

  /// Memory usage in bytes (if available).
  final int? memoryUsage;

  /// Current frame rate (if available).
  final double? currentFps;
}

/// Provides current system information.
///
/// This provider collects platform and device information for display in the
/// debug overlay's System Info tab.
@riverpod
Future<SystemInfo> systemInfo(Ref ref) async {
  final window = WidgetsBinding.instance.platformDispatcher.views.first;
  final size = window.physicalSize / window.devicePixelRatio;
  final padding = window.padding;

  String buildMode;
  if (kDebugMode) {
    buildMode = 'Debug';
  } else if (kProfileMode) {
    buildMode = 'Profile';
  } else {
    buildMode = 'Release';
  }

  String osVersion;
  try {
    osVersion = Platform.operatingSystemVersion;
  } catch (_) {
    osVersion = 'Unknown';
  }

  int? memoryUsage;
  try {
    memoryUsage = ProcessInfo.currentRss;
  } catch (_) {
    memoryUsage = null;
  }

  final packageInfo = await PackageInfo.fromPlatform();
  const gitVersion = String.fromEnvironment('GIT_VERSION');

  return SystemInfo(
    flutterVersion: const String.fromEnvironment('FLUTTER_VERSION', defaultValue: 'Unknown'),
    buildMode: buildMode,
    platform: defaultTargetPlatform.name,
    osVersion: osVersion,
    screenSize: size,
    pixelRatio: window.devicePixelRatio,
    safeAreaInsets: EdgeInsets.fromViewPadding(padding, window.devicePixelRatio),
    appVersion: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
    gitVersion: gitVersion.isEmpty ? null : gitVersion,
    memoryUsage: memoryUsage,
    currentFps: null,
  );
}
