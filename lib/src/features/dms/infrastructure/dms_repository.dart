import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/utils/logger.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/daos/dm_convos_dao.dart';
import '../../../infrastructure/db/daos/dm_messages_dao.dart';
import '../../../infrastructure/network/xrpc_client.dart';
import '../domain/dm_conversation.dart';
import '../domain/dm_message.dart' as domain;

/// Repository for managing direct messages from Bluesky.
///
/// Handles fetching, caching, and streaming conversations and messages from
/// chat.bsky.convo.* API endpoints. All requests include the atproto-proxy
/// header for service routing.
class DmsRepository {
  DmsRepository(this._client, this._convosDao, this._messagesDao, this._logger);

  final XrpcClient _client;
  final DmConvosDao _convosDao;
  final DmMessagesDao _messagesDao;
  final Logger _logger;

  /// Fetches conversations from the API and caches them locally.
  ///
  /// [cursor] - Pagination cursor for fetching older conversations.
  /// [limit] - Maximum number of conversations to fetch (default 50).
  Future<String?> fetchConversations({String? cursor, int limit = 50}) async {
    _logger.info('Fetching conversations', {'cursor': cursor, 'limit': limit});

    try {
      final params = <String, dynamic>{'limit': limit.clamp(1, 100)};
      if (cursor != null) {
        params['cursor'] = cursor;
      }

      final response = await _client.call('chat.bsky.convo.listConvos', params: params);

      final convosList = response['convos'] as List<dynamic>? ?? [];
      final newCursor = response['cursor'] as String?;

      _logger.debug('Received conversations', {
        'count': convosList.length,
        'newCursor': newCursor,
      });

      final convos = <DmConvosCompanion>[];
      final profiles = <ProfilesCompanion>[];
      final now = DateTime.now();

      for (final item in convosList) {
        final convoMap = item as Map<String, dynamic>;
        final members = convoMap['members'] as List<dynamic>? ?? [];

        final memberDids = <String>[];
        for (final member in members) {
          final memberMap = member as Map<String, dynamic>;
          final did = memberMap['did'] as String?;
          if (did == null) continue;

          memberDids.add(did);
          profiles.add(
            ProfilesCompanion.insert(
              did: did,
              handle: memberMap['handle'] as String? ?? 'unknown',
              displayName: Value(memberMap['displayName'] as String?),
              description: Value(memberMap['description'] as String?),
              avatar: Value(memberMap['avatar'] as String?),
            ),
          );
        }

        if (memberDids.isEmpty) continue;

        final lastMessage = convoMap['lastMessage'] as Map<String, dynamic>?;
        String? lastMessageText;
        DateTime? lastMessageAt;

        if (lastMessage != null) {
          lastMessageText = lastMessage['text'] as String?;
          final sentAtStr = lastMessage['sentAt'] as String?;
          if (sentAtStr != null) {
            lastMessageAt = DateTime.tryParse(sentAtStr);
          }
        }

        convos.add(
          DmConvosCompanion.insert(
            convoId: convoMap['id'] as String,
            membersJson: jsonEncode(memberDids),
            lastMessageText: Value(lastMessageText),
            lastMessageAt: Value(lastMessageAt),
            unreadCount: Value(convoMap['unreadCount'] as int? ?? 0),
            isMuted: Value(convoMap['muted'] as bool? ?? false),
            isAccepted: const Value(true),
            cachedAt: now,
          ),
        );
      }

      await _convosDao.insertConvosBatch(newConvos: convos, newProfiles: profiles);

      _logger.info('Cached conversations', {
        'convoCount': convos.length,
        'profileCount': profiles.length,
      });

      return newCursor;
    } catch (error, stack) {
      _logger.error('Failed to fetch conversations', error, stack);
      rethrow;
    }
  }

  /// Returns a stream of conversations from the local cache.
  ///
  /// Conversations are joined with member profiles for complete display data.
  Stream<List<DmConversation>> watchConversations() {
    return _convosDao.watchConversations().map((items) {
      return items.map((item) {
        return DmConversation(
          convoId: item.convo.convoId,
          members: item.members,
          lastMessageText: item.convo.lastMessageText,
          lastMessageAt: item.convo.lastMessageAt,
          lastReadMessageId: item.convo.lastReadMessageId,
          unreadCount: item.convo.unreadCount,
          isMuted: item.convo.isMuted,
          isAccepted: item.convo.isAccepted,
        );
      }).toList();
    });
  }

  /// Gets a single conversation by ID.
  Future<DmConversation?> getConversation(String convoId) async {
    final item = await _convosDao.getConvo(convoId);
    if (item == null) return null;

    return DmConversation(
      convoId: item.convo.convoId,
      members: item.members,
      lastMessageText: item.convo.lastMessageText,
      lastMessageAt: item.convo.lastMessageAt,
      lastReadMessageId: item.convo.lastReadMessageId,
      unreadCount: item.convo.unreadCount,
      isMuted: item.convo.isMuted,
      isAccepted: item.convo.isAccepted,
    );
  }

  /// Fetches messages for a conversation from the API and caches them locally.
  ///
  /// [convoId] - Conversation to fetch messages for.
  /// [cursor] - Pagination cursor for fetching older messages.
  /// [limit] - Maximum number of messages to fetch (default 50).
  Future<String?> fetchMessages(String convoId, {String? cursor, int limit = 50}) async {
    _logger.info('Fetching messages', {'convoId': convoId, 'cursor': cursor, 'limit': limit});

    try {
      final params = <String, dynamic>{'convoId': convoId, 'limit': limit.clamp(1, 100)};
      if (cursor != null) {
        params['cursor'] = cursor;
      }

      final response = await _client.call('chat.bsky.convo.getMessages', params: params);

      final messagesList = response['messages'] as List<dynamic>? ?? [];
      final newCursor = response['cursor'] as String?;

      _logger.debug('Received messages', {'count': messagesList.length, 'newCursor': newCursor});

      final messages = <DmMessagesCompanion>[];
      final profiles = <ProfilesCompanion>[];
      final now = DateTime.now();

      for (final item in messagesList) {
        final messageMap = item as Map<String, dynamic>;
        final sender = messageMap['sender'] as Map<String, dynamic>?;
        if (sender == null) continue;

        final senderDid = sender['did'] as String?;
        if (senderDid == null) continue;

        if (sender.containsKey('handle')) {
          profiles.add(
            ProfilesCompanion.insert(
              did: senderDid,
              handle: sender['handle'] as String? ?? 'unknown',
              displayName: Value(sender['displayName'] as String?),
              avatar: Value(sender['avatar'] as String?),
            ),
          );
        }

        final sentAtStr = messageMap['sentAt'] as String?;
        final sentAt = sentAtStr != null ? DateTime.tryParse(sentAtStr) ?? now : now;

        messages.add(
          DmMessagesCompanion.insert(
            messageId: messageMap['id'] as String,
            convoId: convoId,
            senderDid: senderDid,
            content: messageMap['text'] as String? ?? '',
            sentAt: sentAt,
            status: 'sent',
            cachedAt: now,
          ),
        );
      }

      await _messagesDao.insertMessagesBatch(newMessages: messages, newProfiles: profiles);

      _logger.info('Cached messages', {
        'messageCount': messages.length,
        'profileCount': profiles.length,
      });

      return newCursor;
    } catch (error, stack) {
      _logger.error('Failed to fetch messages', error, stack);
      rethrow;
    }
  }

  /// Returns a stream of messages for a conversation from the local cache.
  ///
  /// Messages are joined with sender profiles for complete display data.
  Stream<List<domain.AppDmMessage>> watchMessages(String convoId) {
    return _messagesDao.watchMessagesByConvo(convoId).map((items) {
      return items.map((item) {
        return domain.AppDmMessage(
          messageId: item.message.messageId,
          convoId: item.message.convoId,
          sender: item.sender,
          content: item.message.content,
          sentAt: item.message.sentAt,
          status: domain.MessageStatus.fromString(item.message.status),
        );
      }).toList();
    });
  }

  /// Accepts a conversation request.
  Future<void> acceptConversation(String convoId) async {
    _logger.info('Accepting conversation', {'convoId': convoId});

    try {
      await _client.call('chat.bsky.convo.acceptConvo', body: {'convoId': convoId});

      await _convosDao.acceptConvo(convoId);

      _logger.debug('Successfully accepted conversation', {});
    } catch (error, stack) {
      _logger.error('Failed to accept conversation', error, stack);
      rethrow;
    }
  }

  /// Updates the read state for a conversation.
  Future<void> updateReadState(String convoId, String messageId) async {
    _logger.info('Updating read state', {'convoId': convoId, 'messageId': messageId});

    try {
      await _client.call(
        'chat.bsky.convo.updateRead',
        body: {'convoId': convoId, 'messageId': messageId},
      );

      await _convosDao.updateReadState(
        convoId: convoId,
        lastReadMessageId: messageId,
        unreadCount: 0,
      );

      _logger.debug('Successfully updated read state', {});
    } catch (error, stack) {
      _logger.error('Failed to update read state', error, stack);
      rethrow;
    }
  }

  /// Clears all cached conversations and messages.
  Future<void> clearAll() async {
    await _messagesDao.clearMessages();
    await _convosDao.clearConversations();
  }
}
