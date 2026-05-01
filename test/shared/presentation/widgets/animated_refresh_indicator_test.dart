import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';

void main() {
  testWidgets('does not call animation controller methods after dispose during refresh', (tester) async {
    final completer = Completer<void>();
    var refreshStarted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedRefreshIndicator(
            onRefresh: () {
              refreshStarted = true;
              return completer.future;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 1200)],
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(refreshStarted, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    completer.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
