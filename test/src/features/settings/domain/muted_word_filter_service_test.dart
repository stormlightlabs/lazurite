import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/settings/domain/muted_word_filter_service.dart';

void main() {
  group('MutedWordFilterService', () {
    group('Content matching', () {
      test('matches exact word in content', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: 'This is spam'), isTrue);
        expect(service.shouldMutePost(text: 'spam everywhere'), isTrue);
        expect(service.shouldMutePost(text: 'SPAM in caps'), isTrue);
      });

      test('respects word boundaries', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'cat', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: 'I love cats'), isTrue);
        expect(service.shouldMutePost(text: 'A cat is here'), isTrue);
        expect(service.shouldMutePost(text: 'category'), isFalse);
        expect(service.shouldMutePost(text: 'scattered'), isFalse);
      });

      test('matches multi-word phrases', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'bad phrase', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: 'This is a bad phrase here'), isTrue);
        expect(service.shouldMutePost(text: 'bad phrase'), isTrue);
        expect(service.shouldMutePost(text: 'bad word'), isFalse);
      });

      test('is case-insensitive', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'Test', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: 'test'), isTrue);
        expect(service.shouldMutePost(text: 'TEST'), isTrue);
        expect(service.shouldMutePost(text: 'TeSt'), isTrue);
      });

      test('does not match when target is tags only', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.tags]),
          ],
        );

        expect(service.shouldMutePost(text: 'This is spam'), isFalse);
      });
    });

    group('Tag matching', () {
      test('matches exact tag', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.tags]),
          ],
        );

        expect(service.shouldMutePost(text: 'Post', tags: ['spam']), isTrue);
        expect(service.shouldMutePost(text: 'Post', tags: ['SPAM']), isTrue);
        expect(service.shouldMutePost(text: 'Post', tags: ['other']), isFalse);
      });

      test('matches tag in list', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'bad', targets: [MutedWordTarget.tags]),
          ],
        );

        expect(service.shouldMutePost(text: 'Post', tags: ['good', 'bad', 'other']), isTrue);
        expect(service.shouldMutePost(text: 'Post', tags: ['good', 'other']), isFalse);
      });

      test('does not match when target is content only', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: 'Post', tags: ['spam']), isFalse);
      });
    });

    group('Multiple targets', () {
      test('matches when both content and tags are targeted', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(
              id: '1',
              value: 'spam',
              targets: [MutedWordTarget.content, MutedWordTarget.tags],
            ),
          ],
        );

        expect(service.shouldMutePost(text: 'This is spam'), isTrue);
        expect(service.shouldMutePost(text: 'Post', tags: ['spam']), isTrue);
        expect(service.shouldMutePost(text: 'This is spam', tags: ['spam']), isTrue);
        expect(service.shouldMutePost(text: 'Clean', tags: ['clean']), isFalse);
      });
    });

    group('Actor target filtering', () {
      test('mutes from all accounts when actorTarget is all', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(
              id: '1',
              value: 'spam',
              targets: [MutedWordTarget.content],
              actorTarget: MutedWordActorTarget.all,
            ),
          ],
        );

        expect(service.shouldMutePost(text: 'spam', isFollowing: false), isTrue);
        expect(service.shouldMutePost(text: 'spam', isFollowing: true), isTrue);
      });

      test('excludes following when actorTarget is excludeFollowing', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(
              id: '1',
              value: 'spam',
              targets: [MutedWordTarget.content],
              actorTarget: MutedWordActorTarget.excludeFollowing,
            ),
          ],
        );

        expect(service.shouldMutePost(text: 'spam', isFollowing: false), isTrue);
        expect(service.shouldMutePost(text: 'spam', isFollowing: true), isFalse);
      });
    });

    group('Multiple muted words', () {
      test('matches any muted word', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
            MutedWord(id: '2', value: 'scam', targets: [MutedWordTarget.content]),
            MutedWord(id: '3', value: 'bot', targets: [MutedWordTarget.tags]),
          ],
        );

        expect(service.shouldMutePost(text: 'This is spam'), isTrue);
        expect(service.shouldMutePost(text: 'This is a scam'), isTrue);
        expect(service.shouldMutePost(text: 'Post', tags: ['bot']), isTrue);
        expect(service.shouldMutePost(text: 'Clean post'), isFalse);
      });
    });

    group('Empty muted words', () {
      test('does not mute when list is empty', () {
        const service = MutedWordFilterService(mutedWords: []);

        expect(service.shouldMutePost(text: 'Any text'), isFalse);
        expect(service.shouldMutePost(text: 'Text', tags: ['tag']), isFalse);
      });
    });

    group('getMatchingMutedWords', () {
      test('returns all matching muted words', () {
        const words = [
          MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          MutedWord(id: '2', value: 'scam', targets: [MutedWordTarget.content]),
          MutedWord(id: '3', value: 'bot', targets: [MutedWordTarget.tags]),
        ];
        const service = MutedWordFilterService(mutedWords: words);

        final matches = service.getMatchingMutedWords(
          text: 'This is spam and a scam',
          tags: ['bot'],
        );

        expect(matches.length, equals(3));
        expect(matches.map((w) => w.id), containsAll(['1', '2', '3']));
      });

      test('returns empty list when nothing matches', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          ],
        );

        final matches = service.getMatchingMutedWords(text: 'Clean post');

        expect(matches, isEmpty);
      });

      test('respects actor target in matching', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(
              id: '1',
              value: 'test',
              targets: [MutedWordTarget.content],
              actorTarget: MutedWordActorTarget.excludeFollowing,
            ),
          ],
        );

        final matchesNotFollowing = service.getMatchingMutedWords(
          text: 'test',
          isFollowing: false,
        );
        expect(matchesNotFollowing.length, equals(1));

        final matchesFollowing = service.getMatchingMutedWords(text: 'test', isFollowing: true);
        expect(matchesFollowing, isEmpty);
      });
    });

    group('hasMatchingMutedWords', () {
      test('returns true when matches exist', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.hasMatchingMutedWords(text: 'This is spam'), isTrue);
        expect(service.hasMatchingMutedWords(text: 'Clean'), isFalse);
      });
    });

    group('Edge cases', () {
      test('handles empty text', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: ''), isFalse);
      });

      test('handles special regex characters in muted words', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: 'c++', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: 'I love c++'), isTrue);
        expect(service.shouldMutePost(text: 'I love c'), isFalse);
      });

      test('handles unicode and emoji', () {
        const service = MutedWordFilterService(
          mutedWords: [
            MutedWord(id: '1', value: '🚫', targets: [MutedWordTarget.content]),
          ],
        );

        expect(service.shouldMutePost(text: 'No entry 🚫 here'), isTrue);
        expect(service.shouldMutePost(text: 'Clean post'), isFalse);
      });
    });
  });
}
