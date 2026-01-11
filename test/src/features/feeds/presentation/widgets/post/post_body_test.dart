import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/facet/facet_text.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_body.dart';

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
  group('PostBody', () {
    group('Basic Rendering', () {
      testWidgets('renders text correctly', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: PostBody(text: 'Hello world')),
          ),
        );

        expect(find.text('Hello world'), findsOneWidget);
      });

      testWidgets('renders nothing when text is empty', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: PostBody(text: '')),
          ),
        );

        expect(find.byType(Text), findsNothing);
      });
    });

    group('Facet Integration', () {
      testWidgets('displays post text with facets using FacetText', (tester) async {
        final facets = [
          {
            'index': {'byteStart': 0, 'byteEnd': 8},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:test'},
            ],
          },
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody.withFacets(text: '@mention', facets: facets),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
        final textSpan = _findContentSpan(tester);
        final mentionSpan = _findSpanByText(textSpan, '@mention');
        expect(mentionSpan, isNotNull);
      });

      testWidgets('falls back to plain Text when facets null', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PostBody.withFacets(text: 'Plain text', facets: null)),
          ),
        );

        expect(find.byType(FacetText), findsNothing);
        expect(find.text('Plain text'), findsOneWidget);
      });

      testWidgets('handles posts with only plain text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: PostBody(text: 'Just plain text')),
          ),
        );

        expect(find.text('Just plain text'), findsOneWidget);
      });

      testWidgets('handles posts with rich facets (mention, link, hashtag)', (tester) async {
        final facets = [
          {
            'index': {'byteStart': 0, 'byteEnd': 14},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:alice'},
            ],
          },
          {
            'index': {'byteStart': 15, 'byteEnd': 35},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#link', 'uri': 'https://example.com'},
            ],
          },
          {
            'index': {'byteStart': 36, 'byteEnd': 43},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#tag', 'tag': 'dartlang'},
            ],
          },
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody.withFacets(
                text: '@alice.bsky.social https://example.com #dartlang',
                facets: facets,
              ),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });
    });

    group('Navigation', () {
      late GoRouter router;

      setUp(() {
        router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: PostBody.withFacets(
                  text: '@mention',
                  facets: [
                    {
                      'index': {'byteStart': 0, 'byteEnd': 8},
                      'features': [
                        {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:test'},
                      ],
                    },
                  ],
                ),
              ),
            ),
            GoRoute(
              path: '/home/u/:did',
              builder: (_, _) => const Scaffold(body: Text('Profile Screen')),
            ),
            GoRoute(
              path: '/search',
              builder: (_, _) => const Scaffold(body: Text('Search Screen')),
            ),
          ],
        );
      });

      testWidgets('mention tap navigates to profile screen', (tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        _triggerTapOnText(tester, '@mention');
        await tester.pumpAndSettle();

        expect(find.text('Profile Screen'), findsOneWidget);
      });

      testWidgets('navigation uses correct route parameters for profile', (tester) async {
        const testDid = 'did:plc:abc123';

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => Scaffold(
                    body: PostBody.withFacets(
                      text: '@test',
                      facets: [
                        {
                          'index': {'byteStart': 0, 'byteEnd': 5},
                          'features': [
                            {'\$type': 'app.bsky.richtext.facet#mention', 'did': testDid},
                          ],
                        },
                      ],
                    ),
                  ),
                ),
                GoRoute(
                  path: '/home/u/:did',
                  builder: (context, state) {
                    final did = state.pathParameters['did'];
                    return Scaffold(body: Text('Profile: $did'));
                  },
                ),
              ],
            ),
          ),
        );

        _triggerTapOnText(tester, '@test');
        await tester.pumpAndSettle();

        expect(find.text('Profile: $testDid'), findsOneWidget);
      });

      testWidgets('hashtag tap navigates to search screen', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => Scaffold(
                    body: PostBody.withFacets(
                      text: '#dartlang',
                      facets: [
                        {
                          'index': {'byteStart': 0, 'byteEnd': 9},
                          'features': [
                            {'\$type': 'app.bsky.richtext.facet#tag', 'tag': 'dartlang'},
                          ],
                        },
                      ],
                    ),
                  ),
                ),
                GoRoute(
                  path: '/search',
                  builder: (_, _) => const Scaffold(body: Text('Search Screen')),
                ),
              ],
            ),
          ),
        );

        _triggerTapOnText(tester, '#dartlang');
        await tester.pumpAndSettle();

        expect(find.text('Search Screen'), findsOneWidget);
      });

      testWidgets('search query includes hashtag with encoded #', (tester) async {
        const testTag = 'flutter';

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => Scaffold(
                    body: PostBody.withFacets(
                      text: '#$testTag',
                      facets: [
                        {
                          'index': {'byteStart': 0, 'byteEnd': 8},
                          'features': [
                            {'\$type': 'app.bsky.richtext.facet#tag', 'tag': testTag},
                          ],
                        },
                      ],
                    ),
                  ),
                ),
                GoRoute(
                  path: '/search',
                  builder: (context, state) {
                    final query = state.uri.queryParameters['q'];
                    return Scaffold(body: Text('Search query: $query'));
                  },
                ),
              ],
            ),
          ),
        );

        _triggerTapOnText(tester, '#$testTag');
        await tester.pumpAndSettle();

        expect(find.text('Search query: #$testTag'), findsOneWidget);
      });
    });

    group('Post Model Integration', () {
      testWidgets('loads facets from Post.facets field format', (tester) async {
        final recordJson = {
          'text': 'Hello @alice!',
          'facets': [
            {
              'index': {'byteStart': 6, 'byteEnd': 17},
              'features': [
                {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:alice'},
              ],
            },
          ],
        };

        final facets = recordJson['facets'] as List<dynamic>;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody.withFacets(text: 'Hello @alice!', facets: facets),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('deserializes facets from JSON correctly', (tester) async {
        final facetsJson = jsonEncode([
          {
            'index': {'byteStart': 0, 'byteEnd': 8},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:test'},
            ],
          },
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody(text: '@mention', facetsJson: facetsJson),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
      });

      testWidgets('handles missing facets field in Post model', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody.withFacets(text: 'Plain text without facets', facets: null),
            ),
          ),
        );

        expect(find.text('Plain text without facets'), findsOneWidget);
        expect(find.byType(FacetText), findsNothing);
      });

      testWidgets('passes correct text to FacetText', (tester) async {
        const testText = 'Test post content';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: PostBody(text: testText)),
          ),
        );

        expect(find.text(testText), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('handles malformed facets JSON gracefully', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PostBody(text: 'Test text', facetsJson: 'invalid json {'),
            ),
          ),
        );

        expect(find.text('Test text'), findsOneWidget);
      });

      testWidgets('handles facets with invalid byte offsets', (tester) async {
        final facets = [
          {
            'index': {'byteStart': -1, 'byteEnd': 1000},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:test'},
            ],
          },
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody.withFacets(text: 'Short', facets: facets),
            ),
          ),
        );

        final textSpan = _findContentSpan(tester);
        final plainSpan = _findSpanByText(textSpan, 'Short');
        expect(plainSpan, isNotNull);
      });

      testWidgets('handles facets with unknown feature types', (tester) async {
        final facets = [
          {
            'index': {'byteStart': 0, 'byteEnd': 4},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#unknown', 'data': 'test'},
            ],
          },
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody.withFacets(text: 'Test', facets: facets),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('handles empty facets JSON string', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PostBody(text: 'Plain text', facetsJson: ''),
            ),
          ),
        );

        expect(find.text('Plain text'), findsOneWidget);
      });
    });

    group('Text Styling', () {
      testWidgets('renders plain text with PostBody', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(body: PostBody(text: 'Test')),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('applies theme to facets', (tester) async {
        final facets = [
          {
            'index': {'byteStart': 0, 'byteEnd': 8},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:test'},
            ],
          },
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: const ColorScheme.light(primary: Colors.red)),
            home: Scaffold(
              body: PostBody.withFacets(text: '@mention', facets: facets),
            ),
          ),
        );

        expect(find.byType(RichText), findsOneWidget);
        final textSpan = _findContentSpan(tester);
        final mentionSpan = _findSpanByText(textSpan, '@mention');
        expect(mentionSpan, isNotNull);
      });
    });

    group('Performance', () {
      testWidgets('renders efficiently for text with multiple facets', (tester) async {
        final facets = <Map<String, dynamic>>[];
        var text = 'Post with ';
        var byteCount = 11; // 'Post with '.length

        for (var i = 0; i < 5; i++) {
          final mention = '@user$i ';
          facets.add({
            'index': {'byteStart': byteCount, 'byteEnd': byteCount + mention.length - 1},
            'features': [
              {'\$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:$i'},
            ],
          });
          text += mention;
          byteCount += mention.length;
        }

        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PostBody.withFacets(text: text, facets: facets),
            ),
          ),
        );
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}
