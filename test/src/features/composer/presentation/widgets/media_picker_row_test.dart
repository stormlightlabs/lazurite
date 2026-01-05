import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/media_picker_row.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('MediaPickerRow', () {
    testWidgets('shows add button when empty', (tester) async {
      await tester.pumpApp(const MediaPickerRow(mediaPaths: []));
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    });

    testWidgets('fires onAddMedia callback when add button tapped', (tester) async {
      var addCalled = false;
      await tester.pumpApp(
        MediaPickerRow(mediaPaths: const [], onAddMedia: () => addCalled = true),
      );
      await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
      expect(addCalled, isTrue);
    });

    testWidgets('shows thumbnails for provided paths', (tester) async {
      // Since Image.file won't work in tests, we just verify container is rendered
      await tester.pumpApp(
        const MediaPickerRow(mediaPaths: ['/fake/path1.jpg', '/fake/path2.jpg']),
      );
      // Find the broken image icons (since files don't exist)
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsNWidgets(2));
    });

    testWidgets('shows remove buttons when onRemoveMedia is provided', (tester) async {
      await tester.pumpApp(
        MediaPickerRow(mediaPaths: const ['/fake/path.jpg'], onRemoveMedia: (_) {}),
      );
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('fires onRemoveMedia callback with correct index', (tester) async {
      int? removedIndex;
      await tester.pumpApp(
        MediaPickerRow(
          mediaPaths: const ['/fake/path1.jpg', '/fake/path2.jpg'],
          onRemoveMedia: (index) => removedIndex = index,
        ),
      );
      await tester.pump();
      // Tap the first remove button
      await tester.tap(find.byIcon(Icons.close).first);
      expect(removedIndex, 0);
    });

    testWidgets('hides add button when at max media', (tester) async {
      await tester.pumpApp(
        const MediaPickerRow(mediaPaths: ['/1.jpg', '/2.jpg', '/3.jpg', '/4.jpg'], maxMedia: 4),
      );
      await tester.pump();
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsNothing);
    });
  });
}
