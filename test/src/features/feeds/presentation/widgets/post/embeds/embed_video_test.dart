import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_video.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('EmbedVideo', () {
    testWidgets('renders placeholder and play button', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: EmbedVideo(playlist: 'video.m3u8')),
            ),
          ),
        );
      });

      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('shows thumbnail if provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EmbedVideo(
                  playlist: 'video.m3u8',
                  thumbnail: 'https://example.com/thumb.jpg',
                ),
              ),
            ),
          ),
        );
      });
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows duration badge when durationSeconds is provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: EmbedVideo(playlist: 'video.m3u8', durationSeconds: 125)),
            ),
          ),
        );
      });

      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('formats duration correctly for short videos', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: EmbedVideo(playlist: 'video.m3u8', durationSeconds: 45)),
            ),
          ),
        );
      });

      expect(find.text('00:45'), findsOneWidget);
    });

    testWidgets('formats duration correctly for long videos', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: EmbedVideo(playlist: 'video.m3u8', durationSeconds: 3661)),
            ),
          ),
        );
      });

      expect(find.text('61:01'), findsOneWidget);
    });

    testWidgets('hides duration badge when durationSeconds is null', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: EmbedVideo(playlist: 'video.m3u8')),
            ),
          ),
        );
      });

      expect(find.textContaining(':'), findsNothing);
    });

    testWidgets('uses dynamic aspect ratio when provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EmbedVideo(playlist: 'video.m3u8', aspectRatio: {'width': 9, 'height': 16}),
              ),
            ),
          ),
        );
      });

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, closeTo(9 / 16, 0.01));
    });

    testWidgets('defaults to 16:9 when aspect ratio is missing', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: EmbedVideo(playlist: 'video.m3u8')),
            ),
          ),
        );
      });

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, closeTo(16 / 9, 0.01));
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EmbedVideo(playlist: 'video.m3u8', alt: 'A cat playing piano'),
              ),
            ),
          ),
        );
      });

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'A cat playing piano',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('uses default semantic label when alt is null', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: EmbedVideo(playlist: 'video.m3u8')),
            ),
          ),
        );
      });

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Video',
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });
}
