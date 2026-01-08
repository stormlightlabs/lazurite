import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
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
    final authState = ref.watch(authProvider);

    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      return const Stream.empty();
    }

    return repository.watchConversations(ownerDid);
  }

  /// Refreshes the conversation list.
  ///
  /// Fetches the latest conversations from the API and caches them.
  Future<void> refresh() async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      _cursor = await repository.fetchConversations(ownerDid: ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to refresh conversations', error, stack);
    }
  }

  /// Loads more conversations (pagination).
  ///
  /// Fetches older conversations using the current cursor.
  Future<void> loadMore() async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null || _cursor == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      final newCursor = await repository.fetchConversations(cursor: _cursor, ownerDid: ownerDid);
      _cursor = newCursor;
    } catch (error, stack) {
      _logger.error('Failed to load more conversations', error, stack);
    }
  }

  /// Accepts a conversation request.
  Future<void> acceptConversation(String convoId) async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.acceptConversation(convoId, ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to accept conversation', error, stack);
      rethrow;
    }
  }

  /// Mutes a conversation.
  Future<void> muteConversation(String convoId) async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.muteConversation(convoId, ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to mute conversation', error, stack);
      rethrow;
    }
  }

  /// Unmutes a conversation.
  Future<void> unmuteConversation(String convoId) async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.unmuteConversation(convoId, ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to unmute conversation', error, stack);
      rethrow;
    }
  }

  /// Leaves a conversation.
  Future<void> leaveConversation(String convoId) async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final repository = ref.read(dmsRepositoryProvider);
    try {
      await repository.leaveConversation(convoId, ownerDid);
    } catch (error, stack) {
      _logger.error('Failed to leave conversation', error, stack);
      rethrow;
    }
  }

  /// Marks a conversation as read.
  Future<void> markAsRead(String convoId) async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

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
      rethrow;
    }
  }
}
