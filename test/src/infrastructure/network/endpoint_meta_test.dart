import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/endpoint_meta.dart';
import 'package:lazurite/src/infrastructure/network/host_kind.dart';
import 'package:lazurite/src/infrastructure/network/http_method.dart';
import 'package:lazurite/src/infrastructure/network/proxy_kind.dart';

void main() {
  group('EndpointMeta', () {
    group('constructor', () {
      test('creates with required fields', () {
        const meta = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
        );

        expect(meta.nsid, equals('app.bsky.feed.getTimeline'));
        expect(meta.method, equals(HttpMethod.get));
        expect(meta.hostKind, equals(HostKind.pds));
        expect(meta.requiresAuth, isFalse);
        expect(meta.proxyKind, equals(ProxyKind.none));
      });

      test('creates with all fields', () {
        const meta = EndpointMeta(
          nsid: 'chat.bsky.convo.sendMessage',
          method: HttpMethod.post,
          hostKind: HostKind.pds,
          requiresAuth: true,
          proxyKind: ProxyKind.chat,
        );

        expect(meta.nsid, equals('chat.bsky.convo.sendMessage'));
        expect(meta.method, equals(HttpMethod.post));
        expect(meta.hostKind, equals(HostKind.pds));
        expect(meta.requiresAuth, isTrue);
        expect(meta.proxyKind, equals(ProxyKind.chat));
      });
    });

    group('path', () {
      test('converts NSID to XRPC path', () {
        const meta = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
        );

        expect(meta.path, equals('/xrpc/app.bsky.feed.getTimeline'));
      });

      test('handles nested NSIDs', () {
        const meta = EndpointMeta(
          nsid: 'com.atproto.repo.createRecord',
          method: HttpMethod.post,
          hostKind: HostKind.pds,
        );

        expect(meta.path, equals('/xrpc/com.atproto.repo.createRecord'));
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const meta1 = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
          requiresAuth: true,
        );
        const meta2 = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
          requiresAuth: true,
        );

        expect(meta1, equals(meta2));
        expect(meta1.hashCode, equals(meta2.hashCode));
      });

      test('different NSIDs are not equal', () {
        const meta1 = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
        );
        const meta2 = EndpointMeta(
          nsid: 'app.bsky.feed.getPosts',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
        );

        expect(meta1, isNot(equals(meta2)));
      });

      test('different methods are not equal', () {
        const meta1 = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
        );
        const meta2 = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.post,
          hostKind: HostKind.pds,
        );

        expect(meta1, isNot(equals(meta2)));
      });

      test('different auth requirements are not equal', () {
        const meta1 = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
          requiresAuth: true,
        );
        const meta2 = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
          requiresAuth: false,
        );

        expect(meta1, isNot(equals(meta2)));
      });
    });

    group('toString', () {
      test('produces readable output', () {
        const meta = EndpointMeta(
          nsid: 'app.bsky.feed.getTimeline',
          method: HttpMethod.get,
          hostKind: HostKind.pds,
          requiresAuth: true,
        );

        final str = meta.toString();
        expect(str, contains('app.bsky.feed.getTimeline'));
        expect(str, contains('get'));
        expect(str, contains('pds'));
        expect(str, contains('requiresAuth: true'));
      });
    });
  });
}
