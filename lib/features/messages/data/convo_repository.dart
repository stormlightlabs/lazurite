import 'package:bluesky/bluesky_chat.dart';
import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:bluesky/chat_bsky_convo_getmessages.dart';

class ConvoRepository {
  ConvoRepository({required BlueskyChat chat}) : _chat = chat;

  final BlueskyChat _chat;

  Future<ConvoListResult> listConvos({String? cursor, int limit = 20}) async {
    final response = await _chat.convo.listConvos(cursor: cursor, limit: limit);
    return ConvoListResult(convos: response.data.convos, cursor: response.data.cursor);
  }

  Future<ConvoView> getConvoForMembers(List<String> dids) async {
    final response = await _chat.convo.getConvoForMembers(members: dids);
    return response.data.convo;
  }

  Future<MessageListResult> getMessages(String convoId, {String? cursor, int limit = 50}) async {
    final response = await _chat.convo.getMessages(convoId: convoId, cursor: cursor, limit: limit);
    return MessageListResult(messages: response.data.messages, cursor: response.data.cursor);
  }

  Future<MessageView> sendMessage(String convoId, String text) async {
    final response = await _chat.convo.sendMessage(
      convoId: convoId,
      message: MessageInput(text: text),
    );
    return response.data;
  }

  Future<DeletedMessageView> deleteMessageForSelf(String convoId, String messageId) async {
    final response = await _chat.convo.deleteMessageForSelf(convoId: convoId, messageId: messageId);
    return response.data;
  }

  Future<ConvoView> muteConvo(String convoId) async {
    final response = await _chat.convo.muteConvo(convoId: convoId);
    return response.data.convo;
  }

  Future<ConvoView> unmuteConvo(String convoId) async {
    final response = await _chat.convo.unmuteConvo(convoId: convoId);
    return response.data.convo;
  }

  Future<void> updateRead(String convoId) async {
    await _chat.convo.updateRead(convoId: convoId);
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
