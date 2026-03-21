import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';

void main() {
  testWidgets('keeps long moderation badges within narrow widths', (tester) async {
    const ui = bsky_moderation.ModerationUI(
      alerts: [
        bsky_moderation.ModerationCause.blockOther(
          data: bsky_moderation.ModerationCauseBlockOther(
            source: bsky_moderation.ModerationCauseSource.user(data: bsky_moderation.ModerationCauseSourceUser()),
          ),
        ),
      ],
    );
    final errors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;

    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 150, child: ModerationBadgeRow(ui: ui)),
          ),
        ),
      ),
    );

    expect(errors.where((error) => error.exceptionAsString().contains('A RenderFlex overflowed')), isEmpty);
    expect(find.text('Blocked relationship'), findsOneWidget);
  });
}
