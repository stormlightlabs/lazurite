import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/ads/presentation/ad_post_card.dart';

Widget _buildSubject({required bool isLinear}) {
  return MaterialApp(
    home: Scaffold(
      body: AdPostCard(
        isLinear: isLinear,
        child: const ColoredBox(color: Colors.blue, child: SizedBox(width: 100, height: 100)),
      ),
    ),
  );
}

void main() {
  testWidgets('renders sponsored label in grid mode', (tester) async {
    await tester.pumpWidget(_buildSubject(isLinear: false));

    expect(find.text('Sponsored'), findsOneWidget);
  });

  testWidgets('renders sponsored label with linear chrome', (tester) async {
    await tester.pumpWidget(_buildSubject(isLinear: true));

    expect(find.text('Sponsored'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
  });
}
