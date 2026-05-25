import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/presentation/media/media_alt_text_panel.dart';

void main() {
  testWidgets('scrolls long alt text within its bounded height', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final longAltText = List<String>.generate(40, (index) => 'Alt text line $index').join('\n');

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 400)),
          child: Scaffold(
            body: Center(
              child: MediaAltTextPanel(
                text: longAltText,
                maxHeightFraction: 0.2,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    expect(tester.getSize(find.byType(MediaAltTextPanel)).height, lessThanOrEqualTo(80));

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -80));
    await tester.pump();

    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets('trims surrounding whitespace before rendering alt text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MediaAltTextPanel(
            text: '  A concise description  ',
            decoration: BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );

    expect(find.text('A concise description'), findsOneWidget);
    expect(find.text('  A concise description  '), findsNothing);
  });
}
