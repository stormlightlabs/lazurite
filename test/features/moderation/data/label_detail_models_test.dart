import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/moderation/data/label_detail_models.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:poptart_lex/com/atproto/label/defs.dart';

void main() {
  group('LabelContext', () {
    test('preserves protocol metadata from raw labels', () {
      final createdAt = DateTime.utc(2026, 6, 1, 12);
      final expiresAt = DateTime.utc(2026, 7, 1, 12);
      final label = Label(
        ver: 1,
        src: 'did:plc:labeler',
        uri: 'at://did:plc:author/app.bsky.feed.post/abc',
        cid: 'bafyrecord',
        val: 'spam-risk',
        neg: true,
        cts: createdAt,
        exp: expiresAt,
      );

      final context = LabelContext.fromLabel(label);

      expect(context.appliedLabel, same(label));
      expect(context.labelerDid, 'did:plc:labeler');
      expect(context.identifier, 'spam-risk');
      expect(context.subjectUri, 'at://did:plc:author/app.bsky.feed.post/abc');
      expect(context.subjectCid, 'bafyrecord');
      expect(context.createdAt, createdAt);
      expect(context.expiresAt, expiresAt);
      expect(context.isNegation, isTrue);
      expect(context.version, 1);
      expect(context.hasAppliedLabel, isTrue);
      expect(context.hasSubjectVersion, isTrue);
      expect(context.hasExpiry, isTrue);
    });

    test('allows subject URI and CID overrides for raw labels', () {
      final label = Label(
        src: 'did:plc:labeler',
        uri: 'did:plc:author',
        val: 'impersonation',
        cts: DateTime.utc(2026, 6, 1),
      );

      final context = LabelContext.fromLabel(
        label,
        subjectUri: 'at://did:plc:author/app.bsky.actor.profile/self',
        subjectCid: 'bafyprofile',
      );

      expect(context.subjectUri, 'at://did:plc:author/app.bsky.actor.profile/self');
      expect(context.subjectCid, 'bafyprofile');
      expect(context.isNegation, isFalse);
    });

    test('constructs fallback context from identifier and labeler DID', () {
      final context = LabelContext.fromIdentifier(
        labelerDid: 'did:plc:labeler',
        identifier: 'curated-warning',
        subjectUri: 'did:plc:subject',
      );

      expect(context.appliedLabel, isNull);
      expect(context.labelerDid, 'did:plc:labeler');
      expect(context.identifier, 'curated-warning');
      expect(context.subjectUri, 'did:plc:subject');
      expect(context.subjectCid, isNull);
      expect(context.createdAt, isNull);
      expect(context.expiresAt, isNull);
      expect(context.isNegation, isFalse);
      expect(context.version, isNull);
    });

    test('constructs context from label moderation causes', () {
      final label = Label(
        src: 'did:plc:custom-labeler',
        uri: 'at://did:plc:author/app.bsky.feed.post/abc',
        cid: 'bafyrecord',
        val: 'aaa',
        cts: DateTime.utc(2026, 4, 30),
      );
      final cause = bsky_moderation.ModerationCause.label(
        data: bsky_moderation.ModerationCauseLabel(
          source: const bsky_moderation.ModerationCauseSource.user(data: bsky_moderation.ModerationCauseSourceUser()),
          label: label,
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

      final context = LabelContext.fromModerationCause(cause);

      expect(context, isNotNull);
      expect(context!.appliedLabel, same(label));
      expect(context.labelerDid, 'did:plc:custom-labeler');
      expect(context.identifier, 'aaa');
      expect(context.subjectUri, 'at://did:plc:author/app.bsky.feed.post/abc');
      expect(context.subjectCid, 'bafyrecord');
      expect(context.createdAt, DateTime.utc(2026, 4, 30));
    });

    test('returns null for non-label moderation causes', () {
      const cause = bsky_moderation.ModerationCause.hidden(
        data: bsky_moderation.ModerationCauseHidden(
          source: bsky_moderation.ModerationCauseSource.user(data: bsky_moderation.ModerationCauseSourceUser()),
        ),
      );

      expect(LabelContext.fromModerationCause(cause), isNull);
    });
  });

  group('LabelDetailData', () {
    test('represents complete label detail state', () {
      final context = LabelContext.fromIdentifier(labelerDid: 'did:plc:labeler', identifier: 'aaa');
      const definition = LabelValueDefinition(
        identifier: 'aaa',
        severity: LabelValueDefinitionSeverity.knownValue(data: KnownLabelValueDefinitionSeverity.inform),
        blurs: LabelValueDefinitionBlurs.knownValue(data: KnownLabelValueDefinitionBlurs.none),
        defaultSetting: LabelValueDefinitionDefaultSetting.knownValue(
          data: KnownLabelValueDefinitionDefaultSetting.warn,
        ),
        adultOnly: true,
        locales: [LabelValueDefinitionStrings(lang: 'en', name: 'Test label', description: 'A test label.')],
      );

      final data = LabelDetailData(
        context: context,
        definition: definition,
        effectivePreference: KnownContentLabelPrefVisibility.hide,
        isSubscribed: true,
      );

      expect(data.context, context);
      expect(data.definition, definition);
      expect(data.effectivePreference, KnownContentLabelPrefVisibility.hide);
      expect(data.isSubscribed, isTrue);
      expect(data.hasDefinition, isTrue);
      expect(data.hasLabeler, isFalse);
      expect(data.isPartial, isTrue);
    });

    test('keeps raw context when labeler and definition are missing', () {
      final context = LabelContext.fromLabel(
        Label(
          src: 'did:plc:unknown-labeler',
          uri: 'did:plc:subject',
          val: 'unknown-label',
          cts: DateTime.utc(2026, 6, 1),
        ),
      );

      final data = LabelDetailData(
        context: context,
        effectivePreference: KnownContentLabelPrefVisibility.warn,
        isSubscribed: false,
      );

      expect(data.context.labelerDid, 'did:plc:unknown-labeler');
      expect(data.context.identifier, 'unknown-label');
      expect(data.labeler, isNull);
      expect(data.definition, isNull);
      expect(data.hasLabeler, isFalse);
      expect(data.hasDefinition, isFalse);
      expect(data.isPartial, isTrue);
      expect(data.effectivePreference, KnownContentLabelPrefVisibility.warn);
      expect(data.isSubscribed, isFalse);
    });
  });
}
