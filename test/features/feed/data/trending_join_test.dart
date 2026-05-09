import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/unspecced/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/data/trending_join.dart';

void main() {
  group('trendLinkJoinKey', () {
    test('parses /topic links', () {
      expect(trendLinkJoinKey('/topic/DartLang'), equals('topic:dartlang'));
    });

    test('parses /profile/<actor>/feed/<rkey> links', () {
      expect(trendLinkJoinKey('/profile/alice.bsky.social/feed/aaabbb'), equals('feed:alice.bsky.social:aaabbb'));
    });

    test('returns null for unsupported link formats', () {
      expect(trendLinkJoinKey('/unknown/path'), isNull);
    });
  });

  group('normalizeTrendTopic', () {
    test('normalizes case, hash prefix, and whitespace', () {
      expect(normalizeTrendTopic('  #Dart   Lang  '), equals('dart lang'));
    });
  });

  group('enrichTrendingTopics', () {
    test('prefers parsed link key match over normalized topic match', () {
      final topics = [const TrendingTopic(topic: 'Dart', link: '/topic/dart')];
      final trends = [
        _trend(topic: '#Dart', link: '/topic/something-else', startedAt: DateTime.utc(2026, 1, 2)),
        _trend(topic: 'Different', link: '/topic/dart', startedAt: DateTime.utc(2026, 1, 1)),
      ];

      final result = enrichTrendingTopics(topics: topics, trends: trends);
      expect(result.single.trend?.link, equals('/topic/dart'));
    });

    test('uses normalized topic match when link key match is absent', () {
      final topics = [const TrendingTopic(topic: '#Dart Lang', link: '/unknown/path')];
      final trends = [_trend(topic: 'dart   lang', link: '/topic/dartlang', startedAt: DateTime.utc(2026, 1, 1))];

      final result = enrichTrendingTopics(topics: topics, trends: trends);
      expect(result.single.trend?.topic, equals('dart   lang'));
    });

    test('chooses newest startedAt when multiple matches exist', () {
      final topics = [const TrendingTopic(topic: 'Dart', link: '/topic/dart')];
      final trends = [
        _trend(topic: 'Dart', link: '/topic/dart', startedAt: DateTime.utc(2026, 1, 1)),
        _trend(topic: 'Dart', link: '/topic/dart', startedAt: DateTime.utc(2026, 1, 2)),
      ];

      final result = enrichTrendingTopics(topics: topics, trends: trends);
      expect(result.single.trend?.startedAt, equals(DateTime.utc(2026, 1, 2)));
    });

    test('breaks startedAt ties using lexicographically smallest link', () {
      final topics = [const TrendingTopic(topic: 'Dart', link: '/unknown')];
      final sameTime = DateTime.utc(2026, 1, 1);
      final trends = [
        _trend(topic: 'Dart', link: '/topic/z', startedAt: sameTime),
        _trend(topic: 'Dart', link: '/topic/a', startedAt: sameTime),
      ];

      final result = enrichTrendingTopics(topics: topics, trends: trends);
      expect(result.single.trend?.link, equals('/topic/a'));
    });

    test('returns topic row with null metadata when no match exists', () {
      final topics = [const TrendingTopic(topic: 'Dart', link: '/topic/dart')];
      final trends = [_trend(topic: 'Flutter', link: '/topic/flutter', startedAt: DateTime.utc(2026, 1, 1))];

      final result = enrichTrendingTopics(topics: topics, trends: trends);
      expect(result.single.trend, isNull);
    });
  });
}

TrendView _trend({required String topic, required String link, required DateTime startedAt}) {
  return TrendView(
    topic: topic,
    displayName: topic,
    link: link,
    startedAt: startedAt,
    postCount: 10,
    actors: const [ProfileViewBasic(did: 'did:plc:actor', handle: 'actor.bsky.social')],
  );
}
