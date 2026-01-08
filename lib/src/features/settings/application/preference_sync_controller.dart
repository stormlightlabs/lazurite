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

  Future<void> runSync([String? ownerDid]) async {
    logger.debug('runSync() called', {'ownerDid': ownerDid});

    // If ownerDid is not provided, try to get it from current state
    final authState = ref.read(authProvider);
    final effectiveOwnerDid =
        ownerDid ?? ((authState is AuthStateAuthenticated) ? authState.session.did : null);

    if (effectiveOwnerDid == null) {
      logger.debug('Skipping sync: no ownerDid available');
      return;
    }

    try {
      final repo = ref.read(blueskyPreferencesRepositoryProvider);
      logger.debug('Syncing preferences from remote');
      await repo.syncPreferencesFromRemote(effectiveOwnerDid);
      logger.info('Preferences synced successfully');

      logger.debug('Processing preference sync queue');
      await repo.processSyncQueue(effectiveOwnerDid);
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
          final newDid = next.session.did;
          unawaited(runSync(newDid));
        } else {
          logger.info('User logged out - clearing cached preferences');
          final oldDid = (previous as AuthStateAuthenticated).session.did;
          unawaited(ref.read(blueskyPreferencesRepositoryProvider).clearAll(oldDid));
        }
      } else if (isAuthed && wasAuthed) {
        final prevSession = previous.session;
        final nextSession = next.session;
        if (prevSession.accessJwt != nextSession.accessJwt && prevSession.did == nextSession.did) {
          // Same user, session refresh
          logger.debug('Session refreshed - triggering sync to fetch preferences');
          unawaited(runSync(nextSession.did));
        } else if (prevSession.did != nextSession.did) {
          // User switched without full logout/login cycle (e.g. account switcher)
          logger.info('User switched - clearing old prefs and syncing new');
          unawaited(ref.read(blueskyPreferencesRepositoryProvider).clearAll(prevSession.did));
          unawaited(runSync(nextSession.did));
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
      await runSync(authState.session.did);
    } else {
      logger.info('User not authenticated, skipping initial sync');
    }

    hasInitialized = true;
    logger.info('Controller initialized');
  });
}
