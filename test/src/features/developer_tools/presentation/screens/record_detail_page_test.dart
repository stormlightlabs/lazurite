import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';
import 'package:lazurite/src/features/developer_tools/presentation/screens/record_detail_page.dart';

void main() {
  group('RecordDetailPage', () {
    const testCollection = 'app.bsky.feed.post';
    const testRkey = 'abc123';
    const testDid = 'did:plc:test123';

    final testRecord = RepoRecord(
      uri: 'at://$testDid/$testCollection/$testRkey',
      cid: 'bafyreiabc123456789abcdef',
      value: {
        r'$type': 'app.bsky.feed.post',
        'text': 'Hello, world! This is a test post.',
        'createdAt': '2026-01-09T00:00:00.000Z',
      },
      indexedAt: DateTime.parse('2026-01-09T00:00:00.000Z'),
    );

    Widget createSubject({RepoRecord? record, bool returnNull = false}) {
      return ProviderScope(
        overrides: [
          recordDetailProvider(
            testDid,
            testCollection,
            testRkey,
          ).overrideWith((ref) async => returnNull ? null : (record ?? testRecord)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const RecordDetailPage(did: testDid, collection: testCollection, rkey: testRkey),
        ),
      );
    }

    Future<void> pumpWithFrames(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('renders metadata header with AT URI', (tester) async {
      await tester.pumpWidget(createSubject());
      await pumpWithFrames(tester);

      expect(find.text('Metadata'), findsOneWidget);
      expect(find.text('AT URI'), findsOneWidget);
      expect(find.textContaining('at://$testDid'), findsOneWidget);
    });

    testWidgets('renders metadata header with CID', (tester) async {
      await tester.pumpWidget(createSubject());
      await pumpWithFrames(tester);

      expect(find.text('CID'), findsOneWidget);
      expect(find.textContaining('bafyreiabc123456789abcdef'), findsOneWidget);
    });

    testWidgets('renders metadata header with indexed timestamp', (tester) async {
      await tester.pumpWidget(createSubject());
      await pumpWithFrames(tester);

      expect(find.text('Indexed At'), findsOneWidget);
      expect(find.textContaining('2026-01-09'), findsOneWidget);
    });

    testWidgets('renders JSON tree section', (tester) async {
      await tester.pumpWidget(createSubject());
      await pumpWithFrames(tester);

      expect(find.text('Record Value'), findsOneWidget);
    });

    testWidgets('copies AT URI to clipboard when copy button is tapped', (tester) async {
      final log = <MethodCall>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(createSubject());
      await pumpWithFrames(tester);

      final copyButtons = find.byIcon(Icons.copy);
      expect(copyButtons, findsAtLeastNWidgets(2));

      await tester.tap(copyButtons.first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final clipboardCalls = log.where((c) => c.method == 'Clipboard.setData');
      expect(clipboardCalls, isNotEmpty);
    });

    testWidgets('displays Record not found for null record', (tester) async {
      await tester.pumpWidget(createSubject(returnNull: true));
      await pumpWithFrames(tester);

      expect(find.text('Record not found'), findsOneWidget);
    });

    group('Blob detection', () {
      testWidgets('detects and displays blob references', (tester) async {
        final recordWithBlob = RepoRecord(
          uri: 'at://$testDid/$testCollection/$testRkey',
          cid: 'bafyreiabc123456789abcdef',
          value: {
            r'$type': 'app.bsky.feed.post',
            'text': 'Post with image',
            'embed': {
              r'$type': 'blob',
              'ref': {r'$link': 'bafyreia_blob_cid_12345678'},
              'mimeType': 'image/jpeg',
              'size': 102400,
            },
          },
          indexedAt: DateTime.parse('2026-01-09T00:00:00.000Z'),
        );

        await tester.pumpWidget(createSubject(record: recordWithBlob));
        await pumpWithFrames(tester);

        expect(find.text('Blobs'), findsOneWidget);
        expect(find.text('image/jpeg'), findsOneWidget);
        expect(find.byIcon(Icons.image), findsOneWidget);
      });

      testWidgets('shows video icon for video blobs', (tester) async {
        final recordWithVideo = RepoRecord(
          uri: 'at://$testDid/$testCollection/$testRkey',
          cid: 'bafyreiabc123456789abcdef',
          value: {
            r'$type': 'app.bsky.feed.post',
            'text': 'Post with video',
            'embed': {
              r'$type': 'blob',
              'ref': {r'$link': 'bafyreia_blob_cid_12345678'},
              'mimeType': 'video/mp4',
              'size': 5242880,
            },
          },
          indexedAt: DateTime.parse('2026-01-09T00:00:00.000Z'),
        );

        await tester.pumpWidget(createSubject(record: recordWithVideo));
        await pumpWithFrames(tester);

        expect(find.text('Blobs'), findsOneWidget);
        expect(find.text('video/mp4'), findsOneWidget);
        expect(find.byIcon(Icons.videocam), findsOneWidget);
      });

      testWidgets('does not show blobs section when no blobs present', (tester) async {
        await tester.pumpWidget(createSubject());
        await pumpWithFrames(tester);

        expect(find.text('Blobs'), findsNothing);
      });
    });
  });
}
