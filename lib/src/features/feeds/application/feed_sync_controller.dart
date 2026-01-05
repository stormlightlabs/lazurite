import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lazurite/src/core/providers/app_lifecycle_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_sync_controller.g.dart';

/// Controller that manages automatic background synchronization of feeds.
///
/// Listens to app lifecycle changes and triggers [FeedRepository.syncOnResume]
/// when the app is resumed.
@Riverpod(keepAlive: true)
void feedSyncController(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider);
  var hasInitialized = false;

  Future<void> seedDefaults() async {
    try {
      await repository.seedDefaultFeeds();
    } catch (e, stack) {
      debugPrint('Failed to seed default feeds: $e\n$stack');
    }
  }

  Future<void> runSync() async {
    await seedDefaults();
    try {
      await repository.syncOnResume();
    } catch (e, stack) {
      debugPrint('Failed to sync feeds on resume: $e\n$stack');
    }
  }

  void setActiveFeed(AuthState state) {
    final notifier = ref.read(activeFeedProvider.notifier);
    if (state is AuthStateAuthenticated) {
      notifier.switchToHome();
    } else {
      notifier.switchToDiscover();
    }
  }

  ref.listen(appLifecycleProvider, (previous, next) {
    if (next == AppLifecycleState.resumed) {
      unawaited(runSync());
    }
  });

  ref.listen(authProvider, (previous, next) {
    if (hasInitialized) {
      final wasAuthed = previous is AuthStateAuthenticated;
      final isAuthed = next is AuthStateAuthenticated;
      if (wasAuthed != isAuthed) {
        setActiveFeed(next);
      }
    }
    unawaited(seedDefaults());
  });

  Future.microtask(() async {
    await runSync();
    setActiveFeed(ref.read(authProvider));
    hasInitialized = true;
  });
}
