part of '../poptart_client_adapter.dart';

class BlueskyConvoService {
  BlueskyConvoService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<ConvoListConvosOutput>> listConvos({int limit = 50, String? cursor}) {
    return _client.call(
      chatBskyConvoListConvos,
      parameters: ConvoListConvosInput(limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<ConvoGetConvoForMembersOutput>> getConvoForMembers({required List<String> members}) {
    return _client.call(chatBskyConvoGetConvoForMembers, parameters: ConvoGetConvoForMembersInput(members: members));
  }

  Future<XRPCResponse<ConvoGetMessagesOutput>> getMessages({required String convoId, int limit = 50, String? cursor}) {
    return _client.call(
      chatBskyConvoGetMessages,
      parameters: ConvoGetMessagesInput(convoId: convoId, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<MessageView>> sendMessage({required String convoId, required MessageInput message}) {
    return _client.call(
      chatBskyConvoSendMessage,
      input: ConvoSendMessageInput(convoId: convoId, message: message),
    );
  }

  Future<XRPCResponse<DeletedMessageView>> deleteMessageForSelf({required String convoId, required String messageId}) {
    return _client.call(
      chatBskyConvoDeleteMessageForSelf,
      input: ConvoDeleteMessageForSelfInput(convoId: convoId, messageId: messageId),
    );
  }

  Future<XRPCResponse<ConvoMuteConvoOutput>> muteConvo({required String convoId}) {
    return _client.call(chatBskyConvoMuteConvo, input: ConvoMuteConvoInput(convoId: convoId));
  }

  Future<XRPCResponse<ConvoUnmuteConvoOutput>> unmuteConvo({required String convoId}) {
    return _client.call(chatBskyConvoUnmuteConvo, input: ConvoUnmuteConvoInput(convoId: convoId));
  }

  Future<XRPCResponse<ConvoUpdateReadOutput>> updateRead({required String convoId, String? messageId}) {
    return _client.call(
      chatBskyConvoUpdateRead,
      input: ConvoUpdateReadInput(convoId: convoId, messageId: messageId),
    );
  }
}
