import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/app_lifecycle_provider.dart';
import '../../../core/utils/logger_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_state.dart';
import '../providers.dart';

part 'outbox_worker_controller.g.dart';

/// Controller that manages automatic background processing of the DM outbox.
///
/// Triggers [OutboxRepository.processOutbox] when:
/// - Periodically every 10 seconds
/// - App resumes from background
/// - User authenticates
@Riverpod(keepAlive: true)
void outboxWorkerController(Ref ref) {
  final logger = ref.watch(loggerProvider('OutboxWorker'));
  Timer? periodicTimer;

  Future<void> processOutbox() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) {
      logger.debug('Skipping outbox processing: not authenticated');
      return;
    }

    final ownerDid = authState.session.did;
    logger.debug('Processing outbox', {'ownerDid': ownerDid});

    try {
      await ref.read(outboxRepositoryProvider).processOutbox(ownerDid);
    } catch (e, stack) {
      logger.error('Failed to process outbox', e, stack);
    }
  }

  periodicTimer = Timer.periodic(const Duration(seconds: 10), (_) => unawaited(processOutbox()));

  ref.listen(appLifecycleProvider, (previous, next) {
    if (next == AppLifecycleState.resumed) {
      logger.debug('App resumed, triggering outbox processing');
      unawaited(processOutbox());
    }
  });

  ref.listen(authProvider, (previous, next) {
    if (next is AuthStateAuthenticated && previous is! AuthStateAuthenticated) {
      logger.info('User authenticated, triggering outbox processing');
      unawaited(processOutbox());
    }
  });

  ref.onDispose(() {
    logger.debug('Disposing outbox worker');
    periodicTimer?.cancel();
  });

  Future.microtask(() async {
    logger.info('Outbox worker initialized');
    await processOutbox();
  });
}
