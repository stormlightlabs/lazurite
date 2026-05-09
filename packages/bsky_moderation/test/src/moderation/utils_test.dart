import 'package:bsky_moderation/src/types/behaviors/moderation_prefs.dart';
import 'package:bsky_moderation/src/types/behaviors/moderation_prefs_labeler.dart';
import 'package:bsky_moderation/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('.getLabelerHeaders', () {
    test('case1', () {
      final actual = getLabelerHeaders(null);

      expect(actual.containsKey('atproto-accept-labelers'), isTrue);
      expect(actual['atproto-accept-labelers'], 'did:plc:ar7c4by46qjdydhdevvrndac;redact');
    });

    test('case2', () {
      const emptyPref = ModerationPrefs(labels: {}, labelers: [], mutedWords: [], hiddenPosts: []);

      final actual = getLabelerHeaders(emptyPref);

      expect(actual.containsKey('atproto-accept-labelers'), isTrue);
      expect(actual['atproto-accept-labelers'], 'did:plc:ar7c4by46qjdydhdevvrndac;redact');
    });

    test('case3', () {
      final actual = getLabelerHeaders(
        const ModerationPrefs(
          labels: {},
          labelers: [ModerationPrefsLabeler(did: 'did:aaaa', labels: {})],
          mutedWords: [],
          hiddenPosts: [],
        ),
      );

      expect(actual.containsKey('atproto-accept-labelers'), isTrue);
      expect(actual['atproto-accept-labelers'], 'did:plc:ar7c4by46qjdydhdevvrndac;redact, did:aaaa;redact');
    });

    test('case4', () {
      final actual = getLabelerHeaders(
        const ModerationPrefs(
          labels: {},
          labelers: [
            ModerationPrefsLabeler(did: 'did:aaaa', labels: {}),
            ModerationPrefsLabeler(did: 'did:bbbb', labels: {}),
          ],
          mutedWords: [],
          hiddenPosts: [],
        ),
      );

      expect(actual.containsKey('atproto-accept-labelers'), isTrue);
      expect(
        actual['atproto-accept-labelers'],
        'did:plc:ar7c4by46qjdydhdevvrndac;redact, did:aaaa;redact, '
        'did:bbbb;redact',
      );
    });

    test('case5', () {
      final actual = getLabelerHeaders(
        const ModerationPrefs(
          labels: {},
          labelers: [
            ModerationPrefsLabeler(did: 'did:aaaa', labels: {}),
            ModerationPrefsLabeler(did: 'did:aaaa', labels: {}),
          ],
          mutedWords: [],
          hiddenPosts: [],
        ),
      );

      expect(actual.containsKey('atproto-accept-labelers'), isTrue);
      expect(actual['atproto-accept-labelers'], 'did:plc:ar7c4by46qjdydhdevvrndac;redact, did:aaaa;redact');
    });
  });
}
