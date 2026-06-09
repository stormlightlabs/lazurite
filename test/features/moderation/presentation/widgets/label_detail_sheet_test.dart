import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/moderation/data/label_detail_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/widgets/label_detail_sheet.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';

import '../../../../helpers/router_harness.dart';

class MockModerationService extends Mock implements ModerationService {}

void main() {
  late MockModerationService moderationService;
  late LabelContext labelContext;
  late LabelDetailData detailData;

  setUpAll(() {
    registerFallbackValue(KnownContentLabelPrefVisibility.warn);
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first.physicalSize = const Size(1200, 1800);
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first.devicePixelRatio = 1;
    moderationService = MockModerationService();
    labelContext = LabelContext(
      labelerDid: 'did:plc:labeler',
      identifier: 'spoilers',
      subjectUri: 'at://did:plc:alice/app.bsky.feed.post/3k',
      subjectCid: 'bafy-post',
      createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      expiresAt: DateTime.utc(2026, 2, 1),
      isNegation: true,
      version: 1,
    );
    detailData = LabelDetailData(
      context: labelContext,
      labeler: _buildLabeler(),
      definition: _definition(),
      displayName: 'Spoilers',
      description: 'Hides plot details.',
      effectivePreference: KnownContentLabelPrefVisibility.warn,
      isSubscribed: true,
      adultContentEnabled: true,
      canConfigurePreference: true,
    );

    when(
      () => moderationService.setLabelPreference(
        label: any(named: 'label'),
        labelerDid: any(named: 'labelerDid'),
        visibility: any(named: 'visibility'),
      ),
    ).thenAnswer((_) async {});
    when(() => moderationService.unsubscribeFromLabeler(any())).thenAnswer((_) async {});
    when(() => moderationService.subscribeToLabeler(any())).thenAnswer((_) async {});
  });

  Widget buildSubject({
    required Future<LabelDetailData> Function(LabelContext, Iterable<String>) loader,
    LabelContext? context,
  }) => RepositoryProvider<ModerationService>.value(
    value: moderationService,
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(
          child: LabelDetailSheet(labelContext: context ?? labelContext, loadLabelDetail: loader),
        ),
      ),
    ),
  );

  testWidgets('shows loading then resolved label definition and protocol details', (tester) async {
    final completer = Completer<LabelDetailData>();
    await tester.pumpWidget(buildSubject(loader: (_, _) => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(detailData);
    await tester.pumpAndSettle();

    expect(find.text('Spoilers'), findsOneWidget);
    expect(find.text('Hides plot details.'), findsWidgets);
    expect(find.text('Cinder Moderation'), findsOneWidget);
    expect(find.text('Active warn'), findsOneWidget);
    expect(find.text('Negation'), findsOneWidget);

    await tester.tap(find.text('Protocol details'));
    await tester.pumpAndSettle();
    expect(find.text('src'), findsOneWidget);
    expect(find.text('did:plc:labeler'), findsWidgets);
    expect(find.text('val'), findsOneWidget);
  });

  testWidgets('shows raw identifier fallback for partial missing definition data', (tester) async {
    final partial = LabelDetailData(
      context: labelContext,
      labeler: _buildLabeler(),
      effectivePreference: KnownContentLabelPrefVisibility.hide,
      isSubscribed: false,
      displayName: 'Spoilers',
    );

    await tester.pumpWidget(buildSubject(loader: (_, _) async => partial));
    await tester.pumpAndSettle();

    expect(find.text('Raw label value: spoilers'), findsOneWidget);
    expect(find.textContaining('did not publish a description'), findsOneWidget);
    expect(find.textContaining('No matching published definition'), findsOneWidget);
    expect(find.text('Subscribe to labeler'), findsOneWidget);
  });

  testWidgets('retries after loader failure', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      buildSubject(
        loader: (_, _) {
          calls++;
          if (calls == 1) {
            return Future<LabelDetailData>.error(Exception('offline'));
          }
          return Future.value(detailData);
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load label details'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Spoilers'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('open labeler profile action routes to canonical labeler profile', (tester) async {
    Uri? capturedUri;
    final harness = TestRouterHarness(
      home: RepositoryProvider<ModerationService>.value(
        value: moderationService,
        child: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => RepositoryProvider<ModerationService>.value(
                  value: moderationService,
                  child: LabelDetailSheet(labelContext: labelContext, loadLabelDetail: (_, _) async => detailData),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      routes: [capturedRoute(path: '/labelers/:did', onRoute: (uri) => capturedUri = uri)],
    );
    await harness.pump(tester);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open labeler profile'));
    await tester.pumpAndSettle();

    expect(capturedUri?.path, '/labelers/did:plc:labeler');
  });

  testWidgets('subscription and preference actions call moderation service', (tester) async {
    await tester.pumpWidget(buildSubject(loader: (_, _) async => detailData));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Unsubscribe from labeler'));
    await tester.pump();

    verify(() => moderationService.unsubscribeFromLabeler('did:plc:labeler')).called(1);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hide'));
    await tester.pump();

    verify(
      () => moderationService.setLabelPreference(
        label: 'spoilers',
        labelerDid: 'did:plc:labeler',
        visibility: KnownContentLabelPrefVisibility.hide,
      ),
    ).called(1);
  });
}

LabelerViewDetailed _buildLabeler() => LabelerViewDetailed(
  uri: AtUri.parse('at://did:plc:labeler/app.bsky.labeler.service/self'),
  cid: 'cid-labeler',
  creator: const ProfileView(
    did: 'did:plc:labeler',
    handle: 'cinder.example',
    displayName: 'Cinder Moderation',
    avatar: 'https://example.com/avatar.png',
  ),
  policies: LabelerPolicies(
    labelValues: [const LabelValue.unknown(data: 'spoilers')],
    labelValueDefinitions: [_definition()],
  ),
  indexedAt: DateTime.utc(2026, 1, 1),
);

LabelValueDefinition _definition() => const LabelValueDefinition(
  identifier: 'spoilers',
  severity: LabelValueDefinitionSeverity.knownValue(data: KnownLabelValueDefinitionSeverity.alert),
  blurs: LabelValueDefinitionBlurs.knownValue(data: KnownLabelValueDefinitionBlurs.content),
  defaultSetting: LabelValueDefinitionDefaultSetting.knownValue(data: KnownLabelValueDefinitionDefaultSetting.warn),
  adultOnly: false,
  locales: [LabelValueDefinitionStrings(lang: 'en', name: 'Spoilers', description: 'Hides plot details.')],
);
