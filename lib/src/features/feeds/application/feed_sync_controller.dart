import 'package:flutter/material.dart';
import 'package:lazurite/src/core/providers/app_lifecycle_provider.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_sync_controller.g.dart';

/// Controller that manages automatic background synchronization of feeds.
///
/// Listens to app lifecycle changes and triggers [FeedRepository.syncOnResume]
/// when the app is resumed.
@Riverpod(keepAlive: true)
void feedSyncController(Ref ref) {
  ref.listen(appLifecycleProvider, (previous, next) {
    if (next == AppLifecycleState.resumed) {
      ref.read(feedRepositoryProvider).syncOnResume();
    }
  });

  Future.microtask(() => ref.read(feedRepositoryProvider).syncOnResume());
}
