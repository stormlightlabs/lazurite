import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_record.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('EmbedRecord', () {
    group('viewRecord (quoted posts)', () {
      testWidgets('renders author display name and handle', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.embed.record#viewRecord',
                    'uri': 'at://did:plc:test/app.bsky.feed.post/123',
                    'cid': 'bafycid123',
                    'author': {
                      'did': 'did:plc:test',
                      'handle': 'test.bsky.social',
                      'displayName': 'Test User',
                      'avatar': 'https://example.com/avatar.jpg',
                    },
                    'value': {
                      r'$type': 'app.bsky.feed.post',
                      'text': 'This is a quoted post!',
                      'createdAt': '2024-01-01T00:00:00.000Z',
                    },
                    'indexedAt': '2024-01-01T00:00:00.000Z',
                  },
                ),
              ),
            ),
          );
        });

        expect(find.byType(RichText), findsAtLeastNWidgets(1));
        expect(find.text('This is a quoted post!'), findsOneWidget);
      });

      testWidgets('renders handle only when no display name', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.embed.record#viewRecord',
                    'uri': 'at://did:plc:test/app.bsky.feed.post/123',
                    'author': {'did': 'did:plc:test', 'handle': 'noname.bsky.social'},
                    'value': {'text': 'Hello'},
                  },
                ),
              ),
            ),
          );
        });

        expect(find.byType(RichText), findsAtLeastNWidgets(1));
        expect(find.text('Hello'), findsOneWidget);
      });

      testWidgets('renders nested image embeds', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.embed.record#viewRecord',
                    'uri': 'at://did:plc:test/app.bsky.feed.post/123',
                    'author': {'did': 'did:plc:test', 'handle': 'test.bsky.social'},
                    'value': {'text': 'With images'},
                    'embeds': [
                      {
                        r'$type': 'app.bsky.embed.images#view',
                        'images': [
                          {
                            'thumb': 'https://example.com/img.jpg',
                            'fullsize': 'https://example.com/img.jpg',
                          },
                        ],
                      },
                    ],
                  },
                ),
              ),
            ),
          );
        });

        expect(find.byIcon(Icons.download), findsOneWidget);
      });

      testWidgets('is tappable', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.embed.record#viewRecord',
                    'uri': 'at://did:plc:test/app.bsky.feed.post/123',
                    'author': {'handle': 'test.bsky.social'},
                    'value': {'text': 'Test'},
                  },
                ),
              ),
            ),
          );
        });

        expect(find.byType(GestureDetector), findsOneWidget);
      });
    });

    group('error states', () {
      testWidgets('renders viewNotFound state', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedRecord(
                record: {
                  r'$type': 'app.bsky.embed.record#viewNotFound',
                  'uri': 'at://did:plc:test/app.bsky.feed.post/deleted',
                  'notFound': true,
                },
              ),
            ),
          ),
        );

        expect(find.text('Post not found'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
      });

      testWidgets('renders viewBlocked state', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedRecord(
                record: {
                  r'$type': 'app.bsky.embed.record#viewBlocked',
                  'uri': 'at://did:plc:blocked/app.bsky.feed.post/123',
                  'blocked': true,
                  'author': {'did': 'did:plc:blocked'},
                },
              ),
            ),
          ),
        );

        expect(find.text('Blocked content'), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
      });

      testWidgets('renders viewDetached state', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedRecord(
                record: {
                  r'$type': 'app.bsky.embed.record#viewDetached',
                  'uri': 'at://did:plc:test/app.bsky.feed.post/detached',
                  'detached': true,
                },
              ),
            ),
          ),
        );

        expect(find.text('Content unavailable'), findsOneWidget);
        expect(find.byIcon(Icons.link_off), findsOneWidget);
      });
    });

    group('special record types', () {
      testWidgets('renders feed generator', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.feed.defs#generatorView',
                    'uri': 'at://did:plc:creator/app.bsky.feed.generator/hot',
                    'cid': 'bafycid123',
                    'displayName': 'Hot Feed',
                    'description': 'The hottest posts on Bluesky',
                    'avatar': 'https://example.com/feed.jpg',
                    'creator': {'did': 'did:plc:creator', 'handle': 'creator.bsky.social'},
                    'likeCount': 150,
                    'indexedAt': '2024-01-01T00:00:00.000Z',
                  },
                ),
              ),
            ),
          );
        });

        expect(find.text('Hot Feed'), findsOneWidget);
        expect(find.text('by @creator.bsky.social'), findsOneWidget);
        expect(find.text('The hottest posts on Bluesky'), findsOneWidget);
        expect(find.byIcon(Icons.rss_feed), findsAtLeastNWidgets(1));
      });

      testWidgets('renders list', (tester) async {
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.graph.defs#listView',
                    'uri': 'at://did:plc:creator/app.bsky.graph.list/mylist',
                    'cid': 'bafycid123',
                    'name': 'Cool People',
                    'description': 'A list of cool people',
                    'purpose': 'app.bsky.graph.defs#curatelist',
                    'creator': {'did': 'did:plc:creator', 'handle': 'curator.bsky.social'},
                    'indexedAt': '2024-01-01T00:00:00.000Z',
                  },
                ),
              ),
            ),
          );
        });

        expect(find.text('Cool People'), findsOneWidget);
        expect(find.textContaining('Curated List'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsNWidgets(2));
      });

      testWidgets('renders moderation list', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedRecord(
                record: {
                  r'$type': 'app.bsky.graph.defs#listView',
                  'uri': 'at://did:plc:mod/app.bsky.graph.list/blocklist',
                  'name': 'Spam Accounts',
                  'purpose': 'app.bsky.graph.defs#modlist',
                  'creator': {'handle': 'mod.bsky.social'},
                },
              ),
            ),
          ),
        );

        expect(find.text('Spam Accounts'), findsOneWidget);
        expect(find.textContaining('Moderation List'), findsOneWidget);
        expect(find.byIcon(Icons.shield), findsNWidgets(2));
      });

      testWidgets('renders starter pack', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedRecord(
                record: {
                  r'$type': 'app.bsky.graph.defs#starterPackViewBasic',
                  'uri': 'at://did:plc:creator/app.bsky.graph.starterpack/pack1',
                  'cid': 'bafycid123',
                  'name': 'My Starter Pack',
                  'creator': {'did': 'did:plc:creator', 'handle': 'inviter.bsky.social'},
                  'listItemCount': 25,
                  'indexedAt': '2024-01-01T00:00:00.000Z',
                },
              ),
            ),
          ),
        );

        expect(find.text('My Starter Pack'), findsOneWidget);
        expect(find.textContaining('Starter Pack'), findsAtLeastNWidgets(1));
        expect(find.text('25 people'), findsOneWidget);
        expect(find.byIcon(Icons.rocket_launch), findsNWidgets(2));
      });
    });

    testWidgets('returns empty for unknown type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmbedRecord(
              record: {r'$type': 'app.bsky.unknown#type', 'uri': 'at://did:plc:test/unknown/123'},
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    group('theming', () {
      testWidgets('quoted post uses surfaceContainer for background', (tester) async {
        const containerColor = Color(0xFF2A2A2A);
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                colorScheme: const ColorScheme.dark(surfaceContainer: containerColor),
              ),
              home: const Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.embed.record#viewRecord',
                    'uri': 'at://did:plc:test/app.bsky.feed.post/123',
                    'author': {'handle': 'test.bsky.social'},
                    'value': {'text': 'Test'},
                  },
                ),
              ),
            ),
          );
        });

        final container = tester.widget<Container>(
          find.descendant(of: find.byType(EmbedRecord), matching: find.byType(Container)).first,
        );

        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.color, equals(containerColor));
      });

      testWidgets('error state uses surfaceContainer for background', (tester) async {
        const containerColor = Color(0xFF3B3B3B);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.dark(surfaceContainer: containerColor),
            ),
            home: const Scaffold(
              body: EmbedRecord(
                record: {
                  r'$type': 'app.bsky.embed.record#viewNotFound',
                  'uri': 'at://did:plc:test/app.bsky.feed.post/deleted',
                },
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(of: find.byType(EmbedRecord), matching: find.byType(Container)).first,
        );

        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.color, equals(containerColor));
      });

      testWidgets('uses outlineVariant for border', (tester) async {
        const borderColor = Color(0xFF555555);
        await mockNetworkImages(() async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(colorScheme: const ColorScheme.dark(outlineVariant: borderColor)),
              home: const Scaffold(
                body: EmbedRecord(
                  record: {
                    r'$type': 'app.bsky.embed.record#viewRecord',
                    'uri': 'at://did:plc:test/app.bsky.feed.post/123',
                    'author': {'handle': 'test.bsky.social'},
                    'value': {'text': 'Test'},
                  },
                ),
              ),
            ),
          );
        });

        final container = tester.widget<Container>(
          find.descendant(of: find.byType(EmbedRecord), matching: find.byType(Container)).first,
        );

        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.border, isNotNull);
        final border = decoration?.border as Border?;
        expect(border?.top.color, equals(borderColor));
      });
    });
  });
}
