import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/proxy_kind.dart';

void main() {
  group('ProxyKind', () {
    test('values contains none and chat', () {
      expect(ProxyKind.values, containsAll([ProxyKind.none, ProxyKind.chat]));
      expect(ProxyKind.values.length, 2);
    });
  });

  group('ProxyKindExtension', () {
    group('headerValue', () {
      test('none returns null', () {
        expect(ProxyKind.none.headerValue, isNull);
      });

      test('chat returns correct DID proxy value', () {
        expect(ProxyKind.chat.headerValue, equals('did:web:api.bsky.chat#bsky_chat'));
      });
    });

    group('requiresHeader', () {
      test('none does not require header', () {
        expect(ProxyKind.none.requiresHeader, isFalse);
      });

      test('chat requires header', () {
        expect(ProxyKind.chat.requiresHeader, isTrue);
      });
    });
  });
}
