import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lazurite/src/core/providers/app_lifecycle_provider.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preference_sync_controller.g.dart';

/// Controller that manages automatic background synchronization of Bluesky preferences.
///
/// Listens to app lifecycle changes and triggers preference sync when the app is resumed
/// or when the user logs in. Also processes the preference sync queue to retry failed updates.
@Riverpod(keepAlive: true)
void preferenceSyncController(Ref ref) {
  final logger = ref.watch(loggerProvider('PreferenceSync'));
  var hasInitialized = false;

  Future<void> runSync() async {
    logger.debug('runSync() called');
    try {
      final repo = ref.read(blueskyPreferencesRepositoryProvider);
      logger.debug('Syncing preferences from remote');
      await repo.syncPreferencesFromRemote();
      logger.info('Preferences synced successfully');

      logger.debug('Processing preference sync queue');
      await repo.processSyncQueue();
      logger.info('Preference sync queue processed');
    } catch (e, stack) {
      logger.error('Failed to sync preferences on resume', e, stack);
    }
  }

  ref.listen(appLifecycleProvider, (previous, next) {
    if (next == AppLifecycleState.resumed) {
      logger.debug('App resumed, triggering preference sync');
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
        if (isAuthed) {
          logger.info('User logged in - triggering preference sync');
          unawaited(runSync());
        } else {
          logger.info('User logged out - clearing cached preferences');
          unawaited(ref.read(blueskyPreferencesRepositoryProvider).clearAll());
        }
      } else if (isAuthed && wasAuthed) {
        final prevSession = previous.session;
        final nextSession = next.session;
        if (prevSession.accessJwt != nextSession.accessJwt) {
          logger.debug('Session refreshed - triggering sync to fetch preferences');
          unawaited(runSync());
        }
      }
    } else {
      logger.debug('Not initialized yet, skipping auth change handling');
    }
  });

  Future.microtask(() async {
    logger.debug('Controller initializing...');
    final authState = ref.read(authProvider);
    logger.debug('Initial auth state: ${authState.runtimeType}');

    if (authState is AuthStateAuthenticated) {
      logger.info('User is authenticated, running initial sync');
      await runSync();
    } else {
      logger.info('User not authenticated, skipping initial sync');
    }

    hasInitialized = true;
    logger.info('Controller initialized');
  });
}
