import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';

void main() {
  Widget buildSubject({
    required void Function(BuildContext context) onOpenOptions,
    required void Function(BuildContext context) onOpenCustom,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Column(
              children: [
                FilledButton(onPressed: () => onOpenOptions(context), child: const Text('open-options')),
                FilledButton(onPressed: () => onOpenCustom(context), child: const Text('open-custom')),
              ],
            );
          },
        ),
      ),
    );
  }

  testWidgets('shows options sheet items and triggers callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      buildSubject(
        onOpenOptions: (context) {
          showOptionsSheet<void>(
            context: context,
            items: [OptionsSheetItem(title: 'Copy link', leading: const Icon(Icons.copy), onTap: () => tapped = true)],
          );
        },
        onOpenCustom: (_) {},
      ),
    );

    await tester.tap(find.text('open-options'));
    await tester.pumpAndSettle();

    expect(find.text('Copy link'), findsOneWidget);
    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('shows custom bottom sheet via helper', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        onOpenOptions: (_) {},
        onOpenCustom: (context) {
          showAppBottomSheet<void>(
            context: context,
            builder: (_) => const SafeArea(
              child: SizedBox(height: 80, child: Center(child: Text('custom'))),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('open-custom'));
    await tester.pumpAndSettle();

    expect(find.text('custom'), findsOneWidget);
  });
}
