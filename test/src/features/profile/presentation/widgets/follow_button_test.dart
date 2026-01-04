import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/follow_button.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('FollowButton', () {
    testWidgets('shows "Follow" when not following', (tester) async {
      await tester.pumpApp(const FollowButton(isFollowing: false));

      expect(find.text('Follow'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows "Following" when following', (tester) async {
      await tester.pumpApp(const FollowButton(isFollowing: true));

      expect(find.text('Following'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpApp(const FollowButton(isFollowing: false, isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Follow'), findsNothing);
    });

    testWidgets('invokes onPressed callback when tapped', (tester) async {
      var pressed = false;

      await tester.pumpApp(FollowButton(isFollowing: false, onPressed: () => pressed = true));

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not invoke callback when disabled', (tester) async {
      var pressed = false;

      await tester.pumpApp(
        FollowButton(isFollowing: false, isDisabled: true, onPressed: () => pressed = true),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('does not invoke callback when loading', (tester) async {
      await tester.pumpApp(FollowButton(isFollowing: false, isLoading: true, onPressed: () {}));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('uses outlined style for following state', (tester) async {
      await tester.pumpApp(const FollowButton(isFollowing: true));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('uses filled style for not following state', (tester) async {
      await tester.pumpApp(const FollowButton(isFollowing: false));

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });
}
