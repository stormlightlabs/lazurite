import 'package:flutter/material.dart';
import 'package:lazurite/src/core/providers/app_lifecycle_provider.dart';
import 'package:lazurite/src/features/timeline/application/timeline_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_cleanup_controller.g.dart';

/// Controller that manages cache cleanup for timeline items.
///
/// Listens to app lifecycle changes and triggers [TimelineRepository.cleanupCache]
/// when the app is resumed or on startup.
@Riverpod(keepAlive: true)
void timelineCleanupController(Ref ref) {
  ref.listen(appLifecycleProvider, (previous, next) {
    if (next == AppLifecycleState.resumed) {
      ref.read(timelineRepositoryProvider).cleanupCache();
    }
  });

  Future.microtask(() => ref.read(timelineRepositoryProvider).cleanupCache());
}
