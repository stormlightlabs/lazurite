import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('Avatar', () {
    const imageUrl = 'https://example.com/avatar.jpg';

    testWidgets('renders CircleAvatar', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Avatar(imageUrl: imageUrl)),
          ),
        );
      });

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders CachedNetworkImage when imageUrl is provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Avatar(imageUrl: imageUrl)),
          ),
        );
      });

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('renders fallback icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Avatar(imageUrl: null, fallbackIcon: Icons.star)),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('respects radius parameter', (tester) async {
      const radius = 30.0;
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Avatar(imageUrl: imageUrl, radius: radius),
            ),
          ),
        );
      });

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, radius);
    });

    testWidgets('wraps in Hero when heroTag is provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Avatar(imageUrl: imageUrl, heroTag: 'avatar_hero'),
            ),
          ),
        );
      });

      expect(find.byType(Hero), findsOneWidget);
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'avatar_hero');
    });
  });
}
