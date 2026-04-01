import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lazurite/core/network/constellation_client.dart';

void main() {
  group('ConstellationClient', () {
    group('URL construction', () {
      test('uses default base URL when none provided', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0}), 200);
          }),
        );

        await client.getBacklinksCount('did:plc:test', 'app.bsky.graph.block:subject');

        expect(capturedUri?.host, 'constellation.microcosm.blue');
        expect(capturedUri?.scheme, 'https');
      });

      test('uses custom base URL when provided', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          baseUrl: 'https://my.instance.example',
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0}), 200);
          }),
        );

        await client.getBacklinksCount('did:plc:test', 'app.bsky.graph.block:subject');

        expect(capturedUri?.host, 'my.instance.example');
      });

      test('trims trailing slashes from custom base URL', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          baseUrl: 'https://my.instance.example///',
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0}), 200);
          }),
        );

        await client.getBacklinksCount('did:plc:test', 'app.bsky.graph.block:subject');

        expect(
          capturedUri.toString(),
          'https://my.instance.example/xrpc/blue.microcosm.links.getBacklinksCount?subject=did%3Aplc%3Atest&source=app.bsky.graph.block%3Asubject',
        );
      });

      test('builds XRPC path correctly', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0}), 200);
          }),
        );

        await client.getBacklinksCount('did:plc:test', 'app.bsky.graph.block:subject');

        expect(capturedUri?.path, '/xrpc/blue.microcosm.links.getBacklinksCount');
      });

      test('sends User-Agent: lazurite header', () async {
        Map<String, String>? capturedHeaders;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedHeaders = request.headers;
            return http.Response(jsonEncode({'total': 0}), 200);
          }),
        );

        await client.getBacklinksCount('did:plc:test', 'app.bsky.graph.block:subject');

        expect(capturedHeaders?['User-Agent'], 'lazurite');
      });
    });

    group('getBacklinksCount', () {
      test('returns total from response', () async {
        final client = ConstellationClient(
          httpClient: MockClient((_) async => http.Response(jsonEncode({'total': 42}), 200)),
        );

        final result = await client.getBacklinksCount('did:plc:abc', 'app.bsky.graph.block:subject');

        expect(result, 42);
      });

      test('encodes subject and source as query parameters', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0}), 200);
          }),
        );

        await client.getBacklinksCount('did:plc:abc123', 'app.bsky.graph.block:subject');

        expect(capturedUri?.queryParameters['subject'], 'did:plc:abc123');
        expect(capturedUri?.queryParameters['source'], 'app.bsky.graph.block:subject');
      });

      test('throws ConstellationException on non-200 response', () async {
        final client = ConstellationClient(
          httpClient: MockClient((_) async => http.Response('Internal Server Error', 500)),
        );

        expect(() => client.getBacklinksCount('did:plc:abc', 'source'), throwsA(isA<ConstellationException>()));
      });

      test('throws on timeout', () async {
        final client = ConstellationClient(
          httpClient: MockClient((_) async {
            await Future<void>.delayed(const Duration(seconds: 15));
            return http.Response('', 200);
          }),
        );

        expect(() => client.getBacklinksCount('did:plc:abc', 'source'), throwsA(isA<TimeoutException>()));
      }, timeout: const Timeout(Duration(seconds: 20)));
    });

    group('getDistinct', () {
      test('returns total, dids and cursor from response', () async {
        final responseBody = jsonEncode({
          'total': 3,
          'dids': ['did:plc:aaa', 'did:plc:bbb', 'did:plc:ccc'],
          'cursor': 'next-cursor',
        });
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getDistinct('did:plc:abc', 'app.bsky.graph.block:subject');

        expect(result.total, 3);
        expect(result.dids, ['did:plc:aaa', 'did:plc:bbb', 'did:plc:ccc']);
        expect(result.cursor, 'next-cursor');
      });

      test('returns null cursor when absent', () async {
        final responseBody = jsonEncode({
          'total': 1,
          'dids': ['did:plc:aaa'],
        });
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getDistinct('did:plc:abc', 'source');

        expect(result.cursor, isNull);
      });

      test('treats null dids as empty list', () async {
        final responseBody = jsonEncode({'total': 1, 'dids': null});
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getDistinct('did:plc:abc', 'source');

        expect(result.dids, isEmpty);
      });

      test('passes limit and cursor as query parameters', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0, 'dids': []}), 200);
          }),
        );

        await client.getDistinct('did:plc:abc', 'source', limit: 25, cursor: 'some-cursor');

        expect(capturedUri?.queryParameters['limit'], '25');
        expect(capturedUri?.queryParameters['cursor'], 'some-cursor');
      });

      test('omits limit and cursor when not provided', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0, 'dids': []}), 200);
          }),
        );

        await client.getDistinct('did:plc:abc', 'source');

        expect(capturedUri?.queryParameters.containsKey('limit'), isFalse);
        expect(capturedUri?.queryParameters.containsKey('cursor'), isFalse);
      });

      test('throws ConstellationException on non-200 response', () async {
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response('Not Found', 404)));

        expect(() => client.getDistinct('did:plc:abc', 'source'), throwsA(isA<ConstellationException>()));
      });
    });

    group('getBacklinks', () {
      test('prefers records payload when returned by Microcosm', () async {
        final responseBody = jsonEncode({
          'total': 2,
          'records': [
            {'did': 'did:plc:aaa', 'collection': 'app.bsky.graph.block', 'rkey': 'rkey1'},
            {'did': 'did:plc:bbb', 'collection': 'app.bsky.graph.block', 'rkey': 'rkey2'},
          ],
          'linking_records': [
            {'did': 'did:plc:ignored', 'collection': 'app.bsky.graph.block', 'rkey': 'ignored'},
          ],
          'cursor': 'cursor-xyz',
        });
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getBacklinks('did:plc:abc', 'app.bsky.graph.block:subject');

        expect(result.total, 2);
        expect(result.records.map((record) => record.did).toList(), ['did:plc:aaa', 'did:plc:bbb']);
        expect(result.cursor, 'cursor-xyz');
      });

      test('returns total, records and cursor from response', () async {
        final responseBody = jsonEncode({
          'total': 2,
          'linking_records': [
            {'did': 'did:plc:aaa', 'collection': 'app.bsky.graph.listitem', 'rkey': 'rkey1'},
            {'did': 'did:plc:bbb', 'collection': 'app.bsky.graph.listitem', 'rkey': 'rkey2'},
          ],
          'cursor': 'cursor-xyz',
        });
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getBacklinks('did:plc:abc', 'app.bsky.graph.listitem:subject');

        expect(result.total, 2);
        expect(result.records.length, 2);
        expect(result.records.first.did, 'did:plc:aaa');
        expect(result.records.first.collection, 'app.bsky.graph.listitem');
        expect(result.records.first.rkey, 'rkey1');
        expect(result.cursor, 'cursor-xyz');
      });

      test('returns empty records list when none returned', () async {
        final responseBody = jsonEncode({'total': 0, 'linking_records': []});
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getBacklinks('did:plc:abc', 'source');

        expect(result.records, isEmpty);
        expect(result.cursor, isNull);
      });

      test('treats null linking_records as empty list', () async {
        final responseBody = jsonEncode({'total': 0, 'linking_records': null});
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getBacklinks('did:plc:abc', 'source');

        expect(result.records, isEmpty);
      });

      test('passes limit and cursor as query parameters', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'total': 0, 'linking_records': []}), 200);
          }),
        );

        await client.getBacklinks('did:plc:abc', 'source', limit: 50, cursor: 'page2');

        expect(capturedUri?.queryParameters['limit'], '50');
        expect(capturedUri?.queryParameters['cursor'], 'page2');
      });

      test('throws ConstellationException on error response', () async {
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response('Unauthorized', 401)));

        expect(() => client.getBacklinks('did:plc:abc', 'source'), throwsA(isA<ConstellationException>()));
      });
    });

    group('getManyToMany', () {
      test('returns items and cursor from response', () async {
        final responseBody = jsonEncode({
          'items': [
            {
              'linkRecord': {'did': 'did:plc:aaa', 'collection': 'app.bsky.graph.listitem', 'rkey': 'rk1'},
              'otherSubject': 'at://did:plc:aaa/app.bsky.graph.list/rk2',
            },
          ],
          'cursor': 'next',
        });
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getManyToMany('did:plc:abc', 'app.bsky.graph.listitem:subject', 'list');

        expect(result.items.length, 1);
        expect(result.items.first.linkRecord.did, 'did:plc:aaa');
        expect(result.items.first.otherSubject, 'at://did:plc:aaa/app.bsky.graph.list/rk2');
        expect(result.cursor, 'next');
      });

      test('passes pathToOther as query parameter', () async {
        Uri? capturedUri;
        final client = ConstellationClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'items': [], 'cursor': null}), 200);
          }),
        );

        await client.getManyToMany('did:plc:abc', 'source', 'list');

        expect(capturedUri?.queryParameters['pathToOther'], 'list');
        expect(capturedUri?.path, '/xrpc/blue.microcosm.links.getManyToMany');
      });

      test('returns null cursor when absent', () async {
        final responseBody = jsonEncode({'items': []});
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getManyToMany('did:plc:abc', 'source', 'list');

        expect(result.cursor, isNull);
      });

      test('treats null items as empty list', () async {
        final responseBody = jsonEncode({'items': null});
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response(responseBody, 200)));

        final result = await client.getManyToMany('did:plc:abc', 'source', 'list');

        expect(result.items, isEmpty);
      });

      test('throws ConstellationException on error response', () async {
        final client = ConstellationClient(httpClient: MockClient((_) async => http.Response('Bad Request', 400)));

        expect(() => client.getManyToMany('did:plc:abc', 'source', 'list'), throwsA(isA<ConstellationException>()));
      });
    });

    group('ConstellationException', () {
      test('toString includes message', () {
        const e = ConstellationException('HTTP 500: server error');
        expect(e.toString(), contains('HTTP 500: server error'));
      });
    });

    group('ConstellationLinkRecord.fromJson', () {
      test('parses all fields', () {
        final record = ConstellationLinkRecord.fromJson({
          'did': 'did:plc:xyz',
          'collection': 'app.bsky.graph.listitem',
          'rkey': 'abc123',
        });
        expect(record.did, 'did:plc:xyz');
        expect(record.collection, 'app.bsky.graph.listitem');
        expect(record.rkey, 'abc123');
      });
    });

    group('ManyToManyItem.fromJson', () {
      test('parses linkRecord and otherSubject', () {
        final item = ManyToManyItem.fromJson({
          'linkRecord': {'did': 'did:plc:a', 'collection': 'col', 'rkey': 'rk'},
          'otherSubject': 'at://did:plc:a/app.bsky.graph.list/rk2',
        });
        expect(item.linkRecord.did, 'did:plc:a');
        expect(item.otherSubject, 'at://did:plc:a/app.bsky.graph.list/rk2');
      });
    });
  });
}
