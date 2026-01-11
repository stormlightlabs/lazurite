import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/facet/facet_span_builder.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';

void main() {
  group('FacetSpanBuilder.buildTextSpans', () {
    group('Plain Text (No Facets)', () {
      testWidgets('Returns single TextSpan for empty facets list', (tester) async {
        const text = 'Hello, world!';
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, [], capturedContext!);
        expect(span.text, equals(text));
        expect(span.children, isNull);
      });

      testWidgets('TextSpan contains full text content', (tester) async {
        const text = 'The quick brown fox jumps over the lazy dog.';
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, [], capturedContext!);
        expect(span.text, equals(text));
      });

      testWidgets('TextSpan uses default style when no baseStyle provided', (tester) async {
        const text = 'Test text';
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, [], capturedContext!);
        expect(span.style, isNull);
      });

      testWidgets('TextSpan uses provided baseStyle', (tester) async {
        const baseStyle = TextStyle(fontSize: 20, color: Color(0xFFABC123));
        const text = 'Test text';
        final builder = FacetSpanBuilder(baseStyle: baseStyle);

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, [], capturedContext!);
        expect(span.text, equals(text));
      });
    });

    group('Single Facet Types', () {
      testWidgets('Mention facet produces styled TextSpan', (tester) async {
        const text = 'Hello @alice.bsky.social!';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 6, byteEnd: 24),
            features: [MentionFeature(did: 'did:plc:alice123')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, isNotNull);
        expect(span.children!.length, equals(3)); // 'Hello ', mention, '!'

        final mentionSpan = span.children![1] as TextSpan;
        expect(mentionSpan.text, equals('@alice.bsky.social'));
        expect(mentionSpan.semanticsLabel, equals('Mention: @alice.bsky.social'));
      });

      testWidgets('Link facet produces styled TextSpan', (tester) async {
        const text = 'Check https://example.com';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 6, byteEnd: 26),
            features: [LinkFeature(uri: 'https://example.com')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, isNotNull);
        expect(span.children!.length, equals(2));

        final linkSpan = span.children![1] as TextSpan;
        expect(linkSpan.text, equals('https://example.com'));
        expect(linkSpan.semanticsLabel, equals('Link: https://example.com'));
      });

      testWidgets('Hashtag facet produces styled TextSpan', (tester) async {
        const text = 'Love #dartlang!';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 5, byteEnd: 14),
            features: [HashtagFeature(tag: 'dartlang')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, isNotNull);
        expect(span.children!.length, equals(3)); // 'Love ', hashtag, '!'

        final hashtagSpan = span.children![1] as TextSpan;
        expect(hashtagSpan.text, equals('#dartlang'));
        expect(hashtagSpan.semanticsLabel, equals('Hashtag: #dartlang'));
      });

      testWidgets('Facet text matches text substring at byte offsets', (tester) async {
        const text = 'Hello @world!';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 6, byteEnd: 12),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        final mentionSpan = span.children![1] as TextSpan;
        expect(mentionSpan.text, equals('@world'));
      });
    });

    group('Multiple Facets', () {
      testWidgets('Handles multiple non-overlapping facets', (tester) async {
        const text = 'Hey @alice, check https://bsky.app and #dart!';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 4, byteEnd: 11),
            features: [MentionFeature(did: 'did:plc:alice')],
          ),
          Facet(
            index: FacetIndex(byteStart: 18, byteEnd: 34),
            features: [LinkFeature(uri: 'https://bsky.app')],
          ),
          Facet(
            index: FacetIndex(byteStart: 39, byteEnd: 44),
            features: [HashtagFeature(tag: 'dart')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children!.length, equals(7));
      });

      testWidgets('Sorts facets by byte offset correctly', (tester) async {
        const text = 'A B C';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 4, byteEnd: 5),
            features: [MentionFeature(did: 'did:c')],
          ),
          Facet(
            index: FacetIndex(byteStart: 0, byteEnd: 1),
            features: [MentionFeature(did: 'did:a')],
          ),
          Facet(
            index: FacetIndex(byteStart: 2, byteEnd: 3),
            features: [MentionFeature(did: 'did:b')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, isNotNull);
      });

      testWidgets('Inserts plain text spans between facets', (tester) async {
        const text = 'Start @mention middle #tag end';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 6, byteEnd: 14),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
          Facet(
            index: FacetIndex(byteStart: 22, byteEnd: 26),
            features: [HashtagFeature(tag: 'tag')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children!.length, greaterThan(2));
      });
    });

    group('Edge Cases', () {
      testWidgets('Empty text with facets returns empty spans', (tester) async {
        const text = '';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 0, byteEnd: 5),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.text?.isEmpty ?? true, isTrue);
      });

      testWidgets('Facets with byte offsets beyond text length are skipped', (tester) async {
        const text = 'Short';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 100, byteEnd: 200),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, hasLength(1));
        expect((span.children![0] as TextSpan).text, equals(text));
      });

      testWidgets('Facets with negative byte offsets are skipped', (tester) async {
        const text = 'Test';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: -5, byteEnd: -1),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, hasLength(1));
        expect((span.children![0] as TextSpan).text, equals(text));
      });

      testWidgets('Facets with byteStart > byteEnd are skipped', (tester) async {
        const text = 'Test';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 5, byteEnd: 2),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, hasLength(1));
        expect((span.children![0] as TextSpan).text, equals(text));
      });

      testWidgets('Facets covering entire text work correctly', (tester) async {
        const text = '@mention';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 0, byteEnd: 8),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, isNotNull);
        expect(span.children!.length, equals(1));
        final mentionSpan = span.children![0] as TextSpan;
        expect(mentionSpan.text, equals('@mention'));
      });

      testWidgets('Unknown facet type falls back to plain text', (tester) async {
        const text = 'Test';
        final facets = [Facet(index: FacetIndex(byteStart: 0, byteEnd: 4), features: [])];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        expect(span.children, isNotNull);
        expect(span.children!.length, equals(1));
        final plainSpan = span.children!.first as TextSpan;
        expect(plainSpan.text, equals(text));
      });
    });

    group('Character Offset Conversion', () {
      testWidgets('Correctly converts UTF-8 byte offsets to character offsets', (tester) async {
        const text = 'aébc'; // é is 2 bytes in UTF-8
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 1, byteEnd: 3), // 'é' in bytes
            features: [LinkFeature(uri: 'https://test.com')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        final linkSpan = span.children![1] as TextSpan;
        expect(linkSpan.text, equals('é'));
      });

      testWidgets('Handles emoji in facet text', (tester) async {
        const text = 'Hi 😀 bye';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 3, byteEnd: 7),
            features: [HashtagFeature(tag: 'emoji')],
          ),
        ];
        final builder = FacetSpanBuilder();

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final span = builder.build(text, facets, capturedContext!);
        final hashtagSpan = span.children![1] as TextSpan;
        expect(hashtagSpan.text, equals('😀'));
      });
    });

    group('Tap Gesture Recognizers', () {
      testWidgets('Creates recognizer for mention when onMentionTap provided', (tester) async {
        const text = '@mention';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 0, byteEnd: 8),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final builder = FacetSpanBuilder();
        final span = builder.build(text, facets, capturedContext!, onMentionTap: () {});

        final mentionSpan = span.children![0] as TextSpan;
        expect(mentionSpan.recognizer, isNotNull);
      });

      testWidgets('Does not create recognizer when onMentionTap is null', (tester) async {
        const text = '@mention';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 0, byteEnd: 8),
            features: [MentionFeature(did: 'did:plc:test')],
          ),
        ];

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final builder = FacetSpanBuilder();
        final span = builder.build(text, facets, capturedContext!);

        final mentionSpan = span.children![0] as TextSpan;
        expect(mentionSpan.recognizer, isNull);
      });

      testWidgets('Creates recognizer for link when onLinkTap provided', (tester) async {
        const text = 'https://example.com';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 0, byteEnd: 18),
            features: [LinkFeature(uri: 'https://example.com')],
          ),
        ];

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final builder = FacetSpanBuilder();
        final span = builder.build(text, facets, capturedContext!, onLinkTap: () {});

        final linkSpan = span.children![0] as TextSpan;
        expect(linkSpan.recognizer, isNotNull);
      });

      testWidgets('Creates recognizer for hashtag when onHashtagTap provided', (tester) async {
        const text = '#hashtag';
        final facets = [
          Facet(
            index: FacetIndex(byteStart: 0, byteEnd: 8),
            features: [HashtagFeature(tag: 'hashtag')],
          ),
        ];

        BuildContext? capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );

        final builder = FacetSpanBuilder();
        final span = builder.build(text, facets, capturedContext!, onHashtagTap: () {});

        final hashtagSpan = span.children![0] as TextSpan;
        expect(hashtagSpan.recognizer, isNotNull);
      });
    });
  });
}
