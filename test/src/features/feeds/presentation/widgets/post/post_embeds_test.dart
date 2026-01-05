import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_images.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_video.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_embeds.dart';

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

    testWidgets('handles nested recordWithMedia', (tester) async {
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
