import 'package:bluesky_text/bluesky_text.dart';
import 'package:bsky_moderation/src/moderation.dart';
import 'package:bsky_moderation/src/types/behaviors/moderation_cause.dart';
import 'package:bsky_moderation/src/types/behaviors/moderation_opts.dart';
import 'package:bsky_moderation/src/types/behaviors/moderation_prefs.dart';
import 'package:bsky_moderation/src/types/mute_words.dart';
import 'package:bsky_moderation/src/types/subjects/moderation_subject_post.dart';
import 'package:poptart_lex/app/bsky/actor/defs/muted_word.dart';
import 'package:poptart_lex/app/bsky/actor/defs/muted_word_target.dart';
import 'package:poptart_lex/app/bsky/richtext/facet/main.dart';
import 'package:test/test.dart';

import 'utils/mock.dart';

void main() {
  group('hasMutedWord tags', () {
    test('match: outline tag', () async {
      const text = BlueskyText('This is a post #inlineTag');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'outlineTag',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.tag)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: ['outlineTag'],
        ),
        isTrue,
      );
    });

    test('match: inline tag', () async {
      const text = BlueskyText('This is a post #inlineTag');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'inlineTag',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.tag)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: ['outlineTag'],
        ),
        isTrue,
      );
    });

    test('match: content target matches inline tag', () async {
      const text = BlueskyText('This is a post #inlineTag');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'inlineTag',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: ['outlineTag'],
        ),
        isTrue,
      );
    });

    test('no match: only tag targets', () async {
      const text = BlueskyText('This is a post');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'inlineTag',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.tag)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isFalse,
      );
    });

    test('no match: only tag targets', () async {
      const text = BlueskyText('This is a post');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'inlineTag',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.tag)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isFalse,
      );
    });
  });

  group('hasMutedWord early exits', () {
    test('match: single character 希', () async {
      const text = BlueskyText('改善希望です');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: '希',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: single char with length > 1 ☠︎', () async {
      const text = BlueskyText('Idk why ☠︎ but maybe');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: '☠︎',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('no match: long muted word, short post', () async {
      const text = BlueskyText('hey');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'politics',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isFalse,
      );
    });

    test('match: exact text', () async {
      const text = BlueskyText('dart');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'dart',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('hasMutedWord general content', () {
    test('match: word within post', () async {
      const text = BlueskyText('This is a post about dart');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'dart',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('no match: partial word', () async {
      const text = BlueskyText('Use your brain, Eric');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'ai',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isFalse,
      );
    });

    test('match: multiline', () async {
      const text = BlueskyText('Use your\n\tbrain, Eric');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'brain',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: :)', () async {
      const text = BlueskyText('So happy :)');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: ':)',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('hasMutedWord punctuation semi-fuzzy', () {
    test('yay!', () async {
      const text = BlueskyText("We're federating, yay!");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'yay!',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('yay', () async {
      const text = BlueskyText("We're federating, yay!");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'yay',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: y!ppee', () async {
      const text = BlueskyText("We're federating, y!ppee!!");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'y!ppee',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: y!ppee!', () async {
      const text = BlueskyText("We're federating, y!ppee!!");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'y!ppee!',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group("apostrophes: Bluesky's", () {
    test("match: Bluesky's", () async {
      const text = BlueskyText("Yay, Bluesky's mutewords work");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: "Bluesky's",
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: Bluesky', () async {
      const text = BlueskyText("Yay, Bluesky's mutewords work");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'Bluesky',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: blueskys', () async {
      const text = BlueskyText("Yay, Bluesky's mutewords work");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'blueskys',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('Why so S@assy?', () {
    test('match: S@assy', () async {
      const text = BlueskyText('Why so S@assy?');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'S@assy',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: s@assy', () async {
      const text = BlueskyText('Why so S@assy?');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 's@assy',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('New York Times', () {
    test('match: new york times', () async {
      const text = BlueskyText('New York Times');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'new york times',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('!command', () {
    test('match: !command', () async {
      const text = BlueskyText('Idk maybe a bot !command');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: '!command',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: command', () async {
      const text = BlueskyText('Idk maybe a bot !command');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'command',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('no match: !command', () async {
      const text = BlueskyText('Idk maybe a bot command');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: '!command',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isFalse,
      );
    });
  });

  group('e/acc`', () {
    test('match: e/acc', () async {
      const text = BlueskyText("I'm e/acc pilled");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'e/acc',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: acc', () async {
      const text = BlueskyText("I'm e/acc pilled");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'acc',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('super-bad', () {
    test('match: super-bad', () async {
      const text = BlueskyText("I'm super-bad");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'super-bad',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: super', () async {
      const text = BlueskyText("I'm super-bad");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'super',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: bad', () async {
      const text = BlueskyText("I'm super-bad");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'bad',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: super bad', () async {
      const text = BlueskyText("I'm super-bad");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'super bad',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: superbad', () async {
      const text = BlueskyText("I'm super-bad");
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'superbad',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('idk_what_this_would_be', () {
    test('match: idk what this would be', () async {
      const text = BlueskyText('Weird post with idk_what_this_would_be');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'idk what this would be',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('no match: idk what this would be for', () async {
      const text = BlueskyText('Weird post with idk_what_this_would_be');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'idk what this would be for',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isFalse,
      );
    });

    test('match: idk', () async {
      const text = BlueskyText('Weird post with idk_what_this_would_be');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'idk',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: idkwhatthiswouldbe', () async {
      const text = BlueskyText('Weird post with idk_what_this_would_be');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'idkwhatthiswouldbe',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('parentheses', () {
    test('match: context(iykyk)', () async {
      const text = BlueskyText('Post with context(iykyk)');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'context(iykyk)',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: context', () async {
      const text = BlueskyText('Post with context(iykyk)');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'context',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: iykyk', () async {
      const text = BlueskyText('Post with context(iykyk)');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'iykyk',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: (iykyk)', () async {
      const text = BlueskyText('Post with context(iykyk)');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: '(iykyk)',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('🦋', () {
    test('match: 🦋', () async {
      const text = BlueskyText('Post with 🦋');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: '🦋',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('phrases', () {
    test('match: stop worrying', () async {
      const text = BlueskyText(
        'I like turtles, or how I learned to stop worrying and love '
        'the internet.',
      );
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'stop worrying',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });

    test('match: turtles, or how', () async {
      const text = BlueskyText(
        'I like turtles, or how I learned to stop worrying and love '
        'the internet.',
      );
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'turtles, or how',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
        ),
        isTrue,
      );
    });
  });

  group('languages without spaces', () {
    test('match: インターネット', () async {
      const text = BlueskyText('私はカメが好きです、またはどのようにして心配するのをやめてインターネットを愛するようになったのか');
      final facets = await text.entities.toFacets();

      expect(
        hasMutedWord(
          mutedWords: [
            const MutedWord(
              value: 'インターネット',
              targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
            ),
          ],
          text: text.value,
          facets: facets.map(RichtextFacet.fromJson).toList(),
          outlineTags: [],
          languages: ['ja'],
        ),
        isTrue,
      );
    });
  });

  group("doesn't mute own post", () {
    test("does mute if it isn't own post", () async {
      final actual = moderatePost(
        ModerationSubjectPost.postView(
          data: postView(
            record: post(text: 'Mute words!'),
            author: profileViewBasic(handle: 'bob.test', displayName: 'Bob'),
          ),
        ),
        const ModerationOpts(
          userDid: 'did:web:alice.test',
          prefs: ModerationPrefs(
            adultContentEnabled: false,
            labels: {},
            labelers: [],
            mutedWords: [
              MutedWord(
                value: 'words',
                targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
              ),
            ],
            hiddenPosts: [],
          ),
        ),
      );

      expect(actual.causes.firstOrNull, isA<UModerationCauseMuteWord>());
    });

    test("doesn't mute own post when muted word is in text", () async {
      final actual = moderatePost(
        ModerationSubjectPost.postView(
          data: postView(
            record: post(text: 'Mute words!'),
            author: profileViewBasic(handle: 'bob.test', displayName: 'Bob'),
          ),
        ),
        const ModerationOpts(
          userDid: 'did:web:bob.test',
          prefs: ModerationPrefs(
            adultContentEnabled: false,
            labels: {},
            labelers: [],
            mutedWords: [
              MutedWord(
                value: 'words',
                targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.content)],
              ),
            ],
            hiddenPosts: [],
          ),
        ),
      );

      expect(actual.causes.isEmpty, isTrue);
    });

    test("doesn't mute own post when muted word is in tags", () async {
      const text = BlueskyText('Mute #words!');
      final facets = await text.entities.toFacets();

      final actual = moderatePost(
        ModerationSubjectPost.postView(
          data: postView(
            record: post(text: text.value, facets: facets.map(RichtextFacet.fromJson).toList()),
            author: profileViewBasic(handle: 'bob.test', displayName: 'Bob'),
          ),
        ),
        const ModerationOpts(
          userDid: 'did:web:bob.test',
          prefs: ModerationPrefs(
            adultContentEnabled: false,
            labels: {},
            labelers: [],
            mutedWords: [
              MutedWord(
                value: 'words',
                targets: [MutedWordTarget.knownValue(data: KnownMutedWordTarget.tag)],
              ),
            ],
            hiddenPosts: [],
          ),
        ),
      );

      expect(actual.causes.isEmpty, isTrue);
    });
  });
}
