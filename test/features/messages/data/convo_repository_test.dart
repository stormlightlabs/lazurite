import 'dart:collection';
import 'dart:convert';

import 'package:poptart_core/poptart_core.dart' as atcore;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:poptart_lex/chat/bsky/convo/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';

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

  group('ConvoRepository auth recovery', () {
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

class _ScriptedTransport {
  _ScriptedTransport({List<_ScriptedReply>? getReplies, List<_ScriptedReply>? postReplies})
    : _getReplies = Queue<_ScriptedReply>.from(getReplies ?? const []),
      _postReplies = Queue<_ScriptedReply>.from(postReplies ?? const []);

  final Queue<_ScriptedReply> _getReplies;
  final Queue<_ScriptedReply> _postReplies;

  int getCalls = 0;
  int postCalls = 0;

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
        if (_getReplies.isEmpty) {
          throw StateError('No scripted GET response queued for $uri');
        }
        return _getReplies.removeFirst().toResponse(method: 'GET', url: uri);
      },
      postClient: (uri, {headers, body, encoding}) async {
        postCalls += 1;
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
