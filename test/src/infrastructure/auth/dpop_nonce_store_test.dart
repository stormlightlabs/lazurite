import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_nonce_store.dart';

void main() {
  group('DPoPNonceStore', () {
    late DPoPNonceStore store;

    setUp(() {
      store = DPoPNonceStore();
    });

    group('store and get', () {
      test('stores and retrieves nonce for server URL', () {
        const serverUrl = 'https://bsky.social';
        const nonce = 'nonce-value-123';

        store.store(serverUrl, nonce);
        final retrieved = store.get(serverUrl);

        expect(retrieved, equals(nonce));
      });

      test('returns null for non-existent server URL', () {
        final retrieved = store.get('https://example.com');
        expect(retrieved, isNull);
      });

      test('overwrites existing nonce for same server URL', () {
        const serverUrl = 'https://bsky.social';

        store.store(serverUrl, 'nonce1');
        store.store(serverUrl, 'nonce2');

        final retrieved = store.get(serverUrl);
        expect(retrieved, equals('nonce2'));
      });

      test('handles multiple server URLs independently', () {
        store.store('https://bsky.social', 'nonce1');
        store.store('https://example.com', 'nonce2');

        expect(store.get('https://bsky.social'), equals('nonce1'));
        expect(store.get('https://example.com'), equals('nonce2'));
      });
    });

    group('expiration', () {
      test('returns valid nonce immediately after storage', () {
        const serverUrl = 'https://bsky.social';
        const nonce = 'valid-nonce';

        store.store(serverUrl, nonce);
        final retrieved = store.get(serverUrl);

        expect(retrieved, equals(nonce));
      });
    });

    group('clear', () {
      test('clears nonce for specific server URL', () {
        const serverUrl = 'https://bsky.social';

        store.store(serverUrl, 'nonce');
        store.clear(serverUrl);

        final retrieved = store.get(serverUrl);
        expect(retrieved, isNull);
      });

      test('clearing non-existent server URL does nothing', () {
        store.clear('https://example.com');
      });

      test('clearAll removes all stored nonces', () {
        store.store('https://bsky.social', 'nonce1');
        store.store('https://example.com', 'nonce2');

        store.clearAll();

        expect(store.get('https://bsky.social'), isNull);
        expect(store.get('https://example.com'), isNull);
      });
    });

    group('extractFromHeaders', () {
      test('extracts nonce from standard DPoP-Nonce header', () {
        final headers = {'DPoP-Nonce': 'test-nonce-value'};
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, equals('test-nonce-value'));
      });

      test('handles lowercase header name', () {
        final headers = {'dpop-nonce': 'test-nonce'};
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, equals('test-nonce'));
      });

      test('handles mixed case header name', () {
        final headers = {'Dpop-Nonce': 'test-nonce'};
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, equals('test-nonce'));
      });

      test('handles header value as String', () {
        final headers = {'dpop-nonce': 'string-nonce'};
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, equals('string-nonce'));
      });

      test('handles header value as List<String>', () {
        final headers = {
          'dpop-nonce': <String>['list-nonce'],
        };
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, equals('list-nonce'));
      });

      test('returns first value when header value is List with multiple values', () {
        final headers = {
          'dpop-nonce': <String>['nonce1', 'nonce2'],
        };
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, equals('nonce1'));
      });

      test('returns null when headers is null', () {
        final nonce = DPoPNonceStore.extractFromHeaders(null);
        expect(nonce, isNull);
      });

      test('returns null when DPoP-Nonce header is missing', () {
        final headers = {'Content-Type': 'application/json'};
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, isNull);
      });

      test('returns null when headers map is empty', () {
        final nonce = DPoPNonceStore.extractFromHeaders({});
        expect(nonce, isNull);
      });

      test('handles empty list value', () {
        final headers = {'dpop-nonce': <String>[]};
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, isNull);
      });

      test('ignores other headers', () {
        final headers = {
          'dpop-nonce': 'correct-nonce',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        };
        final nonce = DPoPNonceStore.extractFromHeaders(headers);

        expect(nonce, equals('correct-nonce'));
      });
    });

    group('integration scenarios', () {
      test('store → get → clear → get workflow', () {
        const serverUrl = 'https://bsky.social';
        const nonce = 'workflow-test-nonce';

        store.store(serverUrl, nonce);
        expect(store.get(serverUrl), equals(nonce));

        store.clear(serverUrl);
        expect(store.get(serverUrl), isNull);
      });

      test('extract → store → get workflow', () {
        final headers = {'DPoP-Nonce': 'extracted-nonce'};
        const serverUrl = 'https://bsky.social';

        final extracted = DPoPNonceStore.extractFromHeaders(headers);
        expect(extracted, isNotNull);

        store.store(serverUrl, extracted!);
        final retrieved = store.get(serverUrl);

        expect(retrieved, equals('extracted-nonce'));
      });

      test('multiple servers with independent lifecycles', () {
        const server1 = 'https://bsky.social';
        const server2 = 'https://example.com';

        store.store(server1, 'nonce1');
        store.store(server2, 'nonce2');

        store.clear(server1);

        expect(store.get(server1), isNull);
        expect(store.get(server2), equals('nonce2'));
      });

      test('nonce replacement updates timestamp', () {
        const serverUrl = 'https://bsky.social';
        store.store(serverUrl, 'original-nonce');
        store.store(serverUrl, 'updated-nonce');
        expect(store.get(serverUrl), equals('updated-nonce'));
      });
    });
  });
}
