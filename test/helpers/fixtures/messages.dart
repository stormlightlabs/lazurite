const testConvoId = 'convo-test-group';
const testGroupName = 'Release Planning';
const testViewerDid = 'did:plc:viewer';
const testOwnerDid = 'did:plc:owner';
const testMemberDid = 'did:plc:member';
const testJoinLinkCode = 'join-release-planning';

Map<String, Object?> testChatProfileJson({
  String did = testMemberDid,
  String handle = 'member.bsky.social',
  String? displayName = 'Member',
  String? avatar,
  Map<String, Object?> extra = const {},
}) => {
  'did': did,
  'handle': handle,
  ...(displayName == null ? const <String, Object?>{} : {'displayName': displayName}),
  ...(avatar == null ? const <String, Object?>{} : {'avatar': avatar}),
  ...extra,
};

Map<String, Object?> testDirectConvoJson({
  String id = 'convo-direct',
  List<Map<String, Object?>>? members,
  Map<String, Object?> extra = const {},
}) => {
  r'$type': 'chat.bsky.convo.defs#convoView',
  'id': id,
  'rev': 'rev-$id',
  'members':
      members ??
      [
        testChatProfileJson(did: testViewerDid, handle: 'viewer.bsky.social', displayName: 'Viewer'),
        testChatProfileJson(),
      ],
  'muted': false,
  'unreadCount': 0,
  'kind': {r'$type': 'chat.bsky.convo.defs#directConvo'},
  ...extra,
};

Map<String, Object?> testGroupConvoJson({
  String id = testConvoId,
  String name = testGroupName,
  int memberCount = 3,
  bool includeJoinLink = true,
  Map<String, Object?> extra = const {},
}) => {
  r'$type': 'chat.bsky.convo.defs#convoView',
  'id': id,
  'rev': 'rev-$id',
  'members': [
    testChatProfileJson(did: testViewerDid, handle: 'viewer.bsky.social', displayName: 'Viewer'),
    testChatProfileJson(did: testOwnerDid, handle: 'owner.bsky.social', displayName: 'Owner'),
  ],
  'lastMessage': testGroupSystemMessageJson(),
  'muted': false,
  'status': 'accepted',
  'unreadCount': 2,
  'kind': {
    r'$type': 'chat.bsky.convo.defs#groupConvo',
    'name': name,
    'memberCount': memberCount,
    'memberLimit': 50,
    'createdAt': '2026-06-15T14:00:00.000Z',
    'lockStatus': 'unlocked',
    'lockStatusModerationOverride': false,
    'joinRequestCount': 1,
    'unreadJoinRequestCount': 1,
    if (includeJoinLink) 'joinLink': testJoinLinkJson(),
  },
  ...extra,
};

Map<String, Object?> testGroupMemberPageJson({String? cursor = 'next-members', List<Map<String, Object?>>? members}) =>
    {
      ...(cursor == null ? const <String, Object?>{} : {'cursor': cursor}),
      'members':
          members ??
          [
            testChatProfileJson(did: testOwnerDid, handle: 'owner.bsky.social', displayName: 'Owner'),
            testChatProfileJson(),
          ],
    };

Map<String, Object?> testGroupSystemMessageJson({String id = 'system-member-join', String memberDid = testMemberDid}) =>
    {
      r'$type': 'chat.bsky.convo.defs#systemMessageView',
      'id': id,
      'rev': 'rev-$id',
      'sentAt': '2026-06-15T14:05:00.000Z',
      'data': {
        r'$type': 'chat.bsky.convo.defs#systemMessageDataMemberJoin',
        'member': {'did': memberDid},
        'role': 'standard',
        'approvedBy': {'did': testOwnerDid},
      },
    };

Map<String, Object?> testJoinLinkJson({
  String code = testJoinLinkCode,
  bool requireApproval = true,
  String joinRule = 'followedByOwner',
}) => {
  r'$type': 'chat.bsky.group.defs#joinLinkView',
  'code': code,
  'enabledStatus': 'enabled',
  'requireApproval': requireApproval,
  'joinRule': joinRule,
  'createdAt': '2026-06-15T14:01:00.000Z',
};

Map<String, Object?> testJoinRequestJson({String convoId = testConvoId, String requestedByDid = testMemberDid}) => {
  r'$type': 'chat.bsky.group.defs#joinRequestView',
  'convoId': convoId,
  'requestedBy': testChatProfileJson(did: requestedByDid),
  'requestedAt': '2026-06-15T14:10:00.000Z',
};
