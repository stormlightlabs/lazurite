import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';

void main() {
  group('Bluesky poptart adapter', () {
    test('feed.like.create encodes createRecord input through descriptor type conversion', () async {
      Object? capturedBody;
      final bluesky = Bluesky.fromSession(
        const Session(did: 'did:plc:test', handle: 'test.bsky.social', accessJwt: 'access', refreshJwt: 'refresh'),
        service: 'example.com',
        postClient: (url, {headers, body, encoding}) async {
          capturedBody = body;
          return http.Response(
            '{"uri":"at://did:plc:test/app.bsky.feed.like/like1","cid":"like-cid"}',
            200,
            request: http.Request('POST', url),
          );
        },
      );

      final response = await bluesky.feed.like.create(
        subject: RepoStrongRef(cid: 'post-cid', uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/post1')),
        createdAt: DateTime.utc(2026, 5, 10, 15, 8, 56),
      );

      expect(response.data.uri.toString(), 'at://did:plc:test/app.bsky.feed.like/like1');
      final body = jsonDecode(capturedBody! as String) as Map<String, dynamic>;
      expect(body['repo'], 'did:plc:test');
      expect(body['collection'], 'app.bsky.feed.like');
      expect(body['record'], {
        r'$type': 'app.bsky.feed.like',
        'subject': {
          r'$type': 'com.atproto.repo.strongRef',
          'uri': 'at://did:plc:author/app.bsky.feed.post/post1',
          'cid': 'post-cid',
        },
        'createdAt': '2026-05-10T15:08:56.000Z',
      });
    });
  });
}
