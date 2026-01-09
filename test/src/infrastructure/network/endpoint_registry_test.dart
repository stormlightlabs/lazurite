import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/endpoint_registry.dart';
import 'package:lazurite/src/infrastructure/network/host_kind.dart';
import 'package:lazurite/src/infrastructure/network/http_method.dart';
import 'package:lazurite/src/infrastructure/network/proxy_kind.dart';

void main() {
  late EndpointRegistry registry;

  setUp(() {
    registry = EndpointRegistry.instance;
  });

  group('EndpointRegistry.lookup', () {
    test('returns metadata for known NSID', () {
      final meta = registry.lookup('app.bsky.feed.getTimeline');

      expect(meta, isNotNull);
      expect(meta!.nsid, equals('app.bsky.feed.getTimeline'));
      expect(meta.method, equals(HttpMethod.get));
      expect(meta.hostKind, equals(HostKind.pds));
      expect(meta.requiresAuth, isTrue);
    });

    test('returns null for unknown NSID', () {
      final meta = registry.lookup('unknown.endpoint');
      expect(meta, isNull);
    });

    test('returns metadata for public endpoints', () {
      final meta = registry.lookup('app.bsky.feed.getPostThread');

      expect(meta, isNotNull);
      expect(meta!.hostKind, equals(HostKind.publicApi));
      expect(meta.requiresAuth, isFalse);
    });

    test('returns metadata for chat endpoints with proxy', () {
      final meta = registry.lookup('chat.bsky.convo.listConvos');

      expect(meta, isNotNull);
      expect(meta!.hostKind, equals(HostKind.pds));
      expect(meta.requiresAuth, isTrue);
      expect(meta.proxyKind, equals(ProxyKind.chat));
    });
  });

  group('EndpointRegistry.get', () {
    test('returns metadata for known NSID', () {
      final meta = registry.get('app.bsky.feed.getTimeline');
      expect(meta.nsid, equals('app.bsky.feed.getTimeline'));
    });

    test('throws ArgumentError for unknown NSID', () {
      expect(() => registry.get('unknown.endpoint'), throwsA(isA<ArgumentError>()));
    });
  });

  group('EndpointRegistry.contains', () {
    test('returns true for known NSID', () {
      expect(registry.contains('app.bsky.feed.getTimeline'), isTrue);
    });

    test('returns false for unknown NSID', () {
      expect(registry.contains('unknown.endpoint'), isFalse);
    });
  });

  group('EndpointRegistry.allNsids', () {
    test('returns non-empty list of NSIDs', () {
      final nsids = registry.allNsids.toList();
      expect(nsids, isNotEmpty);
    });

    test('includes known endpoints', () {
      final nsids = registry.allNsids.toList();
      expect(nsids, contains('app.bsky.feed.getTimeline'));
      expect(nsids, contains('app.bsky.feed.getPostThread'));
      expect(nsids, contains('chat.bsky.convo.listConvos'));
    });
  });

  group('EndpointRegistry.allEndpoints', () {
    test('returns non-empty list of endpoints', () {
      final endpoints = registry.allEndpoints.toList();
      expect(endpoints, isNotEmpty);
    });

    test('all endpoints have valid metadata', () {
      for (final endpoint in registry.allEndpoints) {
        expect(endpoint.nsid, isNotEmpty);
        expect(endpoint.path, startsWith('/xrpc/'));
        expect(HostKind.values, contains(endpoint.hostKind));
        expect(HttpMethod.values, contains(endpoint.method));
        expect(ProxyKind.values, contains(endpoint.proxyKind));
      }
    });
  });

  group('EndpointRegistry.publicEndpoints', () {
    test('returns only endpoints that do not require auth', () {
      for (final endpoint in registry.publicEndpoints) {
        expect(endpoint.requiresAuth, isFalse);
      }
    });

    test('includes expected public endpoints', () {
      final nsids = registry.publicEndpoints.map((e) => e.nsid).toList();
      expect(nsids, contains('app.bsky.feed.getPostThread'));
      expect(nsids, contains('app.bsky.actor.getProfile'));
      expect(nsids, contains('com.atproto.identity.resolveHandle'));
    });
  });

  group('EndpointRegistry.authEndpoints', () {
    test('returns only endpoints that require auth', () {
      for (final endpoint in registry.authEndpoints) {
        expect(endpoint.requiresAuth, isTrue);
      }
    });

    test('includes expected authenticated endpoints', () {
      final nsids = registry.authEndpoints.map((e) => e.nsid).toList();
      expect(nsids, contains('app.bsky.feed.getTimeline'));
      expect(nsids, contains('com.atproto.repo.createRecord'));
    });
  });

  group('EndpointRegistry.chatEndpoints', () {
    test('returns only chat proxy endpoints', () {
      for (final endpoint in registry.chatEndpoints) {
        expect(endpoint.proxyKind, equals(ProxyKind.chat));
      }
    });

    test('includes expected chat endpoints', () {
      final nsids = registry.chatEndpoints.map((e) => e.nsid).toList();
      expect(nsids, contains('chat.bsky.convo.listConvos'));
      expect(nsids, contains('chat.bsky.convo.sendMessage'));
      expect(nsids, contains('chat.bsky.convo.getMessages'));
    });

    test('all chat endpoints require auth', () {
      for (final endpoint in registry.chatEndpoints) {
        expect(endpoint.requiresAuth, isTrue);
      }
    });

    test('all chat endpoints use PDS host', () {
      for (final endpoint in registry.chatEndpoints) {
        expect(endpoint.hostKind, equals(HostKind.pds));
      }
    });
  });

  group('EndpointRegistry.where', () {
    test('filters endpoints by predicate', () {
      final postEndpoints = registry.where((e) => e.method == HttpMethod.post);

      for (final endpoint in postEndpoints) {
        expect(endpoint.method, equals(HttpMethod.post));
      }
    });

    test('returns empty when no matches', () {
      final noMatches = registry.where((e) => e.nsid == 'nonexistent');
      expect(noMatches, isEmpty);
    });
  });

  group('Endpoint routing rules', () {
    test('public read endpoints use publicApi host', () {
      final publicReads = [
        'app.bsky.feed.getPostThread',
        'app.bsky.feed.getPosts',
        'app.bsky.actor.getProfile',
        'com.atproto.identity.resolveHandle',
      ];

      for (final nsid in publicReads) {
        final meta = registry.get(nsid);
        expect(meta.hostKind, equals(HostKind.publicApi), reason: '$nsid should use publicApi');
        expect(meta.requiresAuth, isFalse, reason: '$nsid should not require auth');
      }
    });

    test('authenticated read endpoints use pds host', () {
      final authReads = [
        'app.bsky.feed.getTimeline',
        'app.bsky.feed.searchPosts',
        'app.bsky.notification.listNotifications',
        'app.bsky.actor.getPreferences',
      ];

      for (final nsid in authReads) {
        final meta = registry.get(nsid);
        expect(meta.hostKind, equals(HostKind.pds), reason: '$nsid should use pds');
        expect(meta.requiresAuth, isTrue, reason: '$nsid should require auth');
      }
    });

    test('write endpoints use pds host and require auth', () {
      final writes = [
        'com.atproto.repo.createRecord',
        'com.atproto.repo.deleteRecord',
        'com.atproto.repo.uploadBlob',
      ];

      for (final nsid in writes) {
        final meta = registry.get(nsid);
        expect(meta.hostKind, equals(HostKind.pds), reason: '$nsid should use pds');
        expect(meta.requiresAuth, isTrue, reason: '$nsid should require auth');
        expect(meta.method, equals(HttpMethod.post), reason: '$nsid should be POST');
      }
    });

    test('chat endpoints use pds with chat proxy', () {
      final chatEndpoints = [
        'chat.bsky.convo.listConvos',
        'chat.bsky.convo.getConvo',
        'chat.bsky.convo.getMessages',
        'chat.bsky.convo.sendMessage',
      ];

      for (final nsid in chatEndpoints) {
        final meta = registry.get(nsid);
        expect(meta.hostKind, equals(HostKind.pds), reason: '$nsid should use pds');
        expect(meta.requiresAuth, isTrue, reason: '$nsid should require auth');
        expect(meta.proxyKind, equals(ProxyKind.chat), reason: '$nsid should use chat proxy');
      }
    });

    test('feed generator endpoints are registered', () {
      final feedEndpoints = ['app.bsky.feed.getFeedGenerator', 'app.bsky.feed.getFeedGenerators'];

      for (final nsid in feedEndpoints) {
        final meta = registry.get(nsid);
        expect(meta.hostKind, equals(HostKind.publicApi), reason: '$nsid should use publicApi');
        expect(meta.requiresAuth, isFalse, reason: '$nsid should not require auth');
        expect(meta.method, equals(HttpMethod.get), reason: '$nsid should be GET');
      }
    });

    test('graph list endpoints are registered', () {
      final listEndpoints = ['app.bsky.graph.getList'];

      for (final nsid in listEndpoints) {
        final meta = registry.get(nsid);
        expect(meta.hostKind, equals(HostKind.publicApi), reason: '$nsid should use publicApi');
        expect(meta.requiresAuth, isFalse, reason: '$nsid should not require auth');
        expect(meta.method, equals(HttpMethod.get), reason: '$nsid should be GET');
      }
    });
  });
}
