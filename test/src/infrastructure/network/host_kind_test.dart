import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/host_kind.dart';

void main() {
  group('HostKind', () {
    test('values contains publicApi and pds', () {
      expect(HostKind.values, containsAll([HostKind.publicApi, HostKind.pds]));
      expect(HostKind.values.length, 2);
    });
  });

  group('HostKindExtension', () {
    group('baseUrl', () {
      test('publicApi returns public.api.bsky.app URL', () {
        expect(HostKind.publicApi.baseUrl, equals('https://public.api.bsky.app'));
      });

      test('pds returns null (resolved at runtime)', () {
        expect(HostKind.pds.baseUrl, isNull);
      });
    });

    group('requiresSession', () {
      test('publicApi does not require session', () {
        expect(HostKind.publicApi.requiresSession, isFalse);
      });

      test('pds requires session', () {
        expect(HostKind.pds.requiresSession, isTrue);
      });
    });
  });
}
