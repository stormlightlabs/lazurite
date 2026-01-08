import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/settings/presentation/screens/muted_words_screen.dart';
import 'package:lazurite/src/infrastructure/preferences/bluesky_preferences_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBlueskyPreferencesRepository extends Mock implements BlueskyPreferencesRepository {}

void main() {
  late MockBlueskyPreferencesRepository mockRepository;
  late Session testSession;

  setUp(() {
    mockRepository = MockBlueskyPreferencesRepository();
    testSession = Session(
      did: 'did:web:test',
      handle: 'handle',
      pdsUrl: 'https://pds',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'scope',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const <String, dynamic>{},
    );

    when(
      () => mockRepository.watchMutedWordsPref(testSession.did),
    ).thenAnswer((_) => Stream.value(MutedWordsPref.empty));
    when(() => mockRepository.updateMutedWordsPref(any(), any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(MutedWordsPref.empty);
  });

  Widget buildTestWidget({MutedWordsPref pref = MutedWordsPref.empty}) {
    when(
      () => mockRepository.watchMutedWordsPref(testSession.did),
    ).thenAnswer((_) => Stream.value(pref));

    return ProviderScope(
      overrides: [
        blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
        authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      ],
      child: const MaterialApp(home: MutedWordsScreen()),
    );
  }

  group('MutedWordsScreen', () {
    testWidgets('renders app bar with title and add button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Muted Words'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
    });

    testWidgets('shows empty state when no muted words', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No Muted Words'), findsOneWidget);
      expect(find.text('Add words or phrases to filter from your feeds'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off_outlined), findsOneWidget);
    });

    testWidgets('shows list of active muted words', (tester) async {
      const pref = MutedWordsPref(
        items: [
          MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
          MutedWord(
            id: '2',
            value: 'scam',
            targets: [MutedWordTarget.tags],
            actorTarget: MutedWordActorTarget.excludeFollowing,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('spam'), findsOneWidget);
      expect(find.text('scam'), findsOneWidget);
    });

    testWidgets('shows expired muted words separately', (tester) async {
      final now = DateTime.now();
      final pref = MutedWordsPref(
        items: [
          const MutedWord(id: '1', value: 'active', targets: [MutedWordTarget.content]),
          MutedWord(
            id: '2',
            value: 'expired',
            targets: [MutedWordTarget.content],
            expiresAt: now.subtract(const Duration(days: 1)),
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('EXPIRED'), findsOneWidget);
      expect(find.text('active'), findsOneWidget);
      expect(find.text('expired'), findsOneWidget);
    });

    testWidgets('shows search bar when many muted words', (tester) async {
      final pref = MutedWordsPref(
        items: List.generate(
          10,
          (i) => MutedWord(id: '$i', value: 'word$i', targets: [MutedWordTarget.content]),
        ),
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsAtLeastNWidgets(0));
    });

    testWidgets('lists muted words', (tester) async {
      const pref = MutedWordsPref(
        items: [
          MutedWord(id: '1', value: 'testword', targets: [MutedWordTarget.content]),
        ],
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.text('testword'), findsOneWidget);
    });

    testWidgets('shows delete button for each muted word', (tester) async {
      const pref = MutedWordsPref(
        items: [
          MutedWord(id: '1', value: 'spam', targets: [MutedWordTarget.content]),
        ],
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('displays target information', (tester) async {
      const pref = MutedWordsPref(
        items: [
          MutedWord(
            id: '1',
            value: 'test',
            targets: [MutedWordTarget.content, MutedWordTarget.tags],
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.textContaining('Targets:'), findsOneWidget);
    });

    testWidgets('displays actor target information', (tester) async {
      const pref = MutedWordsPref(
        items: [
          MutedWord(
            id: '1',
            value: 'test',
            targets: [MutedWordTarget.content],
            actorTarget: MutedWordActorTarget.all,
          ),
          MutedWord(
            id: '2',
            value: 'test2',
            targets: [MutedWordTarget.content],
            actorTarget: MutedWordActorTarget.excludeFollowing,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.text('All accounts'), findsOneWidget);
      expect(find.text('Exclude following'), findsOneWidget);
    });

    testWidgets('displays expiration date', (tester) async {
      final expiresAt = DateTime.now().add(const Duration(days: 7));
      final pref = MutedWordsPref(
        items: [
          MutedWord(
            id: '1',
            value: 'test',
            targets: [MutedWordTarget.content],
            expiresAt: expiresAt,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(pref: pref));
      await tester.pumpAndSettle();

      expect(find.textContaining('Expires:'), findsOneWidget);
    });
  });

  group('AddMutedWordDialog', () {
    testWidgets('renders with required fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddMutedWordDialog())));
      await tester.pumpAndSettle();

      expect(find.text('Add Muted Word'), findsOneWidget);
      expect(find.text('Word or phrase'), findsOneWidget);
      expect(find.text('Targets'), findsOneWidget);
      expect(find.text('Actor Target'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('has content and tags checkboxes', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddMutedWordDialog())));
      await tester.pumpAndSettle();

      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Tags'), findsOneWidget);
    });

    testWidgets('has actor target radio buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddMutedWordDialog())));
      await tester.pumpAndSettle();

      expect(find.text('All accounts'), findsOneWidget);
      expect(find.text('Exclude following'), findsOneWidget);
    });

    testWidgets('has expiration date picker', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddMutedWordDialog())));
      await tester.pumpAndSettle();

      expect(find.text('Expiration (optional)'), findsOneWidget);
      expect(find.text('No expiration'), findsOneWidget);
    });

    testWidgets('validates empty word', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddMutedWordDialog())));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a word or phrase'), findsOneWidget);
    });

    testWidgets('content target is selected by default', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddMutedWordDialog())));
      await tester.pumpAndSettle();

      final contentCheckbox = tester.widget<CheckboxListTile>(
        find.ancestor(of: find.text('Content'), matching: find.byType(CheckboxListTile)),
      );

      expect(contentCheckbox.value, isTrue);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
