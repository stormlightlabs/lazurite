import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/search/data/search_repository.dart';

import '../../../helpers/test_bluesky_client.dart';

void main() {
  late Bluesky bluesky;

  setUp(() {
    bluesky = testBluesky();
  });

  test('search public reads do not fallback when disabled', () async {
    final repo = SearchRepository(bluesky: bluesky, appViewProvider: 'bluesky', crossProviderFallbackEnabled: false);
    final attempts = <String>[];

    await expectLater(
      () => repo.runPublicReadWithFallbackForTest<String>(
        endpointId: 'app.bsky.unspecced.getPopularFeedGenerators',
        request: (provider) async {
          attempts.add(provider);
          throw TimeoutException('timed out');
        },
      ),
      throwsA(isA<TimeoutException>()),
    );

    expect(attempts, equals(['bluesky']));
  });

  test('search public reads fallback when enabled and transient failure occurs', () async {
    final repo = SearchRepository(bluesky: bluesky, appViewProvider: 'bluesky', crossProviderFallbackEnabled: true);
    final attempts = <String>[];

    final result = await repo.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.graph.searchStarterPacks',
      request: (provider) async {
        attempts.add(provider);
        if (provider == 'bluesky') {
          throw Exception('HTTP 503 service unavailable');
        }
        return 'ok:$provider';
      },
    );

    expect(result, equals('ok:blacksky'));
    expect(attempts, equals(['bluesky', 'blacksky']));
  });

  test('search repositories share circuit state through injected AppViewFallbackService', () async {
    var now = DateTime.utc(2026, 4, 30, 14, 0, 0);
    final fallbackService = AppViewFallbackService(
      nowProvider: () => now,
      failureThreshold: 1,
      openWindow: const Duration(minutes: 2),
    );
    final repoA = SearchRepository(
      bluesky: bluesky,
      appViewProvider: 'bluesky',
      crossProviderFallbackEnabled: true,
      appViewFallbackService: fallbackService,
    );
    final repoB = SearchRepository(
      bluesky: bluesky,
      appViewProvider: 'bluesky',
      crossProviderFallbackEnabled: true,
      appViewFallbackService: fallbackService,
    );
    final attempts = <String>[];

    final first = await repoA.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getPopularFeedGenerators',
      request: (provider) async {
        attempts.add('A:$provider');
        if (provider == 'bluesky') {
          throw TimeoutException('timed out');
        }
        return 'ok:$provider';
      },
    );
    expect(first, equals('ok:blacksky'));

    final second = await repoB.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getPopularFeedGenerators',
      request: (provider) async {
        attempts.add('B:$provider');
        return 'ok:$provider';
      },
    );
    expect(second, equals('ok:blacksky'));

    now = now.add(const Duration(minutes: 3));
    final third = await repoB.runPublicReadWithFallbackForTest<String>(
      endpointId: 'app.bsky.unspecced.getPopularFeedGenerators',
      request: (provider) async {
        attempts.add('B2:$provider');
        return 'ok:$provider';
      },
    );
    expect(third, equals('ok:bluesky'));
    expect(attempts, equals(['A:bluesky', 'A:blacksky', 'B:blacksky', 'B2:bluesky']));
  });
}
