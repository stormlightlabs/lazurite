import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/settings/presentation/widgets/connection_detail.dart';

void main() {
  Widget buildSubject(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('keeps localized label casing unchanged', (tester) async {
    await tester.pumpWidget(buildSubject(const ConnectionDetailRow(label: 'identity', value: 'did:plc:abc')));

    expect(find.text('identity'), findsOneWidget);
    expect(find.text('IDENTITY'), findsNothing);
    expect(find.text('did:plc:abc'), findsOneWidget);
  });
}
