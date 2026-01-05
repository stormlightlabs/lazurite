import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/auth/loopback_server.dart';

void main() {
  group('LoopbackServer', () {
    late LoopbackServer server;

    setUp(() {
      server = LoopbackServer();
    });

    tearDown(() async {
      await server.stop();
    });

    group('start', () {
      test('starts server on 127.0.0.1 with random port', () async {
        final redirectUri = await server.start();

        expect(redirectUri, startsWith('http://127.0.0.1:'));
        expect(redirectUri, endsWith('/callback'));

        final uri = Uri.parse(redirectUri);
        expect(uri.scheme, 'http');
        expect(uri.host, '127.0.0.1');
        expect(uri.port, greaterThan(0));
        expect(uri.path, '/callback');

        final client = HttpClient();
        try {
          final request = await client.getUrl(uri);
          final response = await request.close();
          expect(response.statusCode, 200);
        } finally {
          client.close();
        }
      });

      test('returns different ports on multiple server instances', () async {
        final server1 = LoopbackServer();
        final server2 = LoopbackServer();

        try {
          final uri1 = await server1.start();
          final uri2 = await server2.start();

          final port1 = Uri.parse(uri1).port;
          final port2 = Uri.parse(uri2).port;

          expect(port1, isNot(equals(port2)));
        } finally {
          await server1.stop();
          await server2.stop();
        }
      });

      test('throws StateError if server already started', () async {
        await server.start();

        expect(
          () => server.start(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'Server already started')),
        );
      });
    });

    group('waitForCallback', () {
      test('completes when callback request received', () async {
        final redirectUri = await server.start();
        final callbackFuture = server.waitForCallback();

        final client = HttpClient();
        try {
          final uri = Uri.parse(
            redirectUri,
          ).replace(queryParameters: {'code': 'test_code', 'state': 'test_state'});
          final request = await client.getUrl(uri);
          await request.close();

          final callbackUri = await callbackFuture;
          expect(callbackUri.queryParameters['code'], 'test_code');
          expect(callbackUri.queryParameters['state'], 'test_state');
        } finally {
          client.close();
        }
      });

      test('returns full callback URI with all query parameters', () async {
        final redirectUri = await server.start();
        final callbackFuture = server.waitForCallback();

        final client = HttpClient();
        try {
          final uri = Uri.parse(redirectUri).replace(
            queryParameters: {
              'code': 'auth_code_123',
              'state': 'state_456',
              'iss': 'https://bsky.social',
            },
          );
          final request = await client.getUrl(uri);
          await request.close();

          final callbackUri = await callbackFuture;
          expect(callbackUri.queryParameters['code'], 'auth_code_123');
          expect(callbackUri.queryParameters['state'], 'state_456');
          expect(callbackUri.queryParameters['iss'], 'https://bsky.social');
        } finally {
          client.close();
        }
      });

      test('completes only once for multiple requests', () async {
        final redirectUri = await server.start();
        final callbackFuture = server.waitForCallback();

        final client = HttpClient();
        try {
          final uri1 = Uri.parse(redirectUri).replace(queryParameters: {'code': 'first'});
          final request1 = await client.getUrl(uri1);
          await request1.close();

          final callbackUri = await callbackFuture;
          expect(callbackUri.queryParameters['code'], 'first');

          final uri2 = Uri.parse(redirectUri).replace(queryParameters: {'code': 'second'});
          final request2 = await client.getUrl(uri2);
          final response2 = await request2.close();
          expect(response2.statusCode, 200);
        } finally {
          client.close();
        }
      });

      test('handles OAuth error responses', () async {
        final redirectUri = await server.start();
        final callbackFuture = server.waitForCallback();

        final client = HttpClient();
        try {
          final uri = Uri.parse(redirectUri).replace(
            queryParameters: {
              'error': 'access_denied',
              'error_description': 'User denied access',
              'state': 'test_state',
            },
          );
          final request = await client.getUrl(uri);
          await request.close();

          final callbackUri = await callbackFuture;
          expect(callbackUri.queryParameters['error'], 'access_denied');
          expect(callbackUri.queryParameters['error_description'], 'User denied access');
          expect(callbackUri.queryParameters['state'], 'test_state');
        } finally {
          client.close();
        }
      });
    });

    group('stop', () {
      test('stops the server and closes connections', () async {
        final redirectUri = await server.start();
        await server.stop();

        final client = HttpClient();
        try {
          final uri = Uri.parse(redirectUri);
          await expectLater(client.getUrl(uri), throwsA(isA<SocketException>()));
        } finally {
          client.close();
        }
      });

      test('can be called multiple times safely', () async {
        await server.start();
        await server.stop();
        await server.stop();
      });

      test('can be called without starting server', () async {
        await server.stop();
      });

      test('allows server to be restarted after stop', () async {
        final redirectUri1 = await server.start();
        await server.stop();

        final redirectUri2 = await server.start();
        expect(redirectUri2, isNot(equals(redirectUri1)));

        final client = HttpClient();
        try {
          final request = await client.getUrl(Uri.parse(redirectUri2));
          final response = await request.close();
          expect(response.statusCode, 200);
        } finally {
          client.close();
        }
      });
    });

    group('HTTP responses', () {
      test('returns 200 OK for /callback endpoint', () async {
        final redirectUri = await server.start();

        final client = HttpClient();
        try {
          final request = await client.getUrl(Uri.parse(redirectUri));
          final response = await request.close();

          expect(response.statusCode, 200);
          expect(response.headers.value('content-type'), contains('text/html'));

          final body = await response.transform(const SystemEncoding().decoder).join();
          expect(body, contains('Login Successful'));
          expect(body, contains('<!DOCTYPE html>'));
        } finally {
          client.close();
        }
      });

      test('returns 404 for unknown endpoints', () async {
        final redirectUri = await server.start();
        final unknownUri = Uri.parse(redirectUri).replace(path: '/unknown');

        final client = HttpClient();
        try {
          final request = await client.getUrl(unknownUri);
          final response = await request.close();

          expect(response.statusCode, 404);
        } finally {
          client.close();
        }
      });

      test('serves success page with proper HTML', () async {
        final redirectUri = await server.start();

        final client = HttpClient();
        try {
          final request = await client.getUrl(Uri.parse(redirectUri));
          final response = await request.close();

          final body = await response.transform(const SystemEncoding().decoder).join();

          expect(body, contains('<html>'));
          expect(body, contains('<head>'));
          expect(body, contains('<body>'));
          expect(body, contains('<title>Login Successful</title>'));
          expect(body, contains('Login Successful'));
          expect(body, contains('You can close this window'));
        } finally {
          client.close();
        }
      });
    });

    group('concurrent requests', () {
      test('handles multiple concurrent requests correctly', () async {
        final redirectUri = await server.start();

        final client = HttpClient();
        try {
          final futures = List.generate(5, (i) async {
            final uri = Uri.parse(redirectUri).replace(queryParameters: {'request': '$i'});
            final request = await client.getUrl(uri);
            return await request.close();
          });

          final responses = await Future.wait(futures);

          for (final response in responses) {
            expect(response.statusCode, 200);
          }
        } finally {
          client.close();
        }
      });
    });

    group('error handling', () {
      test('handles malformed callback requests gracefully', () async {
        final redirectUri = await server.start();

        final client = HttpClient();
        try {
          final request = await client.getUrl(Uri.parse(redirectUri));
          final response = await request.close();

          expect(response.statusCode, 200);

          final callbackUri = await server.waitForCallback();
          expect(callbackUri.queryParameters, isEmpty);
        } finally {
          client.close();
        }
      });

      test('handles special characters in query parameters', () async {
        final redirectUri = await server.start();
        final callbackFuture = server.waitForCallback();

        final client = HttpClient();
        try {
          final uri = Uri.parse(
            redirectUri,
          ).replace(queryParameters: {'code': 'abc+123/xyz=', 'state': 'test&value'});
          final request = await client.getUrl(uri);
          await request.close();

          final callbackUri = await callbackFuture;
          expect(callbackUri.queryParameters['code'], 'abc+123/xyz=');
          expect(callbackUri.queryParameters['state'], 'test&value');
        } finally {
          client.close();
        }
      });
    });
  });
}
