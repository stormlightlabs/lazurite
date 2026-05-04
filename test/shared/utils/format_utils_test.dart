import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

void main() {
  setUp(() {
    Intl.defaultLocale = 'en_US';
  });

  group('formatInitials', () {
    test('returns question mark for empty values', () {
      expect(formatInitials(''), '?');
      expect(formatInitials('   '), '?');
    });

    test('formats single and multi-part names', () {
      expect(formatInitials('alice'), 'A');
      expect(formatInitials('alice bob'), 'AB');
      expect(formatInitials('alice   bob   carol'), 'AC');
    });
  });

  group('formatCount', () {
    test('formats zero and negative values', () {
      expect(formatCount(0), '0');
      expect(formatCount(-12), '-12');
      expect(formatCount(-1200), '-1.2K');
    });

    test('formats boundary values', () {
      expect(formatCount(999), '999');
      expect(formatCount(1000), '1.0K');
      expect(formatCount(999999), '1000.0K');
      expect(formatCount(1000000), '1.0M');
    });
  });

  group('formatRelativeTime', () {
    final now = DateTime(2026, 4, 25, 12, 0);

    test('formats core minute/hour/day boundaries', () {
      expect(formatRelativeTime(now, now: now), 'now');
      expect(formatRelativeTime(now.subtract(const Duration(seconds: 59)), now: now), 'now');
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 1)), now: now), '1m');
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 59)), now: now), '59m');
      expect(formatRelativeTime(now.subtract(const Duration(hours: 1)), now: now), '1h');
      expect(formatRelativeTime(now.subtract(const Duration(hours: 23)), now: now), '23h');
      expect(formatRelativeTime(now.subtract(const Duration(days: 1)), now: now), '1d');
      expect(formatRelativeTime(now.subtract(const Duration(days: 6)), now: now), '6d');
    });

    test('formats older timestamps as dates and supports uppercase', () {
      final formatted = formatRelativeTime(now.subtract(const Duration(days: 7)), now: now);
      final formattedUpper = formatRelativeTime(now.subtract(const Duration(days: 7)), now: now, uppercase: true);

      expect(formatted, matches(RegExp(r'^[A-Z][a-z]{2} \d{1,2}$')));
      expect(formattedUpper, matches(RegExp(r'^[A-Z]{3} \d{1,2}$')));
    });

    test('supports custom labels and suffixes', () {
      expect(formatRelativeTime(now, now: now, nowLabel: 'Just now', includeAgo: true), 'Just now');
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 2)), now: now, includeAgo: true), '2m ago');
    });

    test('clamps future timestamps to now label', () {
      expect(formatRelativeTime(now.add(const Duration(minutes: 5)), now: now), 'now');
    });
  });

  group('feedDisplayName', () {
    test('prefers generator displayName when available', () {
      final feed = GeneratorView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.generator/test'),
        cid: 'cid-1',
        creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
        did: 'did:plc:test',
        displayName: 'What\'s Hot',
        indexedAt: DateTime.utc(2026, 3, 16),
      );

      expect(feedDisplayName(feed), 'What\'s Hot');
    });

    test('falls back to URI rkey when displayName is empty', () {
      final feed = GeneratorView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.generator/test'),
        cid: 'cid-1',
        creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
        did: 'did:plc:test',
        displayName: '   ',
        indexedAt: DateTime.utc(2026, 3, 16),
      );

      expect(feedDisplayName(feed), 'test');
    });
  });
}
