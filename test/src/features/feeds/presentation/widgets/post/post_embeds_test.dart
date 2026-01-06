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
