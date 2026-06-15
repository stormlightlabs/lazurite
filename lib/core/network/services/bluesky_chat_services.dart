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

  Future<XRPCResponse<ConvoGetConvoMembersOutput>> getConvoMembers({
    required String convoId,
    int limit = 50,
    String? cursor,
  }) => _client.call(
    chatBskyConvoGetConvoMembers,
    parameters: ConvoGetConvoMembersInput(convoId: convoId, limit: limit, cursor: cursor),
  );

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

class BlueskyGroupService {
  BlueskyGroupService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<GroupCreateGroupOutput>> createGroup({required String name, required List<String> members}) {
    return _client.call(
      chatBskyGroupCreateGroup,
      input: GroupCreateGroupInput(name: name, members: members),
    );
  }

  Future<XRPCResponse<GroupAddMembersOutput>> addMembers({required String convoId, required List<String> members}) {
    return _client.call(
      chatBskyGroupAddMembers,
      input: GroupAddMembersInput(convoId: convoId, members: members),
    );
  }

  Future<XRPCResponse<GroupRemoveMembersOutput>> removeMembers({
    required String convoId,
    required List<String> members,
  }) => _client.call(
    chatBskyGroupRemoveMembers,
    input: GroupRemoveMembersInput(convoId: convoId, members: members),
  );

  Future<XRPCResponse<GroupEditGroupOutput>> editGroup({required String convoId, required String name}) {
    return _client.call(
      chatBskyGroupEditGroup,
      input: GroupEditGroupInput(convoId: convoId, name: name),
    );
  }

  Future<XRPCResponse<GroupCreateJoinLinkOutput>> createJoinLink({
    required String convoId,
    required JoinRule joinRule,
    bool requireApproval = false,
  }) => _client.call(
    chatBskyGroupCreateJoinLink,
    input: GroupCreateJoinLinkInput(convoId: convoId, joinRule: joinRule, requireApproval: requireApproval),
  );

  Future<XRPCResponse<GroupEditJoinLinkOutput>> editJoinLink({
    required String convoId,
    bool? requireApproval,
    JoinRule? joinRule,
  }) => _client.call(
    chatBskyGroupEditJoinLink,
    input: GroupEditJoinLinkInput(convoId: convoId, requireApproval: requireApproval, joinRule: joinRule),
  );

  Future<XRPCResponse<GroupEnableJoinLinkOutput>> enableJoinLink({required String convoId}) {
    return _client.call(chatBskyGroupEnableJoinLink, input: GroupEnableJoinLinkInput(convoId: convoId));
  }

  Future<XRPCResponse<GroupDisableJoinLinkOutput>> disableJoinLink({required String convoId}) {
    return _client.call(chatBskyGroupDisableJoinLink, input: GroupDisableJoinLinkInput(convoId: convoId));
  }

  Future<XRPCResponse<GroupGetJoinLinkPreviewOutput>> getJoinLinkPreview({required String code}) {
    return _client.call(chatBskyGroupGetJoinLinkPreview, parameters: GroupGetJoinLinkPreviewInput(code: code));
  }

  Future<XRPCResponse<GroupRequestJoinOutput>> requestJoin({required String code}) {
    return _client.call(chatBskyGroupRequestJoin, input: GroupRequestJoinInput(code: code));
  }

  Future<XRPCResponse<GroupListJoinRequestsOutput>> listJoinRequests({
    required String convoId,
    int limit = 50,
    String? cursor,
  }) => _client.call(
    chatBskyGroupListJoinRequests,
    parameters: GroupListJoinRequestsInput(convoId: convoId, limit: limit, cursor: cursor),
  );

  Future<XRPCResponse<GroupApproveJoinRequestOutput>> approveJoinRequest({
    required String convoId,
    required String member,
  }) => _client.call(
    chatBskyGroupApproveJoinRequest,
    input: GroupApproveJoinRequestInput(convoId: convoId, member: member),
  );

  Future<XRPCResponse<EmptyData>> rejectJoinRequest({required String convoId, required String member}) {
    return _client.call(
      chatBskyGroupRejectJoinRequest,
      input: GroupRejectJoinRequestInput(convoId: convoId, member: member),
    );
  }
}
