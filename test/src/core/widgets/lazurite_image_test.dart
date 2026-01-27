import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/lazurite_image.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('LazuriteImage', () {
    const imageUrl = 'https://example.com/image.jpg';

    testWidgets('renders CachedNetworkImage when imageUrl is provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: LazuriteImage(imageUrl: imageUrl)),
          ),
        );
      });

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('renders errorWidget when imageUrl is empty', (tester) async {
      const errorKey = Key('error_widget');
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LazuriteImage(
              imageUrl: '',
              errorWidget: SizedBox(key: errorKey),
            ),
          ),
        ),
      );

      expect(find.byKey(errorKey), findsOneWidget);
    });

    testWidgets('renders placeholder while loading', (tester) async {
      const placeholderKey = Key('placeholder_widget');
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LazuriteImage(
                imageUrl: imageUrl,
                placeholder: SizedBox(key: placeholderKey),
              ),
            ),
          ),
        );
      });

      expect(find.byKey(placeholderKey), findsOneWidget);
    });

    testWidgets('applies borderRadius when provided', (tester) async {
      final borderRadius = BorderRadius.circular(12);
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LazuriteImage(imageUrl: imageUrl, borderRadius: borderRadius),
            ),
          ),
        );
      });

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, borderRadius);
    });

    testWidgets('renders fallback icon when error occurs and no errorWidget provided', (
      tester,
    ) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: LazuriteImage(imageUrl: imageUrl)),
          ),
        );
      });

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
