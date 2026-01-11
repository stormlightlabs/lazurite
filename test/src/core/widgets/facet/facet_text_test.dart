import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/facet/facet_text.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';

TextSpan _findContentSpan(WidgetTester tester) {
  final richText = tester.widget<RichText>(find.byType(RichText));
  final rootSpan = richText.text as TextSpan;
  final children = rootSpan.children;

  if (rootSpan.text == null &&
      children != null &&
      children.length == 1 &&
      children.first is TextSpan) {
    return children.first as TextSpan;
  }

  return rootSpan;
}

TextSpan? _findSpanByText(TextSpan span, String matchText) {
  if (span.text == matchText) return span;

  final children = span.children;
  if (children == null) return null;

  for (final child in children) {
    if (child is! TextSpan) continue;
    final match = _findSpanByText(child, matchText);
    if (match != null) return match;
  }

  return null;
}

void _triggerTapOnText(WidgetTester tester, String matchText) {
  final contentSpan = _findContentSpan(tester);
  final targetSpan = _findSpanByText(contentSpan, matchText);
  if (targetSpan == null) {
    throw TestFailure('TextSpan "$matchText" not found');
  }

  final recognizer = targetSpan.recognizer;
  if (recognizer is TapGestureRecognizer && recognizer.onTap != null) {
    recognizer.onTap!();
  }
}

void main() {
  group('FacetText Widget', () {
    group('Rendering', () {
      testWidgets('Renders plain text without facets', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FacetText(text: 'Hello, world!')),
          ),
        );

        expect(find.text('Hello, world!'), findsOneWidget);
      });

      testWidgets('Displays text with default TextStyle', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FacetText(text: 'Test text')),
          ),
        );

        expect(find.text('Test text'), findsOneWidget);
      });

      testWidgets('Handles empty text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FacetText(text: '')),
          ),
        );

        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('Handles very long text (300+ graphemes)', (tester) async {
        final longText = 'Lorem ipsum dolor sit amet. ' * 20;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: FacetText(text: longText)),
          ),
        );

        expect(find.text(longText), findsOneWidget);
      });

      testWidgets('Displays mention facet', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: FacetText(
                text: 'Hello @alice.bsky.social!',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 6, byteEnd: 24),
                    features: [MentionFeature(did: 'did:plc:alice')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textSpan = _findContentSpan(tester);
        expect(textSpan.children, hasLength(3));
        final mentionSpan = textSpan.children![1] as TextSpan;
        expect(mentionSpan.text, equals('@alice.bsky.social'));
      });

      testWidgets('Mention text matches facet range', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@mention',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textSpan = _findContentSpan(tester);
        final mentionSpan = textSpan.children![0] as TextSpan;
        expect(mentionSpan.text, equals('@mention'));
      });

      testWidgets('Displays link facet', (tester) async {
        const linkText = 'https://example.com';
        const text = 'Visit $linkText';
        final linkStart = text.indexOf(linkText);
        final linkEnd = linkStart + linkText.length;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: FacetText(
                text: text,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: linkStart, byteEnd: linkEnd),
                    features: [LinkFeature(uri: linkText)],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
        final textSpan = _findContentSpan(tester);
        final linkSpan = _findSpanByText(textSpan, linkText);
        expect(linkSpan, isNotNull);
      });

      testWidgets('Long URLs render correctly', (tester) async {
        const linkText = 'https://verylongdomainname.example.com/path/to/resource';

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: FacetText(
                text: linkText,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: linkText.length),
                    features: [LinkFeature(uri: linkText)],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
        final textSpan = _findContentSpan(tester);
        final linkSpan = _findSpanByText(textSpan, linkText);
        expect(linkSpan, isNotNull);
      });

      testWidgets('Displays hashtag facet', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: FacetText(
                text: 'Love #dartlang!',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 5, byteEnd: 14),
                    features: [HashtagFeature(tag: 'dartlang')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
        final textSpan = _findContentSpan(tester);
        final hashtagSpan = _findSpanByText(textSpan, '#dartlang');
        expect(hashtagSpan, isNotNull);
      });

      testWidgets('Hashtag includes # symbol', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '#test',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 5),
                    features: [HashtagFeature(tag: 'test')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textSpan = _findContentSpan(tester);
        final hashtagSpan = _findSpanByText(textSpan, '#test');
        expect(hashtagSpan, isNotNull);
      });

      testWidgets('Displays mixed facets (mention, link, hashtag)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@alice check https://bsky.app and #dart',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 14),
                    features: [MentionFeature(did: 'did:plc:alice')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 21, byteEnd: 41),
                    features: [LinkFeature(uri: 'https://bsky.app')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 46, byteEnd: 51),
                    features: [HashtagFeature(tag: 'dart')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('Adjacent facets with no space', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@a@b',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 2),
                    features: [MentionFeature(did: 'did:plc:a')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 2, byteEnd: 4),
                    features: [MentionFeature(did: 'did:plc:b')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });
    });

    group('Tap Handlers', () {
      testWidgets('Tapping mention calls onMentionTap callback', (tester) async {
        var didReceived = '';
        const testDid = 'did:plc:alice';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@alice',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 6),
                    features: [MentionFeature(did: testDid)],
                  ),
                ],
                onMentionTap: (did) {
                  didReceived = did;
                },
              ),
            ),
          ),
        );

        _triggerTapOnText(tester, '@alice');
        await tester.pump();

        expect(didReceived, equals(testDid));
      });

      testWidgets('Only mentions trigger mention callback', (tester) async {
        var callbackCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@mention #hashtag',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 9, byteEnd: 17),
                    features: [HashtagFeature(tag: 'hashtag')],
                  ),
                ],
                onMentionTap: (_) {
                  callbackCount++;
                },
                onHashtagTap: (_) {},
              ),
            ),
          ),
        );

        _triggerTapOnText(tester, '#hashtag');
        await tester.pump();

        expect(callbackCount, equals(0));
      });

      testWidgets('Tapping link calls onLinkTap callback', (tester) async {
        var uriReceived = '';
        const testUri = 'https://example.com';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: testUri,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: testUri.length),
                    features: [LinkFeature(uri: testUri)],
                  ),
                ],
                onLinkTap: (uri) {
                  uriReceived = uri;
                },
              ),
            ),
          ),
        );

        _triggerTapOnText(tester, testUri);
        await tester.pump();

        expect(uriReceived, equals(testUri));
      });

      testWidgets('Tapping hashtag calls onHashtagTap callback', (tester) async {
        var tagReceived = '';
        const testTag = 'dartlang';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '#$testTag',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 9),
                    features: [HashtagFeature(tag: testTag)],
                  ),
                ],
                onHashtagTap: (tag) {
                  tagReceived = tag;
                },
              ),
            ),
          ),
        );

        _triggerTapOnText(tester, '#$testTag');
        await tester.pump();

        expect(tagReceived, equals(testTag));
      });

      testWidgets('Multiple mentions each trigger correct DID', (tester) async {
        final didsReceived = <String>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@alice @bob',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 6),
                    features: [MentionFeature(did: 'did:plc:alice')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 7, byteEnd: 11),
                    features: [MentionFeature(did: 'did:plc:bob')],
                  ),
                ],
                onMentionTap: (did) {
                  didsReceived.add(did);
                },
              ),
            ),
          ),
        );

        _triggerTapOnText(tester, '@alice');
        await tester.pump();
        _triggerTapOnText(tester, '@bob');
        await tester.pump();

        expect(didsReceived, equals(['did:plc:alice', 'did:plc:bob']));
      });

      testWidgets('Tapping facet with null handler does nothing', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@mention',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
                onMentionTap: null,
              ),
            ),
          ),
        );

        _triggerTapOnText(tester, '@mention');
        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Plain text without tap handlers does not crash', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FacetText(text: 'Plain text without facets')),
          ),
        );

        await tester.tap(find.text('Plain text without facets'));
        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Text Constraints', () {
      testWidgets('Respects maxLines parameter', (tester) async {
        const longText = 'Line 1\nLine 2\nLine 3\nLine 4';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FacetText(text: longText, maxLines: 2)),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.maxLines, equals(2));
      });

      testWidgets('Truncates text with facets at maxLines', (tester) async {
        const longText = '@alice\n@bob\n@charlie';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: longText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 6),
                    features: [MentionFeature(did: 'did:plc:alice')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 7, byteEnd: 11),
                    features: [MentionFeature(did: 'did:plc:bob')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 12, byteEnd: 20),
                    features: [MentionFeature(did: 'did:plc:charlie')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.maxLines, equals(2));
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      });

      testWidgets('maxLines=1 shows single line with facets', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@alice @bob',
                maxLines: 1,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 6),
                    features: [MentionFeature(did: 'did:plc:alice')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 7, byteEnd: 11),
                    features: [MentionFeature(did: 'did:plc:bob')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.maxLines, equals(1));
      });

      testWidgets('TextOverflow.ellipsis shows ellipsis with facets', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@alice',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 6),
                    features: [MentionFeature(did: 'did:plc:alice')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      });

      testWidgets('TextOverflow.fade fades text with facets', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: 'Long text here @mention',
                maxLines: 1,
                overflow: TextOverflow.fade,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 14, byteEnd: 22),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.overflow, equals(TextOverflow.fade));
      });

      testWidgets('Supports different TextAlign values', (tester) async {
        for (final align in [TextAlign.left, TextAlign.center, TextAlign.right]) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FacetText(text: 'Test', textAlign: align),
              ),
            ),
          );

          final textWidget = tester.widget<Text>(find.byType(Text));
          expect(textWidget.textAlign, equals(align));
        }
      });
    });

    group('Styling and Theming', () {
      testWidgets('Uses provided style for base text', (tester) async {
        const customStyle = TextStyle(fontSize: 20, color: Color(0xFFABC123));

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FacetText(text: 'Test text', style: customStyle),
            ),
          ),
        );

        expect(find.text('Test text'), findsOneWidget);
      });

      testWidgets('Base style applies to facets', (tester) async {
        const baseStyle = TextStyle(fontSize: 20);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: FacetText(
                text: '@mention',
                style: baseStyle,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('Base style font size applies to facets', (tester) async {
        const baseStyle = TextStyle(fontSize: 24);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@mention',
                style: baseStyle,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('Uses theme for mentions', (tester) async {
        final customTheme = ThemeData(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: customTheme,
            home: Scaffold(
              body: FacetText(
                text: '@mention',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('Uses theme for hashtags', (tester) async {
        final customTheme = ThemeData(
          colorScheme: const ColorScheme.light(secondary: Colors.teal),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: customTheme,
            home: Scaffold(
              body: FacetText(
                text: '#hashtag',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [HashtagFeature(tag: 'hashtag')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('Mention includes semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@alice',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 6),
                    features: [MentionFeature(did: 'did:plc:alice')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textSpan = _findContentSpan(tester);
        final mentionSpan = textSpan.children![0] as TextSpan;

        expect(mentionSpan.semanticsLabel, contains('Mention'));
      });

      testWidgets('Link includes semantic label', (tester) async {
        const linkText = 'https://example.com';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: linkText,
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: linkText.length),
                    features: [LinkFeature(uri: linkText)],
                  ),
                ],
              ),
            ),
          ),
        );

        final textSpan = _findContentSpan(tester);
        final linkSpan = textSpan.children![0] as TextSpan;

        expect(linkSpan.semanticsLabel, contains('Link'));
      });

      testWidgets('Hashtag includes semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '#dart',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 5),
                    features: [HashtagFeature(tag: 'dart')],
                  ),
                ],
              ),
            ),
          ),
        );

        final textSpan = _findContentSpan(tester);
        final hashtagSpan = textSpan.children![0] as TextSpan;

        expect(hashtagSpan.semanticsLabel, contains('Hashtag'));
      });
    });

    group('Edge Cases', () {
      testWidgets('Handles facets with missing features gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: 'Test',
                facets: [Facet(index: FacetIndex(byteStart: 0, byteEnd: 4), features: [])],
              ),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('Handles emoji in mentions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: '@😀test',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 8),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('Handles multi-byte characters in all facet types', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: 'Café @user #café',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 5, byteEnd: 10),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                  Facet(
                    index: FacetIndex(byteStart: 11, byteEnd: 17),
                    features: [HashtagFeature(tag: 'café')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('Handles zero-length facets', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: 'Test',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 0, byteEnd: 0),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('Handles facets with byteStart > byteEnd', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: 'Test',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 5, byteEnd: 2),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('Handles facets with byte offsets beyond text length', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(
                text: 'Short',
                facets: [
                  Facet(
                    index: FacetIndex(byteStart: 100, byteEnd: 200),
                    features: [MentionFeature(did: 'did:plc:test')],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Short'), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('Renders quickly for text with 10 facets', (tester) async {
        final facets = <Facet>[];
        var text = 'Start ';
        for (var i = 0; i < 10; i++) {
          final mention = '@user$i';
          facets.add(
            Facet(
              index: FacetIndex(byteStart: text.length, byteEnd: text.length + mention.length),
              features: [MentionFeature(did: 'did:plc:$i')],
            ),
          );
          text += '$mention ';
        }

        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FacetText(text: text, facets: facets),
            ),
          ),
        );
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}
