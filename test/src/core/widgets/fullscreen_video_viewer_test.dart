import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/video_player_widget.dart';
import 'package:lazurite/src/core/widgets/widgets.dart';

void main() {
  group('FullscreenVideoViewer', () {
    testWidgets('shows loading indicator before initialization', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8')),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders video player after initialization', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('close button is present', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('download button is present when metadata provided', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FullscreenVideoViewer(
                playlist: '/path/to/video.m3u8',
                cid: 'bafyreiabcdef',
                authorDid: 'did:plc:test',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('share button is present when metadata provided', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FullscreenVideoViewer(
                playlist: '/path/to/video.m3u8',
                cid: 'bafyreiabcdef',
                authorDid: 'did:plc:test',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('shows ALT badge when alt text is provided', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FullscreenVideoViewer(
                playlist: '/path/to/video.m3u8',
                alt: 'A cat playing piano',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ALT'), findsOneWidget);
    });

    testWidgets('hides ALT badge when alt text is null', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ALT'), findsNothing);
    });

    testWidgets('alt text button shows dialog', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FullscreenVideoViewer(
                playlist: '/path/to/video.m3u8',
                alt: 'A cat playing piano',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ALT'), findsOneWidget);
      expect(find.byType(FullscreenViewerOverlay), findsOneWidget);
    });

    testWidgets('uses provided aspect ratio', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FullscreenVideoViewer(
                playlist: '/path/to/video.m3u8',
                aspectRatio: {'width': 9, 'height': 16},
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('uses provided duration', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8', durationSeconds: 125),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('video player has autoplay enabled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final videoPlayerWidget = tester.widget<VideoPlayerWidget>(find.byType(VideoPlayerWidget));
      expect(videoPlayerWidget.autoplay, isTrue);
    });

    testWidgets('video player has showControls enabled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final videoPlayerWidget = tester.widget<VideoPlayerWidget>(find.byType(VideoPlayerWidget));
      expect(videoPlayerWidget.showControls, isTrue);
    });

    testWidgets('video player has isExpanded enabled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: FullscreenVideoViewer(playlist: '/path/to/video.m3u8')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final videoPlayerWidget = tester.widget<VideoPlayerWidget>(find.byType(VideoPlayerWidget));
      expect(videoPlayerWidget.isExpanded, isTrue);
    });
  });
}
