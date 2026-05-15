import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:lazurite/features/moderation/domain/moderation_models.dart' as bsky_moderation;
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

  testWidgets('renders resolver-provided label text for custom moderation labels', (tester) async {
    final cause = bsky_moderation.ModerationCause.label(
      data: bsky_moderation.ModerationCauseLabel(
        source: const bsky_moderation.ModerationCauseSource.user(data: bsky_moderation.ModerationCauseSourceUser()),
        label: Label(
          src: 'did:plc:custom-labeler',
          uri: 'at://did:plc:author/app.bsky.feed.post/abc',
          val: 'aaa',
          cts: DateTime.utc(2026, 4, 30),
        ),
        labelDef: bsky_moderation.InterpretedLabelValueDefinition(
          identifier: 'aaa',
          severity: bsky_moderation.ModerationBehavior.inform.name,
          blurs: 'none',
          definedBy: 'did:plc:custom-labeler',
        ),
        target: bsky_moderation.LabelTarget.content,
        setting: bsky_moderation.LabelPreference.warn,
        behavior: const {},
      ),
    );

    final ui = bsky_moderation.ModerationUI(alerts: [cause]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModerationBadgeRow(
            ui: ui,
            labelResolver: ({required String identifier, String? labelerDid}) {
              if (identifier == 'aaa' && labelerDid == 'did:plc:custom-labeler') {
                return '🅰️';
              }
              return null;
            },
          ),
        ),
      ),
    );

    expect(find.text('🅰️'), findsOneWidget);
    expect(find.text('Aaa'), findsNothing);
  });
}
