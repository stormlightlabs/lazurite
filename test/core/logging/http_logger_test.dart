import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/logging/http_logger.dart';

void main() {
  group('HttpLogger', () {
    group('redactAuthorizationHeader', () {
      test('redacts Authorization header', () {
        final headers = {'Authorization': 'Bearer secret_token', 'Content-Type': 'application/json'};
        final result = HttpLogger.redactAuthorizationHeader(headers);
        expect(result.contains('Authorization: [REDACTED]'), isTrue);
        expect(result.contains('secret_token'), isFalse);
        expect(result.contains('Content-Type: application/json'), isTrue);
      });

      test('handles case-insensitive Authorization header', () {
        final headers = {'authorization': 'Bearer secret_token'};
        final result = HttpLogger.redactAuthorizationHeader(headers);
        expect(result.contains('[REDACTED]'), isTrue);
        expect(result.contains('secret_token'), isFalse);
      });

      test('returns empty string for empty headers', () {
        final result = HttpLogger.redactAuthorizationHeader({});
        expect(result, isEmpty);
      });

      test('preserves non-authorization headers', () {
        final headers = {'Content-Type': 'application/json', 'Accept': '*/*'};
        final result = HttpLogger.redactAuthorizationHeader(headers);
        expect(result.contains('Content-Type: application/json'), isTrue);
        expect(result.contains('Accept: */*'), isTrue);
      });
    });

    group('truncateBody', () {
      test('returns <empty> for null body', () {
        final result = HttpLogger.truncateBody(null);
        expect(result, '<empty>');
      });

      test('returns <empty> for empty string', () {
        final result = HttpLogger.truncateBody('');
        expect(result, '<empty>');
      });

      test('returns body as-is when under limit', () {
        const shortBody = 'short body';
        final result = HttpLogger.truncateBody(shortBody);
        expect(result, shortBody);
      });

      test('truncates body when over limit', () {
        final longBody = 'a' * 300;
        final result = HttpLogger.truncateBody(longBody);
        expect(result.length, lessThanOrEqualTo(203));
        expect(result.endsWith('...'), isTrue);
      });

      test('truncates exactly at 200 characters', () {
        final body200 = 'a' * 200;
        final result = HttpLogger.truncateBody(body200);
        expect(result, body200);
        expect(result.contains('...'), isFalse);
      });
    });

    group('formatRequest', () {
      test('formats basic request', () {
        final result = HttpLogger.formatRequest(method: 'GET', path: '/api/users');
        expect(result, 'GET /api/users');
      });

      test('formats request with headers', () {
        final result = HttpLogger.formatRequest(
          method: 'POST',
          path: '/api/users',
          headers: {'Content-Type': 'application/json'},
        );
        expect(result.contains('POST /api/users'), isTrue);
        expect(result.contains('Content-Type: application/json'), isTrue);
      });

      test('redacts Authorization header in request', () {
        final result = HttpLogger.formatRequest(
          method: 'GET',
          path: '/api/users',
          headers: {'Authorization': 'Bearer secret_token'},
        );
        expect(result.contains('[REDACTED]'), isTrue);
        expect(result.contains('secret_token'), isFalse);
      });

      test('formats request with body', () {
        final result = HttpLogger.formatRequest(method: 'POST', path: '/api/users', body: '{"name":"test"}');
        expect(result.contains('Body: {"name":"test"}'), isTrue);
      });

      test('formats complete request', () {
        final result = HttpLogger.formatRequest(
          method: 'POST',
          path: '/api/users',
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer token'},
          body: '{"name":"test"}',
        );
        expect(result.contains('POST /api/users'), isTrue);
        expect(result.contains('[REDACTED]'), isTrue);
        expect(result.contains('Body:'), isTrue);
      });
    });

    group('formatResponse', () {
      test('formats basic response', () {
        final result = HttpLogger.formatResponse(statusCode: 200, duration: const Duration(milliseconds: 150));
        expect(result, '200 (150ms)');
      });

      test('formats response with body', () {
        final result = HttpLogger.formatResponse(
          statusCode: 200,
          duration: const Duration(milliseconds: 150),
          body: '{"id":1}',
        );
        expect(result.contains('200 (150ms)'), isTrue);
        expect(result.contains('Body: {"id":1}'), isTrue);
      });

      test('truncates long response body', () {
        final longBody = 'a' * 300;
        final result = HttpLogger.formatResponse(
          statusCode: 200,
          duration: const Duration(milliseconds: 150),
          body: longBody,
        );
        expect(result.contains('...'), isTrue);
      });

      test('handles empty response body', () {
        final result = HttpLogger.formatResponse(statusCode: 204, duration: const Duration(milliseconds: 50));
        expect(result, '204 (50ms)');
      });
    });
  });
}
