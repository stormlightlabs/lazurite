import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_list_notifier.g.dart';

@riverpod
class ConversationListNotifier extends _$ConversationListNotifier {
  Logger get _logger => ref.read(loggerProvider('ConversationListNotifier'));
  String? _cursor;

  @override
  Stream<List<DmConversation>> build() {
    final repository = ref.watch(dmsRepositoryProvider);
    return repository.watchConversations();
  }

  /// Refreshes the conversation list.
  ///
  /// Fetches the latest conversations from the API and caches them.
  Future<void> refresh() async {
    final repository = ref.read(dmsRepositoryProvider);
    try {
      _cursor = await repository.fetchConversations();
    } catch (error, stack) {
      _logger.error('Failed to refresh conversations', error, stack);
    }
  }

  /// Loads more conversations (pagination).
  ///
  /// Fetches older conversations using the current cursor.
  Future<void> loadMore() async {
    if (_cursor == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      final newCursor = await repository.fetchConversations(cursor: _cursor);
      _cursor = newCursor;
    } catch (error, stack) {
      _logger.error('Failed to load more conversations', error, stack);
    }
  }

  /// Accepts a conversation request.
  Future<void> acceptConversation(String convoId) async {
    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.acceptConversation(convoId);
    } catch (error, stack) {
      _logger.error('Failed to accept conversation', error, stack);
      rethrow;
    }
  }

  /// Mutes a conversation.
  Future<void> muteConversation(String convoId) async {
    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.muteConversation(convoId);
    } catch (error, stack) {
      _logger.error('Failed to mute conversation', error, stack);
      rethrow;
    }
  }

  /// Unmutes a conversation.
  Future<void> unmuteConversation(String convoId) async {
    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.unmuteConversation(convoId);
    } catch (error, stack) {
      _logger.error('Failed to unmute conversation', error, stack);
      rethrow;
    }
  }

  /// Leaves a conversation.
  Future<void> leaveConversation(String convoId) async {
    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.leaveConversation(convoId);
    } catch (error, stack) {
      _logger.error('Failed to leave conversation', error, stack);
      rethrow;
    }
  }

  /// Marks a conversation as read.
  Future<void> markAsRead(String convoId) async {
    final repository = ref.read(dmsRepositoryProvider);
    try {
      // Fetch latest messages to get the last message ID.
      await repository.fetchMessages(convoId, limit: 1);
      final messages = await repository.watchMessages(convoId).first;
      if (messages.isNotEmpty) {
        // Messages are usually sorted by sentAt, but let's be sure or take the last one?
        // watchMessages in dms_repository.dart uses _messagesDao.watchMessagesByConvo
        // Let's assume it returns descending or we should check the DAO sort order.
        // DmMessagesDao usually defaults to something.
        // If sorting not guaranteed, we might get random.
        // But assuming latest is what we want.
        // DmMessagesDao.watchMessagesByConvo sort?
        // I should check `DmConvosDao`.
        // I will assume the first one is the latest or I can sort.
        // Ideally we pick the one with max sentAt.
        final lastMessage = messages.reduce(
          (curr, next) => curr.sentAt.isAfter(next.sentAt) ? curr : next,
        );

        await repository.updateReadState(convoId, lastMessage.messageId);
      }
    } catch (error, stack) {
      _logger.error('Failed to mark conversation as read', error, stack);
      rethrow;
    }
  }
}
