import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
SystemInfo systemInfo(Ref ref) {
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

  // TODO: Get from Flutter's dart:developer or package info
  return SystemInfo(
    flutterVersion: '3.27.1',
    buildMode: buildMode,
    platform: defaultTargetPlatform.name,
    osVersion: osVersion,
    screenSize: size,
    pixelRatio: window.devicePixelRatio,
    safeAreaInsets: EdgeInsets.fromViewPadding(padding, window.devicePixelRatio),
    memoryUsage: memoryUsage,
    currentFps: null,
  );
}
