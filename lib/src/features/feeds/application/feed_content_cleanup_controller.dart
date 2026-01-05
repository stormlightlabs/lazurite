import 'package:flutter/material.dart';
import 'package:lazurite/src/core/providers/app_lifecycle_provider.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_content_cleanup_controller.g.dart';

/// Controller that manages cache cleanup for feed content items.
///
/// Listens to app lifecycle changes and triggers [FeedContentRepository.cleanupCache]
/// when the app is resumed or on startup.
@Riverpod(keepAlive: true)
void feedContentCleanupController(Ref ref) {
  ref.listen(appLifecycleProvider, (previous, next) {
    if (next == AppLifecycleState.resumed) {
      ref.read(feedContentRepositoryProvider).cleanupCache();
    }
  });

  Future.microtask(() => ref.read(feedContentRepositoryProvider).cleanupCache());
}
