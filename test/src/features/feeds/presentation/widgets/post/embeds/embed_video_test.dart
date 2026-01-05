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

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
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
  });
}
