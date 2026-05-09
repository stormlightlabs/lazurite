import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/labeler/defs.dart';
import 'package:poptart_lex/app/bsky/labeler/get_services.dart';
import 'package:bsky_moderation/bsky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/screens/labeler_detail_screen.dart';
import 'package:lazurite/features/moderation/presentation/screens/moderation_settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockModerationService extends Mock implements ModerationService {}

void main() {
  late MockModerationService moderationService;
  late LabelerViewDetailed officialLabeler;
  late LabelerViewDetailed customLabeler;

  setUpAll(() {
    registerFallbackValue(KnownContentLabelPrefVisibility.warn);
  });

  setUp(() {
    moderationService = MockModerationService();
    officialLabeler = _buildLabeler(
      did: officialBlueskyLabelerDid,
      handle: 'safety.bsky.social',
      displayName: 'Bluesky Safety',
      description: 'Official moderation policies.',
      definitionName: 'Graphic Media',
      definitionIdentifier: 'graphic-media',
    );
    customLabeler = _buildLabeler(
      did: 'did:plc:custom-labeler',
      handle: 'cinder.example',
      displayName: 'Cinder Moderation',
      description: 'Crowdsourced media warnings.',
      definitionName: 'Spoilers',
      definitionIdentifier: 'spoilers',
    );

    when(() => moderationService.ensureInitialized()).thenAnswer((_) async {});
    when(() => moderationService.currentOpts).thenReturn(null);
    when(() => moderationService.optsStream).thenAnswer((_) => const Stream.empty());
    when(() => moderationService.currentPreferences).thenReturn([
      const UPreferences.adultContentPref(data: AdultContentPref(enabled: true)),
      const UPreferences.labelersPref(
        data: LabelersPref(labelers: [LabelerPrefItem(did: 'did:plc:custom-labeler')]),
      ),
    ]);
    when(() => moderationService.currentPrefs).thenReturn(
      const bsky_moderation.ModerationPrefs(
        adultContentEnabled: true,
        labels: {},
        labelers: [
          bsky_moderation.ModerationPrefsLabeler(did: officialBlueskyLabelerDid, labels: {}),
          bsky_moderation.ModerationPrefsLabeler(did: 'did:plc:custom-labeler', labels: {}),
        ],
        mutedWords: [],
        hiddenPosts: [],
      ),
    );
    when(
      () => moderationService.getSubscribedLabelers(),
    ).thenAnswer((_) async => [ULabelerGetServicesViews.labelerViewDetailed(data: customLabeler)]);
    when(() => moderationService.getLabelerDetails(officialBlueskyLabelerDid)).thenAnswer((_) async => officialLabeler);
    when(() => moderationService.getLabelerDetails('did:plc:custom-labeler')).thenAnswer((_) async => customLabeler);
    when(() => moderationService.unsubscribeFromLabeler(any())).thenAnswer((_) async {});
    when(() => moderationService.setAdultContentEnabled(any())).thenAnswer((_) async {});
    when(
      () => moderationService.setLabelPreference(
        label: any(named: 'label'),
        labelerDid: any(named: 'labelerDid'),
        visibility: any(named: 'visibility'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget buildSubject(Widget child) {
    return RepositoryProvider<ModerationService>.value(
      value: moderationService,
      child: MaterialApp(home: child),
    );
  }

  testWidgets('moderation settings screen renders official and custom labelers', (tester) async {
    await tester.pumpWidget(buildSubject(const ModerationSettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Adult content'), findsOneWidget);
    expect(find.text('Bluesky Safety'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Cinder Moderation'), 300);
    expect(find.text('Cinder Moderation'), findsOneWidget);
    expect(find.textContaining('1/20'), findsOneWidget);
  });

  testWidgets('labeler detail screen renders localized label definitions', (tester) async {
    await tester.pumpWidget(buildSubject(const LabelerDetailScreen(did: 'did:plc:custom-labeler')));
    await tester.pumpAndSettle();

    expect(find.text('Spoilers'), findsOneWidget);
    expect(find.text('Spoilers should be treated cautiously.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Hide'), 300);
    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('Default warn'), findsOneWidget);
  });
}

LabelerViewDetailed _buildLabeler({
  required String did,
  required String handle,
  required String displayName,
  required String description,
  required String definitionName,
  required String definitionIdentifier,
}) {
  return LabelerViewDetailed(
    uri: AtUri.parse('at://$did/app.bsky.labeler.service/self'),
    cid: 'cid-$did',
    creator: ProfileView(
      did: did,
      handle: handle,
      displayName: displayName,
      description: description,
      avatar: 'https://example.com/$handle.png',
    ),
    policies: LabelerPolicies(
      labelValues: [LabelValue.unknown(data: definitionIdentifier)],
      labelValueDefinitions: [
        LabelValueDefinition(
          identifier: definitionIdentifier,
          severity: const LabelValueDefinitionSeverity.knownValue(data: KnownLabelValueDefinitionSeverity.alert),
          blurs: const LabelValueDefinitionBlurs.knownValue(data: KnownLabelValueDefinitionBlurs.content),
          defaultSetting: const LabelValueDefinitionDefaultSetting.knownValue(
            data: KnownLabelValueDefinitionDefaultSetting.warn,
          ),
          adultOnly: false,
          locales: [
            LabelValueDefinitionStrings(
              lang: 'en',
              name: definitionName,
              description: '$definitionName should be treated cautiously.',
            ),
          ],
        ),
      ],
    ),
    indexedAt: DateTime.utc(2026, 3, 21),
  );
}
