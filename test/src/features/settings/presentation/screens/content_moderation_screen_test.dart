import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/settings/presentation/screens/content_moderation_screen.dart';
import 'package:lazurite/src/infrastructure/preferences/bluesky_preferences_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBlueskyPreferencesRepository extends Mock implements BlueskyPreferencesRepository {}

void main() {
  late MockBlueskyPreferencesRepository mockRepository;

  setUp(() {
    mockRepository = MockBlueskyPreferencesRepository();

    when(
      () => mockRepository.watchAdultContentPref(any()),
    ).thenAnswer((_) => Stream.value(const AdultContentPref(enabled: false)));
    when(
      () => mockRepository.watchContentLabelPrefs(any()),
    ).thenAnswer((_) => Stream.value(ContentLabelPrefs.empty));
    when(
      () => mockRepository.watchLabelersPref(any()),
    ).thenAnswer((_) => Stream.value(LabelersPref.empty));
    when(() => mockRepository.updateAdultContentPref(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.updateContentLabelPrefs(any(), any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(const AdultContentPref(enabled: false));
    registerFallbackValue(ContentLabelPrefs.empty);
  });

  Widget buildTestWidget({
    AdultContentPref adultPref = const AdultContentPref(enabled: false),
    ContentLabelPrefs labelPrefs = ContentLabelPrefs.empty,
    LabelersPref labelersPref = LabelersPref.empty,
  }) {
    when(
      () => mockRepository.watchAdultContentPref(any()),
    ).thenAnswer((_) => Stream.value(adultPref));
    when(
      () => mockRepository.watchContentLabelPrefs(any()),
    ).thenAnswer((_) => Stream.value(labelPrefs));
    when(
      () => mockRepository.watchLabelersPref(any()),
    ).thenAnswer((_) => Stream.value(labelersPref));

    return ProviderScope(
      overrides: [
        blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
        adultContentPrefProvider.overrideWith(
          (ref) => mockRepository.watchAdultContentPref(any()),
        ),
        contentLabelPrefsProvider.overrideWith(
          (ref) => mockRepository.watchContentLabelPrefs(any()),
        ),
        labelersPrefProvider.overrideWith((ref) => mockRepository.watchLabelersPref(any())),
      ],
      child: const MaterialApp(home: ContentModerationScreen()),
    );
  }

  group('ContentModerationScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Content Moderation'), findsOneWidget);
    });

    testWidgets('renders adult content section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('ADULT CONTENT'), findsOneWidget);
      expect(find.text('Enable Adult Content'), findsOneWidget);
    });

    testWidgets('renders label category sections', (tester) async {
      await tester.pumpWidget(buildTestWidget(adultPref: const AdultContentPref(enabled: true)));
      await tester.pumpAndSettle();

      expect(find.text('ADULT CONTENT'), findsOneWidget);
      expect(find.text('SEXUAL CONTENT'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('VIOLENCE'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('OTHER'), findsOneWidget);
    });

    testWidgets('renders individual labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(adultPref: const AdultContentPref(enabled: true)));
      await tester.pumpAndSettle();

      expect(find.text('Sexually Suggestive'), findsOneWidget);
      expect(find.text('Nudity'), findsOneWidget);
      expect(find.text('Pornography'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Graphic Media'), findsOneWidget);
    });

    testWidgets('adult content toggle is off by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final toggle = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Enable Adult Content'),
      );
      expect(toggle.value, isFalse);
    });

    testWidgets('adult content toggle shows enabled state', (tester) async {
      await tester.pumpWidget(buildTestWidget(adultPref: const AdultContentPref(enabled: true)));
      await tester.pumpAndSettle();

      final toggle = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Enable Adult Content'),
      );
      expect(toggle.value, isTrue);
    });

    testWidgets('toggling adult content calls updateAdultContentPref', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Enable Adult Content'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.updateAdultContentPref(
          any(that: predicate<AdultContentPref>((p) => p.enabled == true)),
          any(),
        ),
      ).called(1);
    });

    testWidgets('shows subscribed labelers section when labelers exist', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelersPref: const LabelersPref(labelers: [LabelerRef(did: 'did:plc:test-labeler')]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(find.text('SUBSCRIBED LABELERS'), findsOneWidget);
      expect(find.text('did:plc:test-labeler'), findsOneWidget);
    });

    testWidgets('hides labelers section when no labelers exist', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('SUBSCRIBED LABELERS'), findsNothing);
    });

    testWidgets('changing label visibility calls updateContentLabelPrefs', (tester) async {
      await tester.pumpWidget(buildTestWidget(adultPref: const AdultContentPref(enabled: true)));
      await tester.pumpAndSettle();

      final hideButtons = find.text('Hide');
      expect(hideButtons, findsWidgets);

      await tester.tap(hideButtons.first);
      await tester.pumpAndSettle();

      verify(() => mockRepository.updateContentLabelPrefs(any(), any())).called(1);
    });

    testWidgets('shows current label preferences', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          adultPref: const AdultContentPref(enabled: true),
          labelPrefs: const ContentLabelPrefs(
            items: [ContentLabelPref(label: 'sexual', visibility: LabelVisibility.hide)],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sexually Suggestive'), findsOneWidget);
    });

    testWidgets('shows warning message when adult content is disabled', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Adult content is currently disabled. Enable it to configure individual label visibility.',
        ),
        findsOneWidget,
      );
    });
  });
}
