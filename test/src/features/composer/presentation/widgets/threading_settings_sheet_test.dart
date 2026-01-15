import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/threading_settings_sheet.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ThreadingSettingsSheet', () {
    testWidgets('renders title and sections', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThreadingSettingsSheet(
            threadGateType: null,
            quoteDisabled: false,
            onThreadGateChanged: _dummyThreadGateCallback,
            onQuoteDisabledChanged: _dummyBoolCallback,
          ),
        ),
      );

      expect(find.text('Post Settings'), findsOneWidget);
      expect(find.text('Who can reply'), findsOneWidget);
      expect(find.text('Quote posts'), findsOneWidget);
    });

    testWidgets('renders all reply restriction options', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThreadingSettingsSheet(
            threadGateType: null,
            quoteDisabled: false,
            onThreadGateChanged: _dummyThreadGateCallback,
            onQuoteDisabledChanged: _dummyBoolCallback,
          ),
        ),
      );

      expect(find.text('Everyone'), findsOneWidget);
      expect(find.text('People you mention'), findsOneWidget);
      expect(find.text('People you follow'), findsOneWidget);
      expect(find.text('Mentioned & Following'), findsOneWidget);
    });

    testWidgets('shows selected thread gate type', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThreadingSettingsSheet(
            threadGateType: ThreadGateType.mention,
            quoteDisabled: false,
            onThreadGateChanged: _dummyThreadGateCallback,
            onQuoteDisabledChanged: _dummyBoolCallback,
          ),
        ),
      );

      expect(find.byType(RadioListTile<ThreadGateType?>), findsWidgets);

      final mentionTile = tester.widget<RadioListTile<ThreadGateType?>>(
        find.ancestor(
          of: find.text('People you mention'),
          matching: find.byType(RadioListTile<ThreadGateType?>),
        ),
      );

      expect(mentionTile.value, equals(ThreadGateType.mention));
    });

    testWidgets('calls onThreadGateChanged when reply option selected', (tester) async {
      ThreadGateType? selected;

      await tester.pumpApp(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ThreadingSettingsSheet(
                threadGateType: null,
                quoteDisabled: false,
                onThreadGateChanged: (type) {
                  setState(() {
                    selected = type;
                  });
                },
                onQuoteDisabledChanged: _dummyBoolCallback,
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('People you mention'));
      await tester.pump();

      expect(selected, equals(ThreadGateType.mention));
    });

    testWidgets('renders quote disabled toggle', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThreadingSettingsSheet(
            threadGateType: null,
            quoteDisabled: false,
            onThreadGateChanged: _dummyThreadGateCallback,
            onQuoteDisabledChanged: _dummyBoolCallback,
          ),
        ),
      );

      expect(find.text('Disable quote posts'), findsOneWidget);
      expect(find.text('Prevent others from quoting this post'), findsOneWidget);

      final switchTile = tester.widget<SwitchListTile>(
        find.ancestor(of: find.text('Disable quote posts'), matching: find.byType(SwitchListTile)),
      );

      expect(switchTile.value, isFalse);
    });

    testWidgets('shows quote disabled when enabled', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThreadingSettingsSheet(
            threadGateType: null,
            quoteDisabled: true,
            onThreadGateChanged: _dummyThreadGateCallback,
            onQuoteDisabledChanged: _dummyBoolCallback,
          ),
        ),
      );

      final switchTile = tester.widget<SwitchListTile>(
        find.ancestor(of: find.text('Disable quote posts'), matching: find.byType(SwitchListTile)),
      );

      expect(switchTile.value, isTrue);
    });

    testWidgets('calls onQuoteDisabledChanged when toggled', (tester) async {
      bool? disabled;

      await tester.pumpApp(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ThreadingSettingsSheet(
                threadGateType: null,
                quoteDisabled: false,
                onThreadGateChanged: _dummyThreadGateCallback,
                onQuoteDisabledChanged: (value) {
                  setState(() {
                    disabled = value;
                  });
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      expect(disabled, isTrue);
    });
  });
}

void _dummyThreadGateCallback(ThreadGateType? _) {}

void _dummyBoolCallback(bool _) {}
