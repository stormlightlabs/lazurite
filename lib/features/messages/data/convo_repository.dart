import 'package:atproto_core/atproto_core.dart' show UnauthorizedException;
import 'package:bluesky/bluesky_chat.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:bluesky/chat_bsky_convo_getmessages.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

class ConvoRepository {
  ConvoRepository({
    required BlueskyChat chat,
    Future<AuthTokens?> Function()? onUnauthorized,
    BlueskyChat? Function(AuthTokens tokens)? chatClientFactory,
  }) : _chat = chat,
       _onUnauthorized = onUnauthorized,
       _chatClientFactory = chatClientFactory ?? createBlueSkyChatClient;

  BlueskyChat _chat;
  final Future<AuthTokens?> Function()? _onUnauthorized;
  final BlueskyChat? Function(AuthTokens tokens) _chatClientFactory;

  Future<ConvoListResult> listConvos({String? cursor, int limit = 20}) async {
    final response = await _runWithAuthRecovery(() => _chat.convo.listConvos(cursor: cursor, limit: limit));
    return ConvoListResult(convos: response.data.convos, cursor: response.data.cursor);
  }

  Future<ConvoView> getConvoForMembers(List<String> dids) async {
    final response = await _runWithAuthRecovery(() => _chat.convo.getConvoForMembers(members: dids));
    return response.data.convo;
  }

  Future<MessageListResult> getMessages(String convoId, {String? cursor, int limit = 50}) async {
    final response = await _runWithAuthRecovery(
      () => _chat.convo.getMessages(convoId: convoId, cursor: cursor, limit: limit),
    );
    return MessageListResult(messages: response.data.messages, cursor: response.data.cursor);
  }

  Future<MessageView> sendMessage(String convoId, String text) async {
    final response = await _runWithAuthRecovery(
      () => _chat.convo.sendMessage(
        convoId: convoId,
        message: MessageInput(text: text),
      ),
    );
    return response.data;
  }

  Future<DeletedMessageView> deleteMessageForSelf(String convoId, String messageId) async {
    final response = await _runWithAuthRecovery(
      () => _chat.convo.deleteMessageForSelf(convoId: convoId, messageId: messageId),
    );
    return response.data;
  }

  Future<ConvoView> muteConvo(String convoId) async {
    final response = await _runWithAuthRecovery(() => _chat.convo.muteConvo(convoId: convoId));
    return response.data.convo;
  }

  Future<ConvoView> unmuteConvo(String convoId) async {
    final response = await _runWithAuthRecovery(() => _chat.convo.unmuteConvo(convoId: convoId));
    return response.data.convo;
  }

  Future<void> updateRead(String convoId) async {
    await _runWithAuthRecovery(() => _chat.convo.updateRead(convoId: convoId));
  }

  Future<T> _runWithAuthRecovery<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on UnauthorizedException {
      final recovered = await _recoverAuthSession();
      if (!recovered) {
        rethrow;
      }
      return request();
    }
  }

  Future<bool> _recoverAuthSession() async {
    final callback = _onUnauthorized;
    if (callback == null) {
      return false;
    }

    final refreshedTokens = await callback();
    if (refreshedTokens == null) {
      return false;
    }

    final refreshedClient = _chatClientFactory(refreshedTokens);
    if (refreshedClient == null) {
      return false;
    }

    _chat = refreshedClient;
    return true;
  }
}

class ConvoListResult {
  ConvoListResult({required this.convos, this.cursor});

  final List<ConvoView> convos;
  final String? cursor;
}

class MessageListResult {
  MessageListResult({required this.messages, this.cursor});

  final List<UConvoGetMessagesMessages> messages;
  final String? cursor;
}
