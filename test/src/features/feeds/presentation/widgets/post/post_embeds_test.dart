import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_external.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_images.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_record.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_video.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_embeds.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('PostEmbeds', () {
    testWidgets('renders specific embed types correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostEmbeds(
                embed: {r'$type': 'app.bsky.embed.images#view', 'images': []},
                authorDid: 'did:example:123',
              ),
            ),
          ),
        ),
      );
      expect(find.byType(EmbedImages), findsOneWidget);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostEmbeds(
                authorDid: 'did:example:123',
                embed: {
                  r'$type': 'app.bsky.embed.video#view',
                  'playlist': 'http://example.com/playlist.m3u8',
                },
              ),
            ),
          ),
        ),
      );
      expect(find.byType(EmbedVideo), findsOneWidget);
    });

    testWidgets('renders external link embed', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PostEmbeds(
                  authorDid: 'did:example:123',
                  embed: {
                    r'$type': 'app.bsky.embed.external#view',
                    'external': {
                      'uri': 'https://example.com/article',
                      'title': 'Example Article',
                      'description': 'An article description',
                    },
                  },
                ),
              ),
            ),
          ),
        );
      });
      expect(find.byType(EmbedExternal), findsOneWidget);
      expect(find.text('Example Article'), findsOneWidget);
    });

    testWidgets('renders record embed (quoted post)', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PostEmbeds(
                  authorDid: 'did:example:123',
                  embed: {
                    r'$type': 'app.bsky.embed.record#view',
                    'record': {
                      r'$type': 'app.bsky.embed.record#viewRecord',
                      'uri': 'at://did:plc:test/app.bsky.feed.post/123',
                      'cid': 'bafycid123',
                      'author': {
                        'did': 'did:plc:test',
                        'handle': 'quoted.bsky.social',
                        'displayName': 'Quoted Author',
                      },
                      'value': {'text': 'This is a quoted post'},
                      'indexedAt': '2024-01-01T00:00:00.000Z',
                    },
                  },
                ),
              ),
            ),
          ),
        );
      });
      expect(find.byType(EmbedRecord), findsOneWidget);
      expect(find.text('This is a quoted post'), findsOneWidget);
    });

    testWidgets('handles nested recordWithMedia with both media and record', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PostEmbeds(
                  authorDid: 'did:example:123',
                  embed: {
                    r'$type': 'app.bsky.embed.recordWithMedia#view',
                    'media': {r'$type': 'app.bsky.embed.images#view', 'images': []},
                    'record': {
                      r'$type': 'app.bsky.embed.record#view',
                      'record': {
                        r'$type': 'app.bsky.embed.record#viewRecord',
                        'uri': 'at://did:plc:test/app.bsky.feed.post/456',
                        'author': {'handle': 'nested.bsky.social'},
                        'value': {'text': 'Nested quoted post'},
                      },
                    },
                  },
                ),
              ),
            ),
          ),
        );
      });

      expect(find.byType(EmbedImages), findsOneWidget);
      expect(find.byType(EmbedRecord), findsOneWidget);
      expect(find.text('Nested quoted post'), findsOneWidget);
    });

    testWidgets('handles recordWithMedia with video + record', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PostEmbeds(
                  authorDid: 'did:example:123',
                  embed: {
                    r'$type': 'app.bsky.embed.recordWithMedia#view',
                    'media': {
                      r'$type': 'app.bsky.embed.video#view',
                      'playlist': 'https://example.com/playlist.m3u8',
                      'thumbnail': 'https://example.com/thumb.jpg',
                    },
                    'record': {
                      r'$type': 'app.bsky.embed.record#view',
                      'record': {
                        r'$type': 'app.bsky.embed.record#viewRecord',
                        'uri': 'at://did:plc:test/app.bsky.feed.post/789',
                        'author': {'handle': 'video.bsky.social'},
                        'value': {'text': 'Quote with video'},
                      },
                    },
                  },
                ),
              ),
            ),
          ),
        );
      });

      expect(find.byType(EmbedVideo), findsOneWidget);
      expect(find.byType(EmbedRecord), findsOneWidget);
      expect(find.text('Quote with video'), findsOneWidget);
    });

    testWidgets('handles recordWithMedia with external link + record', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PostEmbeds(
                  authorDid: 'did:example:123',
                  embed: {
                    r'$type': 'app.bsky.embed.recordWithMedia#view',
                    'media': {
                      r'$type': 'app.bsky.embed.external#view',
                      'external': {
                        'uri': 'https://example.com/article',
                        'title': 'Link Preview',
                        'description': 'Article description',
                      },
                    },
                    'record': {
                      r'$type': 'app.bsky.embed.record#view',
                      'record': {
                        r'$type': 'app.bsky.embed.record#viewRecord',
                        'uri': 'at://did:plc:test/app.bsky.feed.post/101',
                        'author': {'handle': 'link.bsky.social'},
                        'value': {'text': 'Quote with link'},
                      },
                    },
                  },
                ),
              ),
            ),
          ),
        );
      });

      expect(find.byType(EmbedExternal), findsOneWidget);
      expect(find.text('Link Preview'), findsOneWidget);
      expect(find.byType(EmbedRecord), findsOneWidget);
      expect(find.text('Quote with link'), findsOneWidget);
    });

    testWidgets('handles recordWithMedia with missing media gracefully', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PostEmbeds(
                  authorDid: 'did:example:123',
                  embed: {
                    r'$type': 'app.bsky.embed.recordWithMedia#view',
                    'record': {
                      r'$type': 'app.bsky.embed.record#view',
                      'record': {
                        r'$type': 'app.bsky.embed.record#viewRecord',
                        'uri': 'at://did:plc:test/app.bsky.feed.post/102',
                        'author': {'handle': 'nomedia.bsky.social'},
                        'value': {'text': 'No media quote'},
                      },
                    },
                  },
                ),
              ),
            ),
          ),
        );
      });

      expect(find.byType(EmbedRecord), findsOneWidget);
      expect(find.text('No media quote'), findsOneWidget);
    });

    testWidgets('handles recordWithMedia with missing record gracefully', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostEmbeds(
                authorDid: 'did:example:123',
                embed: {
                  r'$type': 'app.bsky.embed.recordWithMedia#view',
                  'media': {r'$type': 'app.bsky.embed.images#view', 'images': []},
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(EmbedImages), findsOneWidget);
      expect(find.byType(EmbedRecord), findsNothing);
    });

    testWidgets('returns empty for unknown types', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostEmbeds(
                embed: {r'$type': 'app.bsky.embed.unknown#view'},
                authorDid: 'did:example:123',
              ),
            ),
          ),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
