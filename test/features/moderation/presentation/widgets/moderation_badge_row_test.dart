import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/moderation/data/label_detail_models.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
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
    final cause = _labelCause();
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

  testWidgets('keeps badges passive when no tap handler is supplied', (tester) async {
    final ui = bsky_moderation.ModerationUI(alerts: [_labelCause()]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ModerationBadgeRow(ui: ui)),
      ),
    );

    final inkWell = tester.widget<InkWell>(
      find.descendant(of: find.byType(ModerationBadgeRow), matching: find.byType(InkWell)),
    );
    expect(inkWell.onTap, isNull);
  });

  testWidgets('passes label context when a label badge is tapped', (tester) async {
    final ui = bsky_moderation.ModerationUI(alerts: [_labelCause()]);
    LabelContext? tappedContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModerationBadgeRow(ui: ui, onLabelTap: (context) => tappedContext = context),
        ),
      ),
    );

    await tester.tap(find.text('Aaa'));
    await tester.pump();

    final context = tappedContext;
    expect(context, isNotNull);
    expect(context!.labelerDid, 'did:plc:custom-labeler');
    expect(context.identifier, 'aaa');
    expect(context.subjectUri, 'at://did:plc:author/app.bsky.feed.post/abc');
    expect(context.subjectCid, 'bafyrecord');
  });

  testWidgets('does not call the label tap handler for non-label badges', (tester) async {
    const ui = bsky_moderation.ModerationUI(
      alerts: [
        bsky_moderation.ModerationCause.blockOther(
          data: bsky_moderation.ModerationCauseBlockOther(
            source: bsky_moderation.ModerationCauseSource.user(data: bsky_moderation.ModerationCauseSourceUser()),
          ),
        ),
      ],
    );
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModerationBadgeRow(ui: ui, onLabelTap: (_) => tapCount++),
        ),
      ),
    );

    await tester.tap(find.text('Blocked relationship'));
    await tester.pump();

    expect(tapCount, 0);
  });

  testWidgets('exposes tappable label badges as semantic buttons', (tester) async {
    final ui = bsky_moderation.ModerationUI(alerts: [_labelCause()]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModerationBadgeRow(ui: ui, onLabelTap: (_) {}),
        ),
      ),
    );

    final semantics = tester.widgetList<Semantics>(find.byType(Semantics)).where((widget) {
      return widget.properties.label == 'Aaa';
    }).single;
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.hint, contains('Open label details'));
  });

  testWidgets('supports keyboard activation for tappable label badges', (tester) async {
    final ui = bsky_moderation.ModerationUI(alerts: [_labelCause()]);
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModerationBadgeRow(ui: ui, onLabelTap: (_) => tapCount++),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(tapCount, 1);
  });

  test('badge descriptors carry label detail context for moderation label causes', () {
    final descriptors = moderationBadgesForUi(bsky_moderation.ModerationUI(alerts: [_labelCause()]));

    expect(descriptors, hasLength(1));
    expect(descriptors.single.canOpenLabelDetails, isTrue);
    expect(descriptors.single.labelContext?.labelerDid, 'did:plc:custom-labeler');
    expect(descriptors.single.labelContext?.identifier, 'aaa');
  });
}

bsky_moderation.ModerationCause _labelCause() => bsky_moderation.ModerationCause.label(
  data: bsky_moderation.ModerationCauseLabel(
    source: const bsky_moderation.ModerationCauseSource.user(data: bsky_moderation.ModerationCauseSourceUser()),
    label: Label(
      src: 'did:plc:custom-labeler',
      uri: 'at://did:plc:author/app.bsky.feed.post/abc',
      cid: 'bafyrecord',
      val: 'aaa',
      cts: DateTime.utc(2026, 4, 30),
    ),
    labelDef: const bsky_moderation.InterpretedLabelValueDefinition(
      identifier: 'aaa',
      severity: 'inform',
      blurs: 'none',
      definedBy: 'did:plc:custom-labeler',
    ),
    target: bsky_moderation.LabelTarget.content,
    setting: bsky_moderation.LabelPreference.warn,
    behavior: const {},
  ),
);
