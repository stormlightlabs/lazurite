import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/moderation/data/label_detail_models.dart';
import 'package:lazurite/features/moderation/data/label_detail_repository.dart';
import 'package:lazurite/features/moderation/data/moderation_constants.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';

const _customLabelerDid = 'did:plc:custom-labeler';

class _MockModerationService extends Mock implements ModerationService {}

void main() {
  late _MockModerationService moderationService;

  setUp(() {
    moderationService = _MockModerationService();
    when(() => moderationService.ensureInitialized()).thenAnswer((_) async {});
    when(() => moderationService.currentPreferences).thenReturn(const []);
    when(() => moderationService.currentPrefs).thenReturn(null);
  });

  test('resolves label details from live labeler details', () async {
    final labeler = _buildLabeler(
      did: _customLabelerDid,
      identifier: 'spam-risk',
      locales: const [LabelValueDefinitionStrings(lang: 'en', name: 'Spam risk', description: 'Likely spam.')],
    );
    when(() => moderationService.getLabelerDetails(_customLabelerDid)).thenAnswer((_) async => labeler);
    when(() => moderationService.currentPreferences).thenReturn([
      const UPreferences.contentLabelPref(
        data: ContentLabelPref(
          label: 'spam-risk',
          labelerDid: _customLabelerDid,
          visibility: ContentLabelPrefVisibility.knownValue(data: KnownContentLabelPrefVisibility.hide),
        ),
      ),
    ]);
    when(() => moderationService.currentPrefs).thenReturn(
      const bsky_moderation.ModerationPrefs(
        labels: {},
        labelers: [bsky_moderation.ModerationPrefsLabeler(did: _customLabelerDid, labels: {})],
        mutedWords: [],
        hiddenPosts: [],
      ),
    );

    final repository = LabelDetailRepository(moderationService: moderationService);

    final data = await repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'spam-risk'),
      preferredLanguages: const ['en-US'],
    );

    expect(data.labeler, labeler);
    expect(data.definition?.identifier, 'spam-risk');
    expect(data.displayName, 'Spam risk');
    expect(data.description, 'Likely spam.');
    expect(data.effectivePreference, KnownContentLabelPrefVisibility.hide);
    expect(data.isSubscribed, isTrue);
    expect(data.adultContentEnabled, isFalse);
    expect(data.canConfigurePreference, isTrue);
    expect(data.isPartial, isFalse);
  });

  test('uses global preference when no labeler-specific preference exists', () async {
    when(
      () => moderationService.getLabelerDetails(_customLabelerDid),
    ).thenAnswer((_) async => _buildLabeler(did: _customLabelerDid, identifier: 'adult'));
    when(() => moderationService.currentPreferences).thenReturn([
      const UPreferences.contentLabelPref(
        data: ContentLabelPref(
          label: 'adult',
          visibility: ContentLabelPrefVisibility.knownValue(data: KnownContentLabelPrefVisibility.ignore),
        ),
      ),
    ]);

    final repository = LabelDetailRepository(moderationService: moderationService);

    final data = await repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'adult'),
    );

    expect(data.effectivePreference, KnownContentLabelPrefVisibility.ignore);
  });

  test('applies adult-only configuration gating from preferences', () async {
    when(
      () => moderationService.getLabelerDetails(_customLabelerDid),
    ).thenAnswer((_) async => _buildLabeler(did: _customLabelerDid, identifier: 'adult-only', adultOnly: true));
    when(
      () => moderationService.currentPreferences,
    ).thenReturn(const [UPreferences.adultContentPref(data: AdultContentPref(enabled: false))]);

    final repository = LabelDetailRepository(moderationService: moderationService);

    final disabled = await repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'adult-only'),
    );
    expect(disabled.adultContentEnabled, isFalse);
    expect(disabled.canConfigurePreference, isFalse);

    when(
      () => moderationService.currentPreferences,
    ).thenReturn(const [UPreferences.adultContentPref(data: AdultContentPref(enabled: true))]);

    final enabled = await repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'adult-only'),
    );
    expect(enabled.adultContentEnabled, isTrue);
    expect(enabled.canConfigurePreference, isTrue);
  });

  test('falls back to definition default setting when no user preference exists', () async {
    when(() => moderationService.getLabelerDetails(_customLabelerDid)).thenAnswer(
      (_) async => _buildLabeler(
        did: _customLabelerDid,
        identifier: 'hide-by-default',
        defaultSetting: const LabelValueDefinitionDefaultSetting.knownValue(
          data: KnownLabelValueDefinitionDefaultSetting.hide,
        ),
      ),
    );

    final repository = LabelDetailRepository(moderationService: moderationService);

    final data = await repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'hide-by-default'),
    );

    expect(data.effectivePreference, KnownContentLabelPrefVisibility.hide);
  });

  test('represents unknown labeler without losing raw label metadata', () async {
    final label = Label(
      src: 'did:plc:unknown-labeler',
      uri: 'at://did:plc:author/app.bsky.feed.post/abc',
      cid: 'bafyrecord',
      val: 'unknown-label',
      neg: true,
      cts: DateTime.utc(2026, 6, 2),
    );
    when(() => moderationService.getLabelerDetails('did:plc:unknown-labeler')).thenAnswer((_) async => null);

    final repository = LabelDetailRepository(moderationService: moderationService);

    final data = await repository.getLabelDetail(LabelContext.fromLabel(label));

    expect(data.labeler, isNull);
    expect(data.definition, isNull);
    expect(data.context.appliedLabel, label);
    expect(data.context.subjectCid, 'bafyrecord');
    expect(data.context.isNegation, isTrue);
    expect(data.displayName, 'Unknown Label');
    expect(data.effectivePreference, KnownContentLabelPrefVisibility.warn);
  });

  test('uses cached labeler policies when live lookup fails', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final policies = _buildPolicies(
      identifier: 'cached-label',
      locales: const [LabelValueDefinitionStrings(lang: 'en', name: 'Cached label', description: 'Loaded from cache.')],
    );
    await database.upsertLabelerCache(_customLabelerDid, PoptartCacheCodecs.labelerPolicies.encode(policies));
    when(() => moderationService.getLabelerDetails(_customLabelerDid)).thenThrow(Exception('offline'));

    final repository = LabelDetailRepository(moderationService: moderationService, database: database);

    final data = await repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'cached-label'),
    );

    expect(data.labeler, isNull);
    expect(data.definition?.identifier, 'cached-label');
    expect(data.displayName, 'Cached label');
    expect(data.description, 'Loaded from cache.');
    expect(data.isPartial, isTrue);
  });

  test('de-duplicates concurrent labeler lookups for the same DID', () async {
    final completer = Completer<LabelerViewDetailed?>();
    when(() => moderationService.getLabelerDetails(_customLabelerDid)).thenAnswer((_) => completer.future);
    final repository = LabelDetailRepository(moderationService: moderationService);

    final first = repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'aaa'),
    );
    final second = repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: _customLabelerDid, identifier: 'aaa'),
    );

    completer.complete(_buildLabeler(did: _customLabelerDid, identifier: 'aaa'));
    await Future.wait([first, second]);

    verify(() => moderationService.getLabelerDetails(_customLabelerDid)).called(1);
  });

  test('treats the official Bluesky labeler as subscribed', () async {
    when(
      () => moderationService.getLabelerDetails(officialBlueskyLabelerDid),
    ).thenAnswer((_) async => _buildLabeler(did: officialBlueskyLabelerDid, identifier: 'porn'));

    final repository = LabelDetailRepository(moderationService: moderationService);

    final data = await repository.getLabelDetail(
      LabelContext.fromIdentifier(labelerDid: officialBlueskyLabelerDid, identifier: 'porn'),
    );

    expect(data.isSubscribed, isTrue);
  });
}

LabelerViewDetailed _buildLabeler({
  required String did,
  required String identifier,
  List<LabelValueDefinitionStrings> locales = const [
    LabelValueDefinitionStrings(lang: 'en', name: 'Example label', description: 'Example description.'),
  ],
  bool adultOnly = false,
  LabelValueDefinitionDefaultSetting defaultSetting = const LabelValueDefinitionDefaultSetting.knownValue(
    data: KnownLabelValueDefinitionDefaultSetting.warn,
  ),
}) => LabelerViewDetailed(
  uri: AtUri.parse('at://$did/app.bsky.labeler.service/self'),
  cid: 'cid-$did',
  creator: ProfileView(did: did, handle: 'labeler.example.com', displayName: 'Labeler'),
  policies: _buildPolicies(
    identifier: identifier,
    locales: locales,
    adultOnly: adultOnly,
    defaultSetting: defaultSetting,
  ),
  indexedAt: DateTime.utc(2026, 6, 2),
);

LabelerPolicies _buildPolicies({
  required String identifier,
  List<LabelValueDefinitionStrings> locales = const [
    LabelValueDefinitionStrings(lang: 'en', name: 'Example label', description: 'Example description.'),
  ],
  bool adultOnly = false,
  LabelValueDefinitionDefaultSetting defaultSetting = const LabelValueDefinitionDefaultSetting.knownValue(
    data: KnownLabelValueDefinitionDefaultSetting.warn,
  ),
}) => LabelerPolicies(
  labelValues: [LabelValue.unknown(data: identifier)],
  labelValueDefinitions: [
    LabelValueDefinition(
      identifier: identifier,
      severity: const LabelValueDefinitionSeverity.knownValue(data: KnownLabelValueDefinitionSeverity.alert),
      blurs: const LabelValueDefinitionBlurs.knownValue(data: KnownLabelValueDefinitionBlurs.content),
      defaultSetting: defaultSetting,
      adultOnly: adultOnly,
      locales: locales,
    ),
  ],
);
