import 'package:bluesky_poptart/app/bsky/unspecced/defs.dart';

class EnrichedTrendingTopic {
  const EnrichedTrendingTopic({required this.topic, this.trend});

  final TrendingTopic topic;
  final TrendView? trend;
}

List<EnrichedTrendingTopic> enrichTrendingTopics({
  required List<TrendingTopic> topics,
  required List<TrendView> trends,
}) {
  if (topics.isEmpty) {
    return const [];
  }

  return topics.map((topic) => EnrichedTrendingTopic(topic: topic, trend: _bestTrendFor(topic, trends))).toList();
}

TrendView? _bestTrendFor(TrendingTopic topic, List<TrendView> trends) {
  final topicLinkKey = trendLinkJoinKey(topic.link);
  final topicFallbackKey = normalizeTrendTopic(topic.topic);

  final parsedMatches = <TrendView>[];
  final fallbackMatches = <TrendView>[];

  for (final trend in trends) {
    final trendLinkKey = trendLinkJoinKey(trend.link);
    if (topicLinkKey != null && trendLinkKey == topicLinkKey) {
      parsedMatches.add(trend);
      continue;
    }

    if (normalizeTrendTopic(trend.topic) == topicFallbackKey) {
      fallbackMatches.add(trend);
    }
  }

  if (parsedMatches.isNotEmpty) {
    return _pickDeterministicTrend(parsedMatches);
  }

  if (fallbackMatches.isNotEmpty) {
    return _pickDeterministicTrend(fallbackMatches);
  }

  return null;
}

TrendView _pickDeterministicTrend(List<TrendView> candidates) {
  final sorted = List<TrendView>.from(candidates)
    ..sort((left, right) {
      final startedAtComparison = right.startedAt.compareTo(left.startedAt);
      if (startedAtComparison != 0) {
        return startedAtComparison;
      }
      return left.link.compareTo(right.link);
    });

  return sorted.first;
}

String normalizeTrendTopic(String value) {
  final trimmed = value.trim().toLowerCase();
  final withoutHash = trimmed.startsWith('#') ? trimmed.substring(1) : trimmed;
  return withoutHash.replaceAll(RegExp(r'\s+'), ' ');
}

String? trendLinkJoinKey(String rawLink) {
  final trimmed = rawLink.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final parsed = Uri.tryParse(trimmed);
  if (parsed == null) {
    return null;
  }

  final segments = parsed.pathSegments.where((segment) => segment.isNotEmpty).toList(growable: false);
  if (segments.length >= 2 && segments[0] == 'topic') {
    final topicId = segments[1].trim();
    if (topicId.isEmpty) {
      return null;
    }
    return 'topic:${topicId.toLowerCase()}';
  }

  if (segments.length >= 4 && segments[0] == 'profile' && segments[2] == 'feed') {
    final actor = segments[1].trim();
    final rkey = segments[3].trim();
    if (actor.isEmpty || rkey.isEmpty) {
      return null;
    }
    return 'feed:${actor.toLowerCase()}:${rkey.toLowerCase()}';
  }

  return null;
}
