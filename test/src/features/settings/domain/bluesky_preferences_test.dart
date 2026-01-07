import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';

void main() {
  group('AdultContentPref', () {
    test('fromJson parses enabled field', () {
      final pref = AdultContentPref.fromJson({'enabled': true});
      expect(pref.enabled, isTrue);
    });

    test('fromJson defaults to false when enabled is missing', () {
      final pref = AdultContentPref.fromJson({});
      expect(pref.enabled, isFalse);
    });

    test('toJson serializes correctly', () {
      const pref = AdultContentPref(enabled: true);
      expect(pref.toJson(), {'enabled': true});
    });

    test('round-trip through stored JSON', () {
      const original = AdultContentPref(enabled: true);
      final json = original.toStoredJson();
      final restored = AdultContentPref.fromStoredJson(json);
      expect(restored, equals(original));
    });

    test('equality works correctly', () {
      const a = AdultContentPref(enabled: true);
      const b = AdultContentPref(enabled: true);
      const c = AdultContentPref(enabled: false);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('LabelVisibility', () {
    test('fromString parses known values', () {
      expect(LabelVisibility.fromString('ignore'), LabelVisibility.ignore);
      expect(LabelVisibility.fromString('show'), LabelVisibility.show);
      expect(LabelVisibility.fromString('warn'), LabelVisibility.warn);
      expect(LabelVisibility.fromString('hide'), LabelVisibility.hide);
    });

    test('fromString defaults to warn for unknown values', () {
      expect(LabelVisibility.fromString('unknown'), LabelVisibility.warn);
      expect(LabelVisibility.fromString(null), LabelVisibility.warn);
    });

    test('toApiString returns correct values', () {
      expect(LabelVisibility.ignore.toApiString(), 'ignore');
      expect(LabelVisibility.show.toApiString(), 'show');
      expect(LabelVisibility.warn.toApiString(), 'warn');
      expect(LabelVisibility.hide.toApiString(), 'hide');
    });
  });

  group('ContentLabelPref', () {
    test('fromJson parses all fields', () {
      final pref = ContentLabelPref.fromJson({
        'label': 'sexual',
        'labelerDid': 'did:plc:test',
        'visibility': 'hide',
      });
      expect(pref.label, 'sexual');
      expect(pref.labelerDid, 'did:plc:test');
      expect(pref.visibility, LabelVisibility.hide);
    });

    test('fromJson handles missing labelerDid', () {
      final pref = ContentLabelPref.fromJson({'label': 'nudity', 'visibility': 'warn'});
      expect(pref.labelerDid, isNull);
    });

    test('toJson excludes null labelerDid', () {
      const pref = ContentLabelPref(label: 'spam', visibility: LabelVisibility.ignore);
      expect(pref.toJson(), {'label': 'spam', 'visibility': 'ignore'});
    });

    test('equality considers all fields', () {
      const a = ContentLabelPref(
        label: 'nsfw',
        labelerDid: 'did:1',
        visibility: LabelVisibility.hide,
      );
      const b = ContentLabelPref(
        label: 'nsfw',
        labelerDid: 'did:1',
        visibility: LabelVisibility.hide,
      );
      const c = ContentLabelPref(
        label: 'nsfw',
        labelerDid: 'did:2',
        visibility: LabelVisibility.hide,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ContentLabelPrefs', () {
    test('fromJsonList parses list of prefs', () {
      final prefs = ContentLabelPrefs.fromJsonList([
        {'label': 'sexual', 'visibility': 'hide'},
        {'label': 'nudity', 'visibility': 'warn'},
      ]);
      expect(prefs.items, hasLength(2));
      expect(prefs.items[0].label, 'sexual');
      expect(prefs.items[1].label, 'nudity');
    });

    test('round-trip through stored JSON', () {
      const original = ContentLabelPrefs(
        items: [
          ContentLabelPref(label: 'gore', visibility: LabelVisibility.hide),
          ContentLabelPref(label: 'spam', visibility: LabelVisibility.ignore),
        ],
      );
      final json = original.toStoredJson();
      final restored = ContentLabelPrefs.fromStoredJson(json);
      expect(restored, equals(original));
    });

    test('getVisibility returns correct value', () {
      const prefs = ContentLabelPrefs(
        items: [ContentLabelPref(label: 'test', visibility: LabelVisibility.hide)],
      );
      expect(prefs.getVisibility('test'), LabelVisibility.hide);
      expect(prefs.getVisibility('unknown'), isNull);
    });

    test('empty constant works', () {
      expect(ContentLabelPrefs.empty.items, isEmpty);
    });
  });

  group('LabelersPref', () {
    test('fromJson parses labelers array', () {
      final pref = LabelersPref.fromJson({
        'labelers': [
          {'did': 'did:plc:1'},
          {'did': 'did:plc:2'},
        ],
      });
      expect(pref.labelers, hasLength(2));
      expect(pref.labelerDids, ['did:plc:1', 'did:plc:2']);
    });

    test('fromJson handles empty labelers', () {
      final pref = LabelersPref.fromJson({'labelers': []});
      expect(pref.labelers, isEmpty);
    });

    test('round-trip through stored JSON', () {
      const original = LabelersPref(labelers: [LabelerRef(did: 'did:plc:test')]);
      final json = original.toStoredJson();
      final restored = LabelersPref.fromStoredJson(json);
      expect(restored, equals(original));
    });

    test('empty constant works', () {
      expect(LabelersPref.empty.labelers, isEmpty);
    });
  });

  group('FeedViewPref', () {
    test('fromJson parses all fields', () {
      final pref = FeedViewPref.fromJson({
        'hideReplies': true,
        'hideRepliesByUnfollowed': false,
        'hideRepliesByLikeCount': 5,
        'hideReposts': true,
        'hideQuotePosts': true,
        'feed': 'at://test/feed',
      });
      expect(pref.hideReplies, isTrue);
      expect(pref.hideRepliesByUnfollowed, isFalse);
      expect(pref.hideRepliesByLikeCount, 5);
      expect(pref.hideReposts, isTrue);
      expect(pref.hideQuotePosts, isTrue);
      expect(pref.feed, 'at://test/feed');
    });

    test('fromJson uses defaults for missing fields', () {
      final pref = FeedViewPref.fromJson({});
      expect(pref.hideReplies, isFalse);
      expect(pref.hideRepliesByUnfollowed, isTrue);
      expect(pref.hideRepliesByLikeCount, isNull);
      expect(pref.hideReposts, isFalse);
      expect(pref.hideQuotePosts, isFalse);
    });

    test('round-trip through stored JSON', () {
      const original = FeedViewPref(hideReplies: true, hideReposts: true);
      final json = original.toStoredJson();
      final restored = FeedViewPref.fromStoredJson(json);
      expect(restored, equals(original));
    });

    test('defaultPref has sensible defaults', () {
      expect(FeedViewPref.defaultPref.hideReplies, isFalse);
      expect(FeedViewPref.defaultPref.hideReposts, isFalse);
    });
  });

  group('ThreadSortOrder', () {
    test('fromString parses known values', () {
      expect(ThreadSortOrder.fromString('oldest'), ThreadSortOrder.oldest);
      expect(ThreadSortOrder.fromString('newest'), ThreadSortOrder.newest);
      expect(ThreadSortOrder.fromString('most-likes'), ThreadSortOrder.mostLikes);
      expect(ThreadSortOrder.fromString('random'), ThreadSortOrder.random);
      expect(ThreadSortOrder.fromString('hotness'), ThreadSortOrder.hotness);
    });

    test('fromString defaults to oldest for unknown values', () {
      expect(ThreadSortOrder.fromString('unknown'), ThreadSortOrder.oldest);
      expect(ThreadSortOrder.fromString(null), ThreadSortOrder.oldest);
    });

    test('toApiString returns correct values', () {
      expect(ThreadSortOrder.mostLikes.toApiString(), 'most-likes');
    });
  });

  group('ThreadViewPref', () {
    test('fromJson parses all fields', () {
      final pref = ThreadViewPref.fromJson({'sort': 'newest', 'prioritizeFollowedUsers': false});
      expect(pref.sort, ThreadSortOrder.newest);
      expect(pref.prioritizeFollowedUsers, isFalse);
    });

    test('fromJson uses defaults for missing fields', () {
      final pref = ThreadViewPref.fromJson({});
      expect(pref.sort, ThreadSortOrder.oldest);
      expect(pref.prioritizeFollowedUsers, isTrue);
    });

    test('round-trip through stored JSON', () {
      const original = ThreadViewPref(
        sort: ThreadSortOrder.mostLikes,
        prioritizeFollowedUsers: false,
      );
      final json = original.toStoredJson();
      final restored = ThreadViewPref.fromStoredJson(json);
      expect(restored, equals(original));
    });
  });

  group('MutedWord', () {
    test('fromJson parses all fields', () {
      final word = MutedWord.fromJson({
        'id': '123',
        'value': 'test word',
        'targets': ['content', 'tag'],
        'actorTarget': 'exclude-following',
        'expiresAt': '2025-01-01T00:00:00.000Z',
      });
      expect(word.id, '123');
      expect(word.value, 'test word');
      expect(word.targets, [MutedWordTarget.content, MutedWordTarget.tags]);
      expect(word.actorTarget, MutedWordActorTarget.excludeFollowing);
      expect(word.expiresAt, isNotNull);
    });

    test('isExpired returns true for past dates', () {
      final word = MutedWord(
        id: '1',
        value: 'test',
        targets: [MutedWordTarget.content],
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(word.isExpired, isTrue);
    });

    test('isExpired returns false for future dates', () {
      final word = MutedWord(
        id: '1',
        value: 'test',
        targets: [MutedWordTarget.content],
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(word.isExpired, isFalse);
    });

    test('isExpired returns false when no expiration', () {
      const word = MutedWord(id: '1', value: 'test', targets: [MutedWordTarget.content]);
      expect(word.isExpired, isFalse);
    });
  });

  group('MutedWordsPref', () {
    test('fromJson parses items array', () {
      final pref = MutedWordsPref.fromJson({
        'items': [
          {
            'id': '1',
            'value': 'word1',
            'targets': ['content'],
          },
          {
            'id': '2',
            'value': 'word2',
            'targets': ['tag'],
          },
        ],
      });
      expect(pref.items, hasLength(2));
      expect(pref.items[0].value, 'word1');
      expect(pref.items[1].value, 'word2');
    });

    test('activeItems filters out expired words', () {
      final pref = MutedWordsPref(
        items: [
          const MutedWord(id: '1', value: 'active', targets: [MutedWordTarget.content]),
          MutedWord(
            id: '2',
            value: 'expired',
            targets: [MutedWordTarget.content],
            expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      );
      expect(pref.activeItems, hasLength(1));
      expect(pref.activeItems[0].value, 'active');
    });

    test('round-trip through stored JSON', () {
      const original = MutedWordsPref(
        items: [
          MutedWord(id: '123', value: 'test', targets: [MutedWordTarget.content]),
        ],
      );
      final json = original.toStoredJson();
      final restored = MutedWordsPref.fromStoredJson(json);
      expect(restored.items, hasLength(1));
      expect(restored.items[0].value, 'test');
    });

    test('empty constant works', () {
      expect(MutedWordsPref.empty.items, isEmpty);
    });
  });
}
