import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('Avatar', () {
    testWidgets('renders CircleAvatar', (tester) async {
      await tester.pumpApp(const Avatar(imageUrl: null));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows fallback icon when imageUrl is null', (tester) async {
      await tester.pumpApp(const Avatar(imageUrl: null));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows custom fallback icon when provided', (tester) async {
      await tester.pumpApp(const Avatar(imageUrl: null, fallbackIcon: Icons.account_circle));
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('respects custom radius', (tester) async {
      const customRadius = 30.0;
      await tester.pumpApp(const Avatar(imageUrl: null, radius: customRadius));

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, equals(customRadius));
    });

    testWidgets('wraps with Hero when heroTag is provided', (tester) async {
      await tester.pumpApp(const Avatar(imageUrl: null, heroTag: 'test-hero-tag'));

      expect(find.byType(Hero), findsOneWidget);
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, equals('test-hero-tag'));
    });

    testWidgets('does not wrap with Hero when heroTag is null', (tester) async {
      await tester.pumpApp(const Avatar(imageUrl: null));
      expect(find.byType(Hero), findsNothing);
    });

    testWidgets('sets foregroundImage when imageUrl is provided', (tester) async {
      await tester.pumpApp(const Avatar(imageUrl: 'https://example.com/avatar.jpg'));
      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.foregroundImage, isA<NetworkImage>());
    });
  });
}
