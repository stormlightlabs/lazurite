import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/actor_name_widget.dart';

void main() {
  Widget buildSubject(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders display name and uppercase handle by default', (tester) async {
    await tester.pumpWidget(
      buildSubject(const ActorNameWidget(displayName: 'Alice Smith', handle: 'alice.bsky.social')),
    );

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('@ALICE.BSKY.SOCIAL'), findsOneWidget);
  });

  testWidgets('renders only handle line when configured and displayName is missing', (tester) async {
    await tester.pumpWidget(
      buildSubject(const ActorNameWidget(handle: 'alice.bsky.social', showDisplayNameOnlyWhenPresent: true)),
    );

    expect(find.text('alice.bsky.social'), findsNothing);
    expect(find.text('@ALICE.BSKY.SOCIAL'), findsOneWidget);
  });

  testWidgets('can preserve original handle case', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const ActorNameWidget(displayName: 'Alice Smith', handle: 'alice.bsky.social', uppercaseHandle: false),
      ),
    );

    expect(find.text('@alice.bsky.social'), findsOneWidget);
  });
}
