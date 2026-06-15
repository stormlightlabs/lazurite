import 'dart:collection';
import 'dart:convert';

import 'package:poptart_core/poptart_core.dart' as atcore;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/request_join.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';

import '../../../helpers/fixtures/messages.dart';

void main() {
  group('ConvoListResult', () {
    test('stores convos and cursor', () {
      final convo = _makeConvoView('c1');
      final result = ConvoListResult(convos: [convo], cursor: 'cursor-1');

      expect(result.convos.length, 1);
      expect(result.convos.first.id, 'c1');
      expect(result.cursor, 'cursor-1');
    });

    test('cursor is nullable', () {
      final result = ConvoListResult(convos: []);
      expect(result.cursor, isNull);
    });
  });

  group('MessageListResult', () {
    test('stores messages and cursor', () {
      final result = MessageListResult(messages: [], cursor: 'cursor-1');

      expect(result.messages, isEmpty);
      expect(result.cursor, 'cursor-1');
    });

    test('cursor is nullable', () {
      final result = MessageListResult(messages: []);
      expect(result.cursor, isNull);
    });
  });

  group('ConvoMembersResult', () {
    test('stores members and cursor', () {
      final member = ProfileViewBasic.fromJson(testChatProfileJson());
      final result = ConvoMembersResult(members: [member], cursor: 'cursor-1');

      expect(result.members.single.did, testMemberDid);
      expect(result.cursor, 'cursor-1');
    });

    test('cursor is nullable', () {
      final result = ConvoMembersResult(members: []);
      expect(result.cursor, isNull);
    });
  });

  group('JoinRequestsResult', () {
    test('stores requests and cursor', () {
      final request = JoinRequestView.fromJson(testJoinRequestJson());
      final result = JoinRequestsResult(requests: [request], cursor: 'cursor-1');

      expect(result.requests.single.convoId, testConvoId);
      expect(result.cursor, 'cursor-1');
    });

    test('cursor is nullable', () {
      final result = JoinRequestsResult(requests: []);
      expect(result.cursor, isNull);
    });
  });

  group('ConvoRepository group methods', () {
    test('createGroup returns created conversation', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'convo': testGroupConvoJson(id: 'created-group')}),
          ],
        ).createChat(),
      );

      final convo = await repository.createGroup(name: testGroupName, memberDids: [testMemberDid]);

      expect(convo.id, 'created-group');
    });

    test('getConvoMembers returns paginated members', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(getReplies: [_okReply(testGroupMemberPageJson(cursor: 'next-members'))]).createChat(),
      );

      final result = await repository.getConvoMembers(testConvoId);

      expect(result.members.map((member) => member.did), containsAll([testOwnerDid, testMemberDid]));
      expect(result.cursor, 'next-members');
    });

    test('addGroupMembers returns updated conversation', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({
              'convo': testGroupConvoJson(memberCount: 4),
              'addedMembers': [testChatProfileJson()],
            }),
          ],
        ).createChat(),
      );

      final convo = await repository.addGroupMembers(testConvoId, [testMemberDid]);

      expect(convo.id, testConvoId);
    });

    test('removeGroupMembers returns updated conversation', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'convo': testGroupConvoJson(memberCount: 2)}),
          ],
        ).createChat(),
      );

      final convo = await repository.removeGroupMembers(testConvoId, [testMemberDid]);

      expect(convo.id, testConvoId);
    });

    test('editGroupName returns renamed conversation', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'convo': testGroupConvoJson(name: 'Renamed Group')}),
          ],
        ).createChat(),
      );

      final convo = await repository.editGroupName(testConvoId, 'Renamed Group');

      final kind = convo.kind;
      expect(kind?.isGroupConvo, isTrue);
      expect(kind?.groupConvo?.name, 'Renamed Group');
    });

    test('createJoinLink returns join link', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'joinLink': testJoinLinkJson(code: 'created-link')}),
          ],
        ).createChat(),
      );

      final link = await repository.createJoinLink(
        convoId: testConvoId,
        joinRule: const JoinRule.knownValue(data: KnownJoinRule.followedByOwner),
        requireApproval: true,
      );

      expect(link.code, 'created-link');
    });

    test('editJoinLink returns edited join link', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'joinLink': testJoinLinkJson(requireApproval: false, joinRule: 'anyone')}),
          ],
        ).createChat(),
      );

      final link = await repository.editJoinLink(
        convoId: testConvoId,
        joinRule: const JoinRule.knownValue(data: KnownJoinRule.anyone),
        requireApproval: false,
      );

      expect(link.requireApproval, isFalse);
      expect(link.joinRule.knownValue, KnownJoinRule.anyone);
    });

    test('enableJoinLink returns enabled join link', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'joinLink': testJoinLinkJson()}),
          ],
        ).createChat(),
      );

      final link = await repository.enableJoinLink(testConvoId);

      expect(link.code, testJoinLinkCode);
    });

    test('disableJoinLink returns disabled join link', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'joinLink': testJoinLinkJson()}),
          ],
        ).createChat(),
      );

      final link = await repository.disableJoinLink(testConvoId);

      expect(link.code, testJoinLinkCode);
    });

    test('previewJoinLink returns join link preview', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          getReplies: [
            _okReply({
              'joinLinkPreview': {
                r'$type': 'chat.bsky.group.defs#joinLinkPreviewView',
                'name': testGroupName,
                'owner': testChatProfileJson(did: testOwnerDid),
                'memberCount': 3,
                'requireApproval': true,
                'convo': testGroupConvoJson(),
              },
            }),
          ],
        ).createChat(),
      );

      final preview = await repository.previewJoinLink(testJoinLinkCode);

      expect(preview.name, testGroupName);
      expect(preview.convo?.id, testConvoId);
    });

    test('requestJoin returns join status and conversation when joined', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'status': 'joined', 'convo': testGroupConvoJson()}),
          ],
        ).createChat(),
      );

      final result = await repository.requestJoin(testJoinLinkCode);

      expect(result.status.knownValue, KnownGroupRequestJoinStatus.joined);
      expect(result.convo?.id, testConvoId);
    });

    test('listJoinRequests returns paginated requests', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          getReplies: [
            _okReply({
              'requests': [testJoinRequestJson()],
              'cursor': 'next-requests',
            }),
          ],
        ).createChat(),
      );

      final result = await repository.listJoinRequests(testConvoId);

      expect(result.requests.single.requestedBy.did, testMemberDid);
      expect(result.cursor, 'next-requests');
    });

    test('approveJoinRequest returns updated conversation', () async {
      final repository = ConvoRepository(
        chat: _ScriptedTransport(
          postReplies: [
            _okReply({'convo': testGroupConvoJson()}),
          ],
        ).createChat(),
      );

      final convo = await repository.approveJoinRequest(testConvoId, testMemberDid);

      expect(convo.id, testConvoId);
    });

    test('rejectJoinRequest completes on empty response', () async {
      final transport = _ScriptedTransport(postReplies: [_okReply({})]);
      final repository = ConvoRepository(chat: transport.createChat());

      await repository.rejectJoinRequest(testConvoId, testMemberDid);

      expect(transport.postCalls, 1);
    });

    for (final scenario in _groupApiErrorScenarios()) {
      test('${scenario.name} rethrows API errors', () async {
        final repository = ConvoRepository(
          chat: _ScriptedTransport(
            getReplies: scenario.usesGet ? [_apiErrorReply()] : const [],
            postReplies: scenario.usesGet ? const [] : [_apiErrorReply()],
          ).createChat(),
        );

        await expectLater(scenario.call(repository), throwsA(isA<atcore.XRPCException>()));
      });
    }
  });

  group('ConvoRepository auth recovery', () {
    test('listConvos sends requests through the Bluesky chat proxy service', () async {
      final transport = _ScriptedTransport(
        getReplies: [
          _okReply({'convos': const []}),
        ],
      );
      final repository = ConvoRepository(chat: transport.createChat());

      await repository.listConvos();

      expect(transport.lastGetHeaders?['atproto-proxy'], 'did:web:api.bsky.chat#bsky_chat');
    });

    test('sendMessage sends requests through the Bluesky chat proxy service', () async {
      final transport = _ScriptedTransport(postReplies: [_okReply(_messageJson('msg-1'))]);
      final repository = ConvoRepository(chat: transport.createChat());

      await repository.sendMessage('c1', 'Hello');

      expect(transport.lastPostHeaders?['atproto-proxy'], 'did:web:api.bsky.chat#bsky_chat');
    });

    test('listConvos retries once after unauthorized and succeeds with refreshed client', () async {
      final primary = _ScriptedTransport(getReplies: [_unauthorizedReply()]);
      final fallback = _ScriptedTransport(
        getReplies: [
          _okReply({
            'convos': [_convoJson('c1')],
            'cursor': 'next-cursor',
          }),
        ],
      );

      var recoveryCalls = 0;
      var factoryCalls = 0;
      final repository = ConvoRepository(
        chat: primary.createChat(),
        onUnauthorized: () async {
          recoveryCalls += 1;
          return _freshTokens();
        },
        chatClientFactory: (_) {
          factoryCalls += 1;
          return fallback.createChat();
        },
      );

      final result = await repository.listConvos();

      expect(recoveryCalls, 1);
      expect(factoryCalls, 1);
      expect(primary.getCalls, 1);
      expect(fallback.getCalls, 1);
      expect(result.cursor, 'next-cursor');
      expect(result.convos.length, 1);
      expect(result.convos.first.id, 'c1');
    });

    test('listConvos rethrows unauthorized when recovery returns null tokens', () async {
      final primary = _ScriptedTransport(getReplies: [_unauthorizedReply()]);
      var recoveryCalls = 0;
      final repository = ConvoRepository(
        chat: primary.createChat(),
        onUnauthorized: () async {
          recoveryCalls += 1;
          return null;
        },
      );

      await expectLater(repository.listConvos(), throwsA(isA<atcore.UnauthorizedException>()));
      expect(recoveryCalls, 1);
      expect(primary.getCalls, 1);
    });

    test('updateRead retries post request after unauthorized and succeeds', () async {
      final primary = _ScriptedTransport(postReplies: [_unauthorizedReply()]);
      final fallback = _ScriptedTransport(
        postReplies: [
          _okReply({'convo': _convoJson('c1')}),
        ],
      );

      var recoveryCalls = 0;
      final repository = ConvoRepository(
        chat: primary.createChat(),
        onUnauthorized: () async {
          recoveryCalls += 1;
          return _freshTokens();
        },
        chatClientFactory: (_) => fallback.createChat(),
      );

      await repository.updateRead('c1');

      expect(recoveryCalls, 1);
      expect(primary.postCalls, 1);
      expect(fallback.postCalls, 1);
    });
  });
}

List<_RepositoryScenario> _groupApiErrorScenarios() {
  return [
    _RepositoryScenario(
      name: 'createGroup',
      usesGet: false,
      call: (repository) => repository.createGroup(name: testGroupName, memberDids: [testMemberDid]),
    ),
    _RepositoryScenario(
      name: 'getConvoMembers',
      usesGet: true,
      call: (repository) => repository.getConvoMembers(testConvoId),
    ),
    _RepositoryScenario(
      name: 'addGroupMembers',
      usesGet: false,
      call: (repository) => repository.addGroupMembers(testConvoId, [testMemberDid]),
    ),
    _RepositoryScenario(
      name: 'removeGroupMembers',
      usesGet: false,
      call: (repository) => repository.removeGroupMembers(testConvoId, [testMemberDid]),
    ),
    _RepositoryScenario(
      name: 'editGroupName',
      usesGet: false,
      call: (repository) => repository.editGroupName(testConvoId, testGroupName),
    ),
    _RepositoryScenario(
      name: 'createJoinLink',
      usesGet: false,
      call: (repository) => repository.createJoinLink(
        convoId: testConvoId,
        joinRule: const JoinRule.knownValue(data: KnownJoinRule.followedByOwner),
      ),
    ),
    _RepositoryScenario(
      name: 'editJoinLink',
      usesGet: false,
      call: (repository) => repository.editJoinLink(convoId: testConvoId, requireApproval: false),
    ),
    _RepositoryScenario(
      name: 'enableJoinLink',
      usesGet: false,
      call: (repository) => repository.enableJoinLink(testConvoId),
    ),
    _RepositoryScenario(
      name: 'disableJoinLink',
      usesGet: false,
      call: (repository) => repository.disableJoinLink(testConvoId),
    ),
    _RepositoryScenario(
      name: 'previewJoinLink',
      usesGet: true,
      call: (repository) => repository.previewJoinLink(testJoinLinkCode),
    ),
    _RepositoryScenario(
      name: 'requestJoin',
      usesGet: false,
      call: (repository) => repository.requestJoin(testJoinLinkCode),
    ),
    _RepositoryScenario(
      name: 'listJoinRequests',
      usesGet: true,
      call: (repository) => repository.listJoinRequests(testConvoId),
    ),
    _RepositoryScenario(
      name: 'approveJoinRequest',
      usesGet: false,
      call: (repository) => repository.approveJoinRequest(testConvoId, testMemberDid),
    ),
    _RepositoryScenario(
      name: 'rejectJoinRequest',
      usesGet: false,
      call: (repository) => repository.rejectJoinRequest(testConvoId, testMemberDid),
    ),
  ];
}

class _RepositoryScenario {
  const _RepositoryScenario({required this.name, required this.usesGet, required this.call});

  final String name;
  final bool usesGet;
  final Future<Object?> Function(ConvoRepository repository) call;
}

class _ScriptedTransport {
  _ScriptedTransport({List<_ScriptedReply>? getReplies, List<_ScriptedReply>? postReplies})
    : _getReplies = Queue<_ScriptedReply>.from(getReplies ?? const []),
      _postReplies = Queue<_ScriptedReply>.from(postReplies ?? const []);

  final Queue<_ScriptedReply> _getReplies;
  final Queue<_ScriptedReply> _postReplies;

  int getCalls = 0;
  int postCalls = 0;
  Map<String, String>? lastGetHeaders;
  Map<String, String>? lastPostHeaders;

  BlueskyChat createChat() {
    return BlueskyChat.fromSession(
      const atcore.Session(
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        accessJwt: 'access-token',
        refreshJwt: 'refresh-token',
      ),
      getClient: (uri, {headers}) async {
        getCalls += 1;
        lastGetHeaders = headers;
        if (_getReplies.isEmpty) {
          throw StateError('No scripted GET response queued for $uri');
        }
        return _getReplies.removeFirst().toResponse(method: 'GET', url: uri);
      },
      postClient: (uri, {headers, body, encoding}) async {
        postCalls += 1;
        lastPostHeaders = headers;
        if (_postReplies.isEmpty) {
          throw StateError('No scripted POST response queued for $uri');
        }
        return _postReplies.removeFirst().toResponse(method: 'POST', url: uri);
      },
    );
  }
}

Map<String, Object?> _convoJson(String id) {
  return {'id': id, 'rev': 'rev-$id', 'members': const [], 'muted': false, 'unreadCount': 0};
}

Map<String, Object?> _messageJson(String id) {
  return {
    'id': id,
    'rev': 'rev-$id',
    'text': 'Hello',
    'sender': {'did': 'did:plc:test'},
    'sentAt': DateTime.utc(2026, 1, 1).toIso8601String(),
  };
}

class _ScriptedReply {
  const _ScriptedReply({required this.statusCode, required this.payload});

  final int statusCode;
  final Map<String, Object?> payload;

  Future<http.Response> toResponse({required String method, required Uri url}) async {
    final streamed = http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(jsonEncode(payload))),
      statusCode,
      request: http.Request(method, url),
      headers: const {'content-type': 'application/json'},
    );
    return http.Response.fromStream(streamed);
  }
}

_ScriptedReply _okReply(Map<String, Object?> payload) {
  return _ScriptedReply(statusCode: 200, payload: payload);
}

_ScriptedReply _unauthorizedReply() {
  return const _ScriptedReply(
    statusCode: 401,
    payload: {'error': 'Unauthorized', 'message': 'exp claim timestamp check failed'},
  );
}

_ScriptedReply _apiErrorReply() {
  return const _ScriptedReply(statusCode: 400, payload: {'error': 'InvalidConvo', 'message': 'Invalid conversation'});
}

ConvoView _makeConvoView(String id) => ConvoView(id: id, rev: 'rev-1', members: [], muted: false, unreadCount: 0);

AuthTokens _freshTokens() {
  final now = DateTime.now().toUtc();
  return AuthTokens(
    accessToken: 'fresh-access-token',
    refreshToken: 'fresh-refresh-token',
    expiresAt: now.add(const Duration(hours: 1)),
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    service: 'bsky.social',
  );
}
