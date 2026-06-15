import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/get_messages.dart';
import 'package:bluesky_poptart/chat/bsky/group/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/request_join.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

class ConvoRepository {
  ConvoRepository({
    required BlueskyChat chat,
    Future<AuthTokens?> Function()? onUnauthorized,
    BlueskyChat? Function(AuthTokens tokens)? chatClientFactory,
  }) {
    _authRecovery = UnauthorizedRecoveryRunner<BlueskyChat>(
      initialClient: chat,
      onUnauthorized: onUnauthorized,
      clientFactory: chatClientFactory ?? createBlueSkyChatClient,
    );
  }

  late final UnauthorizedRecoveryRunner<BlueskyChat> _authRecovery;

  Future<ConvoListResult> listConvos({String? cursor, int limit = 20}) async {
    final response = await _authRecovery.run((client) => client.convo.listConvos(cursor: cursor, limit: limit));
    return ConvoListResult(convos: response.data.convos, cursor: response.data.cursor);
  }

  Future<ConvoView> getConvoForMembers(List<String> dids) async {
    final response = await _authRecovery.run((client) => client.convo.getConvoForMembers(members: dids));
    return response.data.convo;
  }

  Future<ConvoView> getConvo(String convoId) async {
    final response = await _authRecovery.run((client) => client.convo.getConvo(convoId: convoId));
    return response.data.convo;
  }

  Future<ConvoView> createGroup({required String name, required List<String> memberDids}) async {
    final response = await _authRecovery.run((client) => client.group.createGroup(name: name, members: memberDids));
    return response.data.convo;
  }

  Future<ConvoMembersResult> getConvoMembers(String convoId, {String? cursor, int limit = 50}) async {
    final response = await _authRecovery.run(
      (client) => client.convo.getConvoMembers(convoId: convoId, cursor: cursor, limit: limit),
    );
    return ConvoMembersResult(members: response.data.members, cursor: response.data.cursor);
  }

  Future<ConvoView> addGroupMembers(String convoId, List<String> memberDids) async {
    final response = await _authRecovery.run(
      (client) => client.group.addMembers(convoId: convoId, members: memberDids),
    );
    return response.data.convo;
  }

  Future<ConvoView> removeGroupMembers(String convoId, List<String> memberDids) async {
    final response = await _authRecovery.run(
      (client) => client.group.removeMembers(convoId: convoId, members: memberDids),
    );
    return response.data.convo;
  }

  Future<ConvoView> editGroupName(String convoId, String name) async {
    final response = await _authRecovery.run((client) => client.group.editGroup(convoId: convoId, name: name));
    return response.data.convo;
  }

  Future<JoinLinkView> createJoinLink({
    required String convoId,
    required JoinRule joinRule,
    bool requireApproval = false,
  }) async {
    final response = await _authRecovery.run(
      (client) => client.group.createJoinLink(convoId: convoId, joinRule: joinRule, requireApproval: requireApproval),
    );
    return response.data.joinLink;
  }

  Future<JoinLinkView> editJoinLink({required String convoId, bool? requireApproval, JoinRule? joinRule}) async {
    final response = await _authRecovery.run(
      (client) => client.group.editJoinLink(convoId: convoId, requireApproval: requireApproval, joinRule: joinRule),
    );
    return response.data.joinLink;
  }

  Future<JoinLinkView> enableJoinLink(String convoId) async {
    final response = await _authRecovery.run((client) => client.group.enableJoinLink(convoId: convoId));
    return response.data.joinLink;
  }

  Future<JoinLinkView> disableJoinLink(String convoId) async {
    final response = await _authRecovery.run((client) => client.group.disableJoinLink(convoId: convoId));
    return response.data.joinLink;
  }

  Future<JoinLinkPreviewView> previewJoinLink(String code) async {
    final response = await _authRecovery.run((client) => client.group.getJoinLinkPreview(code: code));
    return response.data.joinLinkPreview;
  }

  Future<GroupRequestJoinOutput> requestJoin(String code) async {
    final response = await _authRecovery.run((client) => client.group.requestJoin(code: code));
    return response.data;
  }

  Future<JoinRequestsResult> listJoinRequests(String convoId, {String? cursor, int limit = 50}) async {
    final response = await _authRecovery.run(
      (client) => client.group.listJoinRequests(convoId: convoId, cursor: cursor, limit: limit),
    );
    return JoinRequestsResult(requests: response.data.requests, cursor: response.data.cursor);
  }

  Future<ConvoView> approveJoinRequest(String convoId, String memberDid) async {
    final response = await _authRecovery.run(
      (client) => client.group.approveJoinRequest(convoId: convoId, member: memberDid),
    );
    return response.data.convo;
  }

  Future<void> rejectJoinRequest(String convoId, String memberDid) async {
    await _authRecovery.run((client) => client.group.rejectJoinRequest(convoId: convoId, member: memberDid));
  }

  Future<MessageListResult> getMessages(String convoId, {String? cursor, int limit = 50}) async {
    final response = await _authRecovery.run(
      (client) => client.convo.getMessages(convoId: convoId, cursor: cursor, limit: limit),
    );
    return MessageListResult(messages: response.data.messages, cursor: response.data.cursor);
  }

  Future<MessageView> sendMessage(String convoId, String text) async {
    final response = await _authRecovery.run(
      (client) => client.convo.sendMessage(
        convoId: convoId,
        message: MessageInput(text: text),
      ),
    );
    return response.data;
  }

  Future<DeletedMessageView> deleteMessageForSelf(String convoId, String messageId) async {
    final response = await _authRecovery.run(
      (client) => client.convo.deleteMessageForSelf(convoId: convoId, messageId: messageId),
    );
    return response.data;
  }

  Future<ConvoView> muteConvo(String convoId) async {
    final response = await _authRecovery.run((client) => client.convo.muteConvo(convoId: convoId));
    return response.data.convo;
  }

  Future<ConvoView> unmuteConvo(String convoId) async {
    final response = await _authRecovery.run((client) => client.convo.unmuteConvo(convoId: convoId));
    return response.data.convo;
  }

  Future<void> updateRead(String convoId) async {
    await _authRecovery.run((client) => client.convo.updateRead(convoId: convoId));
  }

  Future<void> leaveConvo(String convoId) async {
    await _authRecovery.run((client) => client.convo.leaveConvo(convoId: convoId));
  }
}

class ConvoListResult {
  ConvoListResult({required this.convos, this.cursor});

  final List<ConvoView> convos;
  final String? cursor;
}

class ConvoMembersResult {
  ConvoMembersResult({required this.members, this.cursor});

  final List<ProfileViewBasic> members;
  final String? cursor;
}

class JoinRequestsResult {
  JoinRequestsResult({required this.requests, this.cursor});

  final List<JoinRequestView> requests;
  final String? cursor;
}

class MessageListResult {
  MessageListResult({required this.messages, this.cursor});

  final List<UConvoGetMessagesMessages> messages;
  final String? cursor;
}
