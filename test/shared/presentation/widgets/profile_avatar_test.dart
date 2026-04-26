import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

void main() {
  Widget buildSubject(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders initials fallback when image is missing', (tester) async {
    await tester.pumpWidget(buildSubject(const ProfileAvatar(size: 40, fallbackText: 'Alice Smith')));

    expect(find.text('AS'), findsOneWidget);
  });

  testWidgets('uses custom fallback builder when provided', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        ProfileAvatar(size: 40, fallbackText: 'Alice Smith', fallbackBuilder: (_) => const Icon(Icons.person_outline)),
      ),
    );

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.text('AS'), findsNothing);
  });

  testWidgets('respects the requested avatar size', (tester) async {
    await tester.pumpWidget(buildSubject(const ProfileAvatar(size: 52, fallbackText: 'Alice Smith')));

    final avatarSize = tester.getSize(find.byType(ProfileAvatar));
    expect(avatarSize.width, 52);
    expect(avatarSize.height, 52);
  });
}
