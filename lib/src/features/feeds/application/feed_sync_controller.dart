import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lazurite/src/core/providers/app_lifecycle_provider.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
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
  final logger = ref.watch(loggerProvider('FeedSync'));
  var hasInitialized = false;

  Future<void> seedDefaults() async {
    try {
      await ref.read(feedRepositoryProvider).seedDefaultFeeds();
    } catch (e, stack) {
      logger.warning('Failed to seed default feeds', e, stack);
    }
  }

  Future<void> runSync() async {
    logger.debug('runSync() called');
    await seedDefaults();
    try {
      logger.debug('Calling repository.syncOnResume()');
      await ref.read(feedRepositoryProvider).syncOnResume();
      logger.info('syncOnResume() completed successfully');
    } catch (e, stack) {
      logger.error('Failed to sync feeds on resume', e, stack);
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
    logger.debug('Auth state changed: ${previous.runtimeType} → ${next.runtimeType}');
    if (hasInitialized) {
      final wasAuthed = previous is AuthStateAuthenticated;
      final isAuthed = next is AuthStateAuthenticated;
      logger.debug('wasAuthed=$wasAuthed, isAuthed=$isAuthed');

      if (wasAuthed != isAuthed) {
        logger.info('Auth status changed, switching active feed');
        setActiveFeed(next);
        if (isAuthed) {
          logger.info('User logged in - triggering full sync');
          unawaited(runSync());
        }
      } else if (isAuthed && wasAuthed) {
        final prevSession = previous.session;
        final nextSession = next.session;
        if (prevSession.accessJwt != nextSession.accessJwt) {
          logger.debug('Session refreshed - triggering sync to fetch feeds');
          unawaited(runSync());
        }
      }
    } else {
      logger.debug('Not initialized yet, skipping auth change handling');
    }
    unawaited(seedDefaults());
  });

  Future.microtask(() async {
    logger.debug('Controller initializing...');
    await runSync();
    final authState = ref.read(authProvider);
    logger.debug('Initial auth state: ${authState.runtimeType}');
    setActiveFeed(authState);
    hasInitialized = true;
    logger.info('Controller initialized');
  });
}
