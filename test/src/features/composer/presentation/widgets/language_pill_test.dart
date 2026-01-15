import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/language_pill.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('LanguagePill', () {
    testWidgets('renders language code in uppercase', (tester) async {
      await tester.pumpApp(const Material(child: LanguagePill(code: 'en')));
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('renders remove button when showRemove is true', (tester) async {
      await tester.pumpApp(
        const Material(
          child: LanguagePill(code: 'en', onRemove: _dummyCallback, showRemove: true),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not render remove button when showRemove is false', (tester) async {
      await tester.pumpApp(const Material(child: LanguagePill(code: 'en', showRemove: false)));
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('calls onRemove when tapped', (tester) async {
      var removed = false;

      void onRemove() {
        removed = true;
      }

      await tester.pumpApp(
        Material(
          child: LanguagePill(code: 'en', onRemove: onRemove),
        ),
      );

      await tester.tap(find.byType(LanguagePill));
      expect(removed, isTrue);
    });

    testWidgets('handles multi-character language codes', (tester) async {
      await tester.pumpApp(const Material(child: LanguagePill(code: 'zh')));
      expect(find.text('ZH'), findsOneWidget);
    });
  });
}

void _dummyCallback() {}
