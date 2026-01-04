import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/network_failure.dart';

void main() {
  group('NetworkFailure hierarchy', () {
    test('ConnectionFailure is a NetworkFailure', () {
      const failure = ConnectionFailure(message: 'No internet');
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, equals('No internet'));
    });

    test('AuthFailure is a NetworkFailure', () {
      const failure = AuthFailure(message: 'Token expired');
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, equals('Token expired'));
    });

    test('ServerFailure is a NetworkFailure', () {
      const failure = ServerFailure(statusCode: 500, message: 'Internal error');
      expect(failure, isA<NetworkFailure>());
      expect(failure.statusCode, equals(500));
    });

    test('ClientFailure is a NetworkFailure', () {
      const failure = ClientFailure(
        statusCode: 400,
        message: 'Bad request',
        errorCode: 'InvalidRequest',
      );
      expect(failure, isA<NetworkFailure>());
      expect(failure.statusCode, equals(400));
      expect(failure.errorCode, equals('InvalidRequest'));
    });

    test('RateLimitFailure is a NetworkFailure', () {
      const failure = RateLimitFailure(
        message: 'Too many requests',
        retryAfter: Duration(seconds: 60),
      );
      expect(failure, isA<NetworkFailure>());
      expect(failure.retryAfter, equals(const Duration(seconds: 60)));
    });

    test('DecodeFailure is a NetworkFailure', () {
      const failure = DecodeFailure(message: 'Invalid JSON');
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, equals('Invalid JSON'));
    });
  });

  group('ConnectionFailure', () {
    test('isTimeout returns true when message contains timeout', () {
      const failure = ConnectionFailure(message: 'Request timeout');
      expect(failure.isTimeout, isTrue);
    });

    test('isTimeout returns false for other errors', () {
      const failure = ConnectionFailure(message: 'Connection refused');
      expect(failure.isTimeout, isFalse);
    });

    test('isTimeout returns false when message is null', () {
      const failure = ConnectionFailure();
      expect(failure.isTimeout, isFalse);
    });

    test('toString produces readable output', () {
      const failure = ConnectionFailure(message: 'Network error');
      expect(failure.toString(), contains('Network error'));
    });

    test('toString handles null message', () {
      const failure = ConnectionFailure();
      expect(failure.toString(), contains('Unknown connection error'));
    });
  });

  group('AuthFailure', () {
    test('requiresReauth defaults to false', () {
      const failure = AuthFailure(message: 'Unauthorized');
      expect(failure.requiresReauth, isFalse);
    });

    test('requiresReauth can be set to true', () {
      const failure = AuthFailure(message: 'Token refresh failed', requiresReauth: true);
      expect(failure.requiresReauth, isTrue);
    });

    test('toString includes requiresReauth', () {
      const failure = AuthFailure(message: 'Auth error', requiresReauth: true);
      expect(failure.toString(), contains('requiresReauth: true'));
    });
  });

  group('ServerFailure', () {
    test('stores status code', () {
      const failure = ServerFailure(statusCode: 503, message: 'Service unavailable');
      expect(failure.statusCode, equals(503));
    });

    test('toString includes status code', () {
      const failure = ServerFailure(statusCode: 500, message: 'Server error');
      expect(failure.toString(), contains('500'));
    });
  });

  group('ClientFailure', () {
    test('errorCode is optional', () {
      const failure = ClientFailure(statusCode: 400);
      expect(failure.errorCode, isNull);
    });

    test('toString includes errorCode when present', () {
      const failure = ClientFailure(statusCode: 404, errorCode: 'RecordNotFound');
      expect(failure.toString(), contains('RecordNotFound'));
    });

    test('toString excludes errorCode when null', () {
      const failure = ClientFailure(statusCode: 400, message: 'Bad request');
      final str = failure.toString();
      expect(str, contains('400'));
      expect(str, isNot(contains('null')));
    });
  });

  group('RateLimitFailure', () {
    test('retryAfter is optional', () {
      const failure = RateLimitFailure(message: 'Rate limited');
      expect(failure.retryAfter, isNull);
    });

    test('toString includes retryAfter', () {
      const failure = RateLimitFailure(retryAfter: Duration(seconds: 30));
      expect(failure.toString(), contains('0:00:30'));
    });
  });

  group('DecodeFailure', () {
    test('stores cause', () {
      const exception = FormatException('Invalid JSON');
      const failure = DecodeFailure(message: 'Parse error', cause: exception);
      expect(failure.cause, equals(exception));
    });

    test('toString handles null message', () {
      const failure = DecodeFailure();
      expect(failure.toString(), contains('Failed to decode response'));
    });
  });

  group('Pattern matching', () {
    test('sealed class enables exhaustive pattern matching', () {
      const NetworkFailure failure = ConnectionFailure(message: 'Test');

      final result = switch (failure) {
        ConnectionFailure() => 'connection',
        AuthFailure() => 'auth',
        ServerFailure() => 'server',
        ClientFailure() => 'client',
        RateLimitFailure() => 'rate_limit',
        DecodeFailure() => 'decode',
      };

      expect(result, equals('connection'));
    });

    test('pattern matching works for all failure types', () {
      final failures = <NetworkFailure>[
        const ConnectionFailure(),
        const AuthFailure(),
        const ServerFailure(statusCode: 500),
        const ClientFailure(statusCode: 400),
        const RateLimitFailure(),
        const DecodeFailure(),
      ];

      final results = failures
          .map(
            (f) => switch (f) {
              ConnectionFailure() => 'connection',
              AuthFailure() => 'auth',
              ServerFailure() => 'server',
              ClientFailure() => 'client',
              RateLimitFailure() => 'rate_limit',
              DecodeFailure() => 'decode',
            },
          )
          .toList();

      expect(results, equals(['connection', 'auth', 'server', 'client', 'rate_limit', 'decode']));
    });
  });
}
