import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:mocktail/mocktail.dart';

class _StubBluesky {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late _StubBluesky bluesky;
  late MockAppDatabase database;

  setUp(() {
    bluesky = _StubBluesky();
    database = MockAppDatabase();
  });

  test('timeout does not fallback when cross-provider fallback is disabled', () async {
    final repo = FeedRepository(
      bluesky: bluesky,
      database: database,
      accountDid: 'did:plc:test',
      appViewProvider: 'bluesky',
      crossProviderFallbackEnabled: false,
    );
    final attempts = <String>[];

    await expectLater(
      () => repo.runPublicReadWithFallbackForTest<String>(
        endpointId: 'app.bsky.unspecced.getTrends',
        request: (provider) async {
          attempts.add(provider);
          throw TimeoutException('request timed out');
        },
      ),
      throwsA(isA<TimeoutException>()),
    );

    expect(attempts, equals(['bluesky']));
  });

  test('429 triggers fallback when cross-provider fallback is enabled', () async {
    final repo = FeedRepository(
      bluesky: bluesky,
      database: database,
      accountDid: 'did:plc:test',
      appViewProvider: 'bluesky',
      crossProviderFallbackEnabled: true,
    );
    final attempts = <String>[];

    final result = await repo.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getTrendingTopics',
      request: (provider) async {
        attempts.add(provider);
        if (provider == 'bluesky') {
          throw Exception('HTTP 429: too many requests');
        }
        return 'ok:$provider';
      },
    );

    expect(result, equals('ok:blacksky'));
    expect(attempts, equals(['bluesky', 'blacksky']));
  });

  test('5xx triggers fallback when cross-provider fallback is enabled', () async {
    final repo = FeedRepository(
      bluesky: bluesky,
      database: database,
      accountDid: 'did:plc:test',
      appViewProvider: 'blacksky',
      crossProviderFallbackEnabled: true,
    );
    final attempts = <String>[];

    final result = await repo.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getTrends',
      request: (provider) async {
        attempts.add(provider);
        if (provider == 'blacksky') {
          throw Exception('HTTP 503 service unavailable');
        }
        return 'ok:$provider';
      },
    );

    expect(result, equals('ok:bluesky'));
    expect(attempts, equals(['blacksky', 'bluesky']));
  });

  test('429 does not fallback when cross-provider fallback is disabled', () async {
    final repo = FeedRepository(
      bluesky: bluesky,
      database: database,
      accountDid: 'did:plc:test',
      appViewProvider: 'blacksky',
      crossProviderFallbackEnabled: false,
    );
    final attempts = <String>[];

    await expectLater(
      () => repo.runPublicReadWithFallbackForTest<String>(
        endpointId: 'app.bsky.unspecced.getTrendingTopics',
        request: (provider) async {
          attempts.add(provider);
          throw Exception('429 RateLimitExceeded');
        },
      ),
      throwsA(isA<Exception>()),
    );

    expect(attempts, equals(['blacksky']));
  });

  test('circuit breaker opens after transient failure threshold and closes after window', () async {
    var now = DateTime.utc(2026, 4, 30, 12, 0, 0);
    final fallbackService = AppViewFallbackService(
      nowProvider: () => now,
      failureThreshold: 1,
      openWindow: const Duration(minutes: 2),
    );
    final repo = FeedRepository(
      bluesky: bluesky,
      database: database,
      accountDid: 'did:plc:test',
      appViewProvider: 'bluesky',
      crossProviderFallbackEnabled: true,
      appViewFallbackService: fallbackService,
    );
    final attempts = <String>[];

    final first = await repo.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getTrends',
      request: (provider) async {
        attempts.add(provider);
        if (provider == 'bluesky') {
          throw TimeoutException('timed out');
        }
        return 'ok:$provider';
      },
    );
    expect(first, equals('ok:blacksky'));

    final second = await repo.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getTrends',
      request: (provider) async {
        attempts.add(provider);
        return 'ok:$provider';
      },
    );
    expect(second, equals('ok:blacksky'));

    now = now.add(const Duration(minutes: 3));
    final third = await repo.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getTrends',
      request: (provider) async {
        attempts.add(provider);
        return 'ok:$provider';
      },
    );
    expect(third, equals('ok:bluesky'));
    expect(attempts, equals(['bluesky', 'blacksky', 'blacksky', 'bluesky']));
  });

  test('drops stale response when routing epoch changes mid-request', () async {
    var currentEpoch = 1;
    final repo = FeedRepository(
      bluesky: bluesky,
      database: database,
      accountDid: 'did:plc:test',
      appViewProvider: 'bluesky',
      crossProviderFallbackEnabled: false,
      routingEpoch: 1,
      routingEpochResolver: () => currentEpoch,
    );

    await expectLater(
      () => repo.runPublicReadWithFallbackForTest<String>(
        endpointId: 'app.bsky.unspecced.getTrends',
        request: (_) async {
          currentEpoch = 2;
          return 'stale';
        },
      ),
      throwsA(isA<StaleRoutingEpochException>()),
    );
  });
}
