import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/upload_progress_tile.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('UploadProgressTile', () {
    testWidgets('renders filename', (tester) async {
      await tester.pumpApp(
        const UploadProgressTile(filename: 'image.jpg', status: DraftMediaStatus.pending),
      );
      expect(find.text('image.jpg'), findsOneWidget);
    });

    testWidgets('shows placeholder thumbnail when no path provided', (tester) async {
      await tester.pumpApp(
        const UploadProgressTile(filename: 'test.jpg', status: DraftMediaStatus.pending),
      );
      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('shows pending status', (tester) async {
      await tester.pumpApp(
        const UploadProgressTile(filename: 'test.jpg', status: DraftMediaStatus.pending),
      );
      expect(find.text('Pending'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    });

    testWidgets('shows progress bar when uploading', (tester) async {
      await tester.pumpApp(
        const UploadProgressTile(
          filename: 'test.jpg',
          status: DraftMediaStatus.uploading,
          progress: 0.5,
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows uploaded status with check icon', (tester) async {
      await tester.pumpApp(
        const UploadProgressTile(filename: 'test.jpg', status: DraftMediaStatus.uploaded),
      );
      expect(find.text('Uploaded'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows failed status with retry button', (tester) async {
      var retryCalled = false;
      await tester.pumpApp(
        UploadProgressTile(
          filename: 'test.jpg',
          status: DraftMediaStatus.failed,
          onRetry: () => retryCalled = true,
        ),
      );
      expect(find.text('Failed'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      expect(retryCalled, isTrue);
    });
  });
}
