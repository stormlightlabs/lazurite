import 'package:uuid/uuid.dart';

import '../../../core/utils/logger.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/daos/dm_messages_dao.dart';
import '../../../infrastructure/db/daos/dm_outbox_dao.dart';
import '../../../infrastructure/network/xrpc_client.dart';
import '../domain/outbox_item.dart';

/// Repository for managing the DM outbox queue.
///
/// Handles reliable message delivery with offline support, retry logic,
/// and exponential backoff. Messages are queued locally before sending
/// to ensure they are never lost.
class OutboxRepository {
  OutboxRepository(this._client, this._outboxDao, this._messagesDao, this._logger);

  final XrpcClient _client;
  final DmOutboxDao _outboxDao;
  final DmMessagesDao _messagesDao;
  final Logger _logger;

  /// UUID generator for outbox IDs.
  static const _uuid = Uuid();

  /// Enqueues a message for sending.
  ///
  /// The message is persisted to the outbox and displayed immediately
  /// with pending status. Returns the outbox ID for tracking.
  Future<String> enqueueSend(String convoId, String text, String ownerDid) async {
    final outboxId = _uuid.v4();
    final now = DateTime.now();

    _logger.info('Enqueueing message', {
      'outboxId': outboxId,
      'convoId': convoId,
      'ownerDid': ownerDid,
    });

    await _outboxDao.enqueue(
      DmOutboxCompanion.insert(
        outboxId: outboxId,
        convoId: convoId,
        ownerDid: ownerDid,
        messageText: text,
        status: 'pending',
        createdAt: now,
      ),
    );

    await _messagesDao.insertLocalMessage(
      DmMessagesCompanion.insert(
        messageId: 'pending:$outboxId',
        convoId: convoId,
        ownerDid: ownerDid,
        senderDid: ownerDid,
        content: text,
        sentAt: now,
        status: 'pending',
        cachedAt: now,
      ),
    );

    return outboxId;
  }

  /// Returns a stream of all pending outbox items.
  Stream<List<OutboxItem>> watchPending(String ownerDid) {
    return _outboxDao.watchPending(ownerDid).map((items) {
      return items.map(_toOutboxItem).toList();
    });
  }

  /// Processes the outbox queue, sending pending messages.
  ///
  /// Processes items oldest-first, one at a time per conversation.
  /// Uses exponential backoff for retries.
  Future<void> processOutbox(String ownerDid) async {
    final pending = await _outboxDao.getPending(ownerDid);
    if (pending.isEmpty) {
      _logger.debug('No pending outbox items', {'ownerDid': ownerDid});
      return;
    }

    _logger.info('Processing outbox', {'pendingCount': pending.length, 'ownerDid': ownerDid});

    final processingConvos = <String>{};

    for (final item in pending) {
      if (processingConvos.contains(item.convoId)) {
        continue;
      }
      processingConvos.add(item.convoId);

      final outboxItem = _toOutboxItem(item);
      if (item.lastAttemptAt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(item.lastAttemptAt!);
        if (timeSinceLastAttempt < outboxItem.nextRetryDelay) {
          _logger.debug('Skipping item due to retry delay', {
            'outboxId': item.outboxId,
            'nextRetryIn': (outboxItem.nextRetryDelay - timeSinceLastAttempt).inSeconds,
          });
          continue;
        }
      }

      await _sendMessage(item);
    }
  }

  /// Retries a failed message (user-initiated).
  Future<void> retryMessage(String outboxId, String ownerDid) async {
    _logger.info('Retrying message', {'outboxId': outboxId, 'ownerDid': ownerDid});

    await _outboxDao.resetForRetry(outboxId);

    await _messagesDao.updateMessageStatus(
      messageId: 'pending:$outboxId',
      status: 'pending',
      ownerDid: ownerDid,
    );

    final item = await _outboxDao.getById(outboxId);
    if (item != null) {
      // Ensure we only retry if owner matches
      if (item.ownerDid != ownerDid) {
        _logger.warning('Skipping retry: owner mismatch', {
          'itemOwner': item.ownerDid,
          'reqOwner': ownerDid,
        });
        return;
      }
      await _sendMessage(item);
    }
  }

  /// Deletes a failed message from the outbox.
  Future<void> deleteOutboxItem(String outboxId, String ownerDid) async {
    _logger.info('Deleting outbox item', {'outboxId': outboxId, 'ownerDid': ownerDid});

    await _outboxDao.deleteItem(outboxId);

    await _messagesDao.deleteMessage('pending:$outboxId', ownerDid);
  }

  /// Gets the count of pending outbox items.
  Future<int> getPendingCount(String ownerDid) async {
    return _outboxDao.countPending(ownerDid);
  }

  /// Sends a message via the API.
  Future<void> _sendMessage(DmOutboxData item) async {
    _logger.debug('Sending message', {'outboxId': item.outboxId, 'convoId': item.convoId});
    final ownerDid = item.ownerDid;

    try {
      await _outboxDao.updateStatus(outboxId: item.outboxId, status: 'sending');
      await _messagesDao.updateMessageStatus(
        messageId: 'pending:${item.outboxId}',
        status: 'sending',
        ownerDid: ownerDid,
      );

      final response = await _client.call(
        'chat.bsky.convo.sendMessage',
        body: {
          'convoId': item.convoId,
          'message': {'text': item.messageText},
        },
      );

      final serverMessageId = response['id'] as String?;
      if (serverMessageId != null) {
        await _messagesDao.updateMessageStatus(
          messageId: 'pending:${item.outboxId}',
          status: 'sent',
          ownerDid: ownerDid,
        );
      }

      await _outboxDao.deleteItem(item.outboxId);

      _logger.info('Successfully sent message', {
        'outboxId': item.outboxId,
        'serverMessageId': serverMessageId,
      });
    } catch (error, stack) {
      _logger.error('Failed to send message', error, stack);

      await _outboxDao.incrementRetryCount(item.outboxId);
      final updatedItem = await _outboxDao.getById(item.outboxId);

      if (updatedItem != null && updatedItem.retryCount >= OutboxItem.maxRetries) {
        await _outboxDao.updateStatus(
          outboxId: item.outboxId,
          status: 'failed',
          errorMessage: error.toString(),
        );
        await _messagesDao.updateMessageStatus(
          messageId: 'pending:${item.outboxId}',
          status: 'failed',
          ownerDid: ownerDid,
        );
        _logger.error('Message permanently failed after max retries', error, stack);
      } else {
        await _outboxDao.updateStatus(
          outboxId: item.outboxId,
          status: 'pending',
          errorMessage: error.toString(),
        );
        await _messagesDao.updateMessageStatus(
          messageId: 'pending:${item.outboxId}',
          status: 'pending',
          ownerDid: ownerDid,
        );
      }
    }
  }

  /// Converts database data to domain model.
  OutboxItem _toOutboxItem(DmOutboxData data) {
    return OutboxItem(
      outboxId: data.outboxId,
      convoId: data.convoId,
      messageText: data.messageText,
      status: OutboxStatus.fromString(data.status),
      retryCount: data.retryCount,
      createdAt: data.createdAt,
      lastAttemptAt: data.lastAttemptAt,
      errorMessage: data.errorMessage,
    );
  }
}
