import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/core/l10n/l10n.dart';

void main() {
  testWidgets('is available from MaterialApp localization delegates', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Text(context.l10n.appTitle);
          },
        ),
      ),
    );

    expect(find.text('Lazurite'), findsOneWidget);
  });

  testWidgets('context helper falls back to English in minimal widget tests', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Text(context.l10n.buttonRetry);
          },
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
  });
}
