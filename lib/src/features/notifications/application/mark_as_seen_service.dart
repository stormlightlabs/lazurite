import 'dart:async';

import '../../../core/utils/logger.dart';
import '../../../infrastructure/db/daos/notifications_sync_queue_dao.dart';
import '../infrastructure/notifications_repository.dart';

/// Service for batching mark as seen operations.
///
/// Collects notification timestamps and batches API calls to avoid
/// excessive requests when scrolling through notifications.
///
/// Implementation follows the spec requirements:
/// - Batch updates every 2 seconds or when we accumulate notifications
/// - Optimistically update local cache
/// - Queue updates for offline sync (future enhancement)
class MarkAsSeenService {
  MarkAsSeenService(this._repository, this._syncQueue, this._logger);

  final NotificationsRepository _repository;
  final NotificationsSyncQueueDao _syncQueue;
  final Logger _logger;

  /// Maximum time to wait before flushing the batch (2 seconds).
  static const _batchDuration = Duration(seconds: 2);

  /// Timer for batching operations.
  Timer? _batchTimer;

  /// Most recent notification timestamp in the current batch.
  DateTime? _latestSeenTimestamp;

  /// Whether a flush is currently in progress.
  bool _isFlushingseenAt = false;

  /// Marks a notification as seen by adding its timestamp to the batch.
  ///
  /// The notification will be marked locally immediately, and synced
  /// to the server after [_batchDuration] or when enough notifications accumulate.
  void markAsSeen(DateTime notificationTimestamp) {
    _logger.debug('Marking notification as seen', {
      'timestamp': notificationTimestamp.toIso8601String(),
    });

    if (_latestSeenTimestamp == null || notificationTimestamp.isAfter(_latestSeenTimestamp!)) {
      _latestSeenTimestamp = notificationTimestamp;
    }

    _batchTimer?.cancel();
    _batchTimer = Timer(_batchDuration, _flush);
  }

  /// Immediately flushes any pending mark as seen operations.
  ///
  /// Useful for marking all as read or when the app goes to background.
  Future<void> flush() async {
    _batchTimer?.cancel();
    _batchTimer = null;
    await _flush();
  }

  /// Internal flush implementation.
  Future<void> _flush() async {
    if (_isFlushingseenAt || _latestSeenTimestamp == null) {
      return;
    }

    _isFlushingseenAt = true;
    final seenAt = _latestSeenTimestamp!;
    _latestSeenTimestamp = null;

    _logger.info('Flushing mark as seen batch', {'seenAt': seenAt.toIso8601String()});

    try {
      await _repository.markAsSeenLocally(seenAt);
      await _repository.updateSeen(seenAt);

      _logger.debug('Successfully flushed mark as seen batch', {});
    } catch (error, stack) {
      _logger.error('Failed to flush mark as seen batch', error, stack);

      try {
        await _syncQueue.enqueueMarkSeen(seenAt);
        _logger.info('Queued mark as seen for offline sync', {'seenAt': seenAt.toIso8601String()});
      } catch (queueError, queueStack) {
        _logger.error('Failed to queue mark as seen for offline sync', queueError, queueStack);
      }
    } finally {
      _isFlushingseenAt = false;
    }
  }

  /// Disposes the service and cancels any pending timers.
  void dispose() {
    _batchTimer?.cancel();
    _batchTimer = null;
  }
}
