import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/dms/domain/dm_message.dart';
import 'package:lazurite/src/features/dms/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_detail_notifier.g.dart';

/// Notifier for managing conversation detail state.
///
/// Provides a stream of messages for a specific conversation and handles
/// sending new messages via the outbox pattern.
@riverpod
class ConversationDetailNotifier extends _$ConversationDetailNotifier {
  Logger get _logger => ref.read(loggerProvider('ConversationDetailNotifier'));
  String? _cursor;

  @override
  Stream<List<AppDmMessage>> build(String convoId) {
    final repository = ref.watch(dmsRepositoryProvider);
    final authState = ref.watch(authProvider);

    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      return const Stream.empty();
    }

    _markAsRead(convoId, ownerDid);

    return repository.watchMessages(convoId, ownerDid);
  }

  /// Refreshes messages for the conversation.
  ///
  /// Fetches the latest messages from the API and caches them.
  Future<void> refresh() async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      _cursor = await repository.fetchMessages(convoId, ownerDid: ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to refresh messages', error, stack);
    }
  }

  /// Loads more messages (pagination).
  ///
  /// Fetches older messages using the current cursor.
  Future<void> loadMore() async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null || _cursor == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      final newCursor = await repository.fetchMessages(
        convoId,
        cursor: _cursor,
        ownerDid: ownerDid,
      );
      _cursor = newCursor;
    } catch (error, stack) {
      _logger.error('Failed to load more messages', error, stack);
    }
  }

  /// Sends a message to the conversation.
  ///
  /// Enqueues the message in the outbox for reliable delivery.
  /// The message will appear immediately with pending status.
  Future<void> sendMessage(String text) async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final outboxRepo = ref.read(outboxRepositoryProvider);
    try {
      await outboxRepo.enqueueSend(convoId, text, ownerDid);
      await outboxRepo.processOutbox(ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to send message', error, stack);
      rethrow;
    }
  }

  /// Retries sending a failed message.
  Future<void> retryMessage(String outboxId) async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final outboxRepo = ref.read(outboxRepositoryProvider);
    try {
      await outboxRepo.retryMessage(outboxId, ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to retry message', error, stack);
      rethrow;
    }
  }

  /// Marks the conversation as read.
  Future<void> _markAsRead(String convoId, String ownerDid) async {
    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.fetchMessages(convoId, ownerDid: ownerDid, limit: 1);
      final messages = await repository.watchMessages(convoId, ownerDid).first;
      if (messages.isNotEmpty) {
        final lastMessage = messages.reduce(
          (curr, next) => curr.sentAt.isAfter(next.sentAt) ? curr : next,
        );

        await repository.updateReadState(
          convoId: convoId,
          ownerDid: ownerDid,
          messageId: lastMessage.messageId,
        );
      }
    } catch (error, stack) {
      _logger.error('Failed to mark conversation as read', error, stack);
    }
  }
}
