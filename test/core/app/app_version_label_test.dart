import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/app/app_version_label.dart';

void main() {
  group('AppVersionLabel', () {
    testWidgets('reserves visible text while version metadata is loading', (tester) async {
      final completer = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppVersionLabel(loadDisplayLabel: () => completer.future)),
        ),
      );

      expect(find.text(AppVersionLabel.placeholderLabel), findsOneWidget);

      completer.complete('Lazurite Nightly v1.0.0 alpha 6');
      await tester.pump();

      expect(find.text('Lazurite Nightly v1.0.0 alpha 6'), findsOneWidget);
    });

    testWidgets('shows a visible error label when version metadata fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppVersionLabel(loadDisplayLabel: () async => throw Exception('metadata unavailable'))),
        ),
      );
      await tester.pump();

      expect(find.text(AppVersionLabel.errorLabel), findsOneWidget);
      expect(find.byTooltip('Unable to load app version'), findsOneWidget);
    });
  });
}
