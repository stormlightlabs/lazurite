import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/infrastructure/network/dio_clients.dart';

Session _createTestSession() {
  return Session(
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    pdsUrl: 'https://pds.example.com',
    accessJwt: 'test-token',
    refreshJwt: 'refresh-token',
    scope: 'atproto',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    dpopKey: const {'kty': 'EC', 'crv': 'P-256', 'x': 'test', 'y': 'test', 'd': 'test'},
  );
}

void main() {
  group('createPublicDio', () {
    test('creates Dio with correct base URL', () {
      final dio = createPublicDio(enableLogging: false);
      expect(dio.options.baseUrl, equals('https://public.api.bsky.app'));
    });

    test('sets correct timeouts', () {
      final dio = createPublicDio(enableLogging: false);
      expect(dio.options.connectTimeout, equals(const Duration(seconds: 30)));
      expect(dio.options.receiveTimeout, equals(const Duration(seconds: 30)));
      expect(dio.options.sendTimeout, equals(const Duration(seconds: 30)));
    });

    test('sets JSON content type headers', () {
      final dio = createPublicDio(enableLogging: false);
      expect(dio.options.headers['Accept'], equals('application/json'));
      expect(dio.options.headers['Content-Type'], equals('application/json'));
    });

    test('includes retry interceptor', () {
      final dio = createPublicDio(enableLogging: false);

      final hasRetryInterceptor = dio.interceptors.any(
        (i) => i.runtimeType.toString().contains('Retry'),
      );
      expect(hasRetryInterceptor, isTrue);
    });

    test('includes logging interceptor when enabled', () {
      final dio = createPublicDio(enableLogging: true);

      final hasLoggingInterceptor = dio.interceptors.any(
        (i) => i.runtimeType.toString().contains('Logging'),
      );
      expect(hasLoggingInterceptor, isTrue);
    });

    test('excludes logging interceptor when disabled', () {
      final dio = createPublicDio(enableLogging: false);

      final hasLoggingInterceptor = dio.interceptors.any(
        (i) => i.runtimeType.toString().contains('Logging'),
      );
      expect(hasLoggingInterceptor, isFalse);
    });
  });

  group('createPdsDio', () {
    test('creates Dio with provided PDS URL', () {
      final dio = createPdsDio(
        pdsUrl: 'https://user.pds.example',
        getSession: () async => _createTestSession(),
        refreshSession: () async => _createTestSession(),
        enableLogging: false,
      );

      expect(dio.options.baseUrl, equals('https://user.pds.example'));
    });

    test('sets correct timeouts', () {
      final dio = createPdsDio(
        pdsUrl: 'https://user.pds.example',
        getSession: () async => _createTestSession(),
        refreshSession: () async => _createTestSession(),
        enableLogging: false,
      );

      expect(dio.options.connectTimeout, equals(const Duration(seconds: 30)));
      expect(dio.options.receiveTimeout, equals(const Duration(seconds: 30)));
      expect(dio.options.sendTimeout, equals(const Duration(seconds: 30)));
    });

    test('includes auth interceptor', () {
      final dio = createPdsDio(
        pdsUrl: 'https://user.pds.example',
        getSession: () async => _createTestSession(),
        refreshSession: () async => _createTestSession(),
        enableLogging: false,
      );

      final hasAuthInterceptor = dio.interceptors.any(
        (i) => i.runtimeType.toString().contains('Auth'),
      );
      expect(hasAuthInterceptor, isTrue);
    });

    test('includes proxy interceptor', () {
      final dio = createPdsDio(
        pdsUrl: 'https://user.pds.example',
        getSession: () async => _createTestSession(),
        refreshSession: () async => _createTestSession(),
        enableLogging: false,
      );

      final hasProxyInterceptor = dio.interceptors.any(
        (i) => i.runtimeType.toString().contains('Proxy'),
      );
      expect(hasProxyInterceptor, isTrue);
    });

    test('includes retry interceptor', () {
      final dio = createPdsDio(
        pdsUrl: 'https://user.pds.example',
        getSession: () async => _createTestSession(),
        refreshSession: () async => _createTestSession(),
        enableLogging: false,
      );

      final hasRetryInterceptor = dio.interceptors.any(
        (i) => i.runtimeType.toString().contains('Retry'),
      );
      expect(hasRetryInterceptor, isTrue);
    });

    test('interceptors are in correct order', () {
      final dio = createPdsDio(
        pdsUrl: 'https://user.pds.example',
        getSession: () async => _createTestSession(),
        refreshSession: () async => _createTestSession(),
        enableLogging: true,
      );

      final interceptorTypes = dio.interceptors.map((i) => i.runtimeType.toString()).toList();

      final loggingIndex = interceptorTypes.indexWhere((t) => t.contains('Logging'));
      final authIndex = interceptorTypes.indexWhere((t) => t.contains('Auth'));
      final proxyIndex = interceptorTypes.indexWhere((t) => t.contains('Proxy'));
      final retryIndex = interceptorTypes.indexWhere((t) => t.contains('Retry'));

      if (loggingIndex >= 0) {
        expect(loggingIndex, lessThan(authIndex));
      }
      expect(authIndex, lessThan(proxyIndex));
      expect(proxyIndex, lessThan(retryIndex));
    });
  });

  group('publicApiBaseUrl constant', () {
    test('has correct value', () {
      expect(publicApiBaseUrl, equals('https://public.api.bsky.app'));
    });
  });
}
