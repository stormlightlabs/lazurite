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
/// Listens to app lifecycle changes and triggers [FeedRepository.syncOnResume] when the
/// app is resumed.
@Riverpod(keepAlive: true)
void feedSyncController(Ref ref) {
  var hasInitialized = false;

  Future<void> seedDefaults() async {
    try {
      await ref.read(feedRepositoryProvider).seedDefaultFeeds();
    } catch (e, stack) {
      debugPrint('Failed to seed default feeds: $e\n$stack');
    }
  }

  Future<void> runSync() async {
    debugPrint('[FeedSync] runSync() called');
    await seedDefaults();
    try {
      debugPrint('[FeedSync] Calling repository.syncOnResume()');
      await ref.read(feedRepositoryProvider).syncOnResume();
      debugPrint('[FeedSync] syncOnResume() completed successfully');
    } catch (e, stack) {
      debugPrint('[FeedSync] Failed to sync feeds on resume: $e\n$stack');
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
    debugPrint('[FeedSync] Auth state changed: ${previous.runtimeType} → ${next.runtimeType}');
    if (hasInitialized) {
      final wasAuthed = previous is AuthStateAuthenticated;
      final isAuthed = next is AuthStateAuthenticated;
      debugPrint('[FeedSync] wasAuthed=$wasAuthed, isAuthed=$isAuthed');

      if (wasAuthed != isAuthed) {
        debugPrint('[FeedSync] Auth status changed, switching active feed');
        setActiveFeed(next);
        if (isAuthed) {
          debugPrint('[FeedSync] User logged in - triggering full sync');
          unawaited(runSync());
        }
      } else if (isAuthed && wasAuthed) {
        final prevSession = previous.session;
        final nextSession = next.session;
        if (prevSession.accessJwt != nextSession.accessJwt) {
          debugPrint('[FeedSync] Session refreshed - triggering sync to fetch feeds');
          unawaited(runSync());
        }
      }
    } else {
      debugPrint('[FeedSync] Not initialized yet, skipping auth change handling');
    }
    unawaited(seedDefaults());
  });

  Future.microtask(() async {
    debugPrint('[FeedSync] Controller initializing...');
    await runSync();
    final authState = ref.read(authProvider);
    debugPrint('[FeedSync] Initial auth state: ${authState.runtimeType}');
    setActiveFeed(authState);
    hasInitialized = true;
    debugPrint('[FeedSync] Controller initialized');
  });
}
