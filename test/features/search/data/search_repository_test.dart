import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/graph/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
  });

  final sampleStarterPack = StarterPackViewBasic(
    uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1'),
    cid: 'cid-pack-1',
    record: const {
      r'$type': 'app.bsky.graph.starterpack',
      'name': 'Test Starter Pack',
      'list': 'at://did:plc:creator/app.bsky.graph.list/list-1',
      'createdAt': '2026-01-01T00:00:00.000Z',
    },
    creator: const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    indexedAt: DateTime.utc(2026, 1, 1),
  );

  final sampleFeed = GeneratorView(
    uri: AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/whats-hot'),
    cid: 'cid-feed',
    did: 'did:web:feed.example.com',
    creator: ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social', indexedAt: DateTime.utc(2026, 1, 1)),
    displayName: 'What\'s Hot',
    indexedAt: DateTime.utc(2026, 1, 1),
  );

  group('SearchRepository.searchStarterPacks', () {
    test('returns result with starterPacks and cursor', () async {
      when(
        () => mockRepository.searchStarterPacks(
          query: 'flutter',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: [sampleStarterPack], cursor: 'next-cursor'));

      final result = await mockRepository.searchStarterPacks(query: 'flutter');

      expect(result.starterPacks.length, 1);
      expect(result.cursor, 'next-cursor');
    });

    test('returns empty result when no packs found', () async {
      when(
        () => mockRepository.searchStarterPacks(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: []));

      final result = await mockRepository.searchStarterPacks(query: 'noresults');

      expect(result.starterPacks, isEmpty);
      expect(result.cursor, isNull);
    });

    test('passes cursor for pagination', () async {
      when(
        () => mockRepository.searchStarterPacks(
          query: 'test',
          cursor: 'page-2-cursor',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: [sampleStarterPack], cursor: 'page-3-cursor'));

      final result = await mockRepository.searchStarterPacks(query: 'test', cursor: 'page-2-cursor');

      expect(result.cursor, 'page-3-cursor');
      verify(
        () => mockRepository.searchStarterPacks(
          query: 'test',
          cursor: 'page-2-cursor',
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });

    test('propagates exceptions', () async {
      when(
        () => mockRepository.searchStarterPacks(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network error'));

      expect(() => mockRepository.searchStarterPacks(query: 'fail'), throwsException);
    });
  });

  group('SearchStarterPacksResult', () {
    test('holds starterPacks and optional cursor', () {
      final result = SearchStarterPacksResult(starterPacks: [sampleStarterPack], cursor: 'cursor');
      expect(result.starterPacks.length, 1);
      expect(result.cursor, 'cursor');
    });

    test('cursor defaults to null', () {
      final result = SearchStarterPacksResult(starterPacks: []);
      expect(result.cursor, isNull);
    });
  });

  group('SearchRepository.searchFeedGenerators', () {
    test('returns result with feeds and cursor', () async {
      when(
        () => mockRepository.searchFeedGenerators(
          query: 'hot',
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchFeedsResult(feeds: [sampleFeed], cursor: 'feed-next'));

      final result = await mockRepository.searchFeedGenerators(query: 'hot');

      expect(result.feeds.length, 1);
      expect(result.cursor, 'feed-next');
    });

    test('returns empty result when no feeds found', () async {
      when(
        () => mockRepository.searchFeedGenerators(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchFeedsResult(feeds: []));

      final result = await mockRepository.searchFeedGenerators(query: 'none');

      expect(result.feeds, isEmpty);
      expect(result.cursor, isNull);
    });

    test('passes cursor for pagination', () async {
      when(
        () => mockRepository.searchFeedGenerators(
          query: 'feeds',
          cursor: 'cursor-1',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchFeedsResult(feeds: [sampleFeed], cursor: 'cursor-2'));

      final result = await mockRepository.searchFeedGenerators(query: 'feeds', cursor: 'cursor-1');

      expect(result.cursor, 'cursor-2');
      verify(
        () => mockRepository.searchFeedGenerators(
          query: 'feeds',
          cursor: 'cursor-1',
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });

    test('propagates exceptions', () async {
      when(
        () => mockRepository.searchFeedGenerators(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network error'));

      expect(() => mockRepository.searchFeedGenerators(query: 'fail'), throwsException);
    });
  });

  group('SearchFeedsResult', () {
    test('holds feeds and optional cursor', () {
      final result = SearchFeedsResult(feeds: [sampleFeed], cursor: 'cursor');
      expect(result.feeds.length, 1);
      expect(result.cursor, 'cursor');
    });

    test('cursor defaults to null', () {
      final result = SearchFeedsResult(feeds: []);
      expect(result.cursor, isNull);
    });
  });
}
