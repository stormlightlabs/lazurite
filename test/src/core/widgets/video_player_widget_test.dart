import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/video_player_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoPlayerWidget', () {
    testWidgets('builds without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4')),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('builds with showControls parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', showControls: true),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('builds with showControls set to false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', showControls: false),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('builds with onExpandTap callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', onExpandTap: () {}),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('builds with autoplay parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', autoplay: true),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('builds with isExpanded false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', isExpanded: false),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('builds with isExpanded true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', isExpanded: true),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('handles videoPath parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: VideoPlayerWidget(videoPath: '/path/to/video.mp4')),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('maintains state when parameters change', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', isExpanded: false),
          ),
        ),
      );

      await tester.pump();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(videoPath: '/tmp/test_video.mp4', isExpanded: true),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });
  });
}
