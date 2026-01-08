import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/app/theming/custom_theme_draft.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';
import 'package:lazurite/src/features/settings/presentation/screens/theme_editor_screen.dart';
import 'package:lazurite/src/features/settings/presentation/widgets/color_role_picker.dart';
import 'package:lazurite/src/infrastructure/db/daos/local_settings_dao.dart';
import 'package:lazurite/src/infrastructure/theming/custom_theme_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomThemeRepository extends Mock implements CustomThemeRepository {}

class MockLocalSettingsDao extends Mock implements LocalSettingsDao {}

class TestApp extends StatelessWidget {
  const TestApp({required this.home, super.key});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => context.push('/editor'),
                  child: const Text('Push'),
                ),
              ),
            ),
          ),
          GoRoute(path: '/editor', builder: (context, state) => home),
        ],
      ),
    );
  }
}

void main() {
  late MockCustomThemeRepository mockRepository;
  late MockLocalSettingsDao mockSettingsDao;

  const testPack = ThemePack(
    id: 'test_pack',
    name: 'Test Pack',
    variants: [
      ThemeVariant(
        id: 'test_variant',
        name: 'Test Variant',
        brightness: Brightness.dark,
        spec: ThemeSpec(
          primary: Colors.blue,
          secondary: Colors.teal,
          tertiary: Colors.amber,
          surface: Colors.black,
          surfaceContainerLow: Colors.black12,
          surfaceContainerHigh: Colors.black26,
          outlineVariant: Colors.grey,
        ),
        derivedScheme: ColorScheme.dark(),
      ),
    ],
  );

  setUp(() {
    mockRepository = MockCustomThemeRepository();
    mockSettingsDao = MockLocalSettingsDao();

    registerFallbackValue(
      CustomThemeDraft.create(
        name: 'fallback',
        basePackId: 'fallback',
        overrides: ThemeRoleOverrides.empty,
      ),
    );

    when(() => mockRepository.getById(any())).thenAnswer((invocation) async {
      final id = invocation.positionalArguments.first as String;
      return CustomThemeDraft.create(
        name: 'Generic Draft',
        basePackId: 'test_pack',
        overrides: ThemeRoleOverrides.empty,
      ).copyWith(id: id);
    });

    when(() => mockSettingsDao.get(ThemeSettingsKeys.themeMode)).thenAnswer((_) async => 'dark');
    when(
      () => mockSettingsDao.get(ThemeSettingsKeys.themePackId),
    ).thenAnswer((_) async => 'test_pack');
    when(() => mockSettingsDao.get(ThemeSettingsKeys.customThemeId)).thenAnswer((_) async => null);
    when(
      () => mockSettingsDao.get(ThemeSettingsKeys.dynamicColorEnabled),
    ).thenAnswer((_) async => 'false');

    when(() => mockSettingsDao.set(any(), any())).thenAnswer((_) async {});
    when(() => mockSettingsDao.remove(any())).thenAnswer((_) async => 1);
  });

  Widget createSubject({String? customThemeId}) {
    return ProviderScope(
      overrides: [
        customThemeRepositoryProvider.overrideWithValue(mockRepository),
        localSettingsDaoProvider.overrideWithValue(mockSettingsDao),
        availableThemePacksProvider.overrideWith((ref) => [testPack]),
      ],
      child: TestApp(home: ThemeEditorScreen(customThemeId: customThemeId)),
    );
  }

  group('ThemeEditorScreen', () {
    testWidgets('reset clears overrides', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.text('My Custom Theme'), findsOneWidget);
      expect(find.text('Test Pack'), findsOneWidget);
      expect(find.byType(ColorRolePicker), findsNWidgets(7));
    });

    testWidgets('loads default state for new theme', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.text('My Custom Theme'), findsOneWidget);
      expect(find.text('Test Pack'), findsOneWidget);
      expect(find.byType(ColorRolePicker), findsNWidgets(7));
    });

    testWidgets('loads existing theme data', (tester) async {
      final existingDraft = CustomThemeDraft.create(
        name: 'Existing Theme',
        basePackId: 'test_pack',
        overrides: const ThemeRoleOverrides(primary: Colors.red),
      ).copyWith(id: 'existing_id');

      when(() => mockRepository.getById('existing_id')).thenAnswer((_) async => existingDraft);

      await tester.pumpWidget(createSubject(customThemeId: 'existing_id'));
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.text('Existing Theme'), findsOneWidget);
    });

    testWidgets('updates override when color picked', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Primary'));
      await tester.pumpAndSettle();

      expect(find.text('Select Color'), findsOneWidget);
    });

    testWidgets('save creates new theme and sets it', (tester) async {
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => const ValidationResult.valid());

      await tester.pumpWidget(createSubject());
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.save(any(that: isA<CustomThemeDraft>()))).called(1);

      verify(() => mockSettingsDao.set(ThemeSettingsKeys.customThemeId, any())).called(1);

      expect(find.byType(ThemeEditorScreen), findsNothing);
    });

    testWidgets('save updates existing theme', (tester) async {
      final existingDraft = CustomThemeDraft.create(
        name: 'Existing',
        basePackId: 'test_pack',
        overrides: ThemeRoleOverrides.empty,
      ).copyWith(id: 'existing_id');

      when(() => mockRepository.getById('existing_id')).thenAnswer((_) async => existingDraft);
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => const ValidationResult.valid());

      await tester.pumpWidget(createSubject(customThemeId: 'existing_id'));
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Updated Name');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      verify(() => mockRepository.save(any())).called(1);
    });

    testWidgets('shows error snackbar on save failure', (tester) async {
      when(
        () => mockRepository.save(any()),
      ).thenAnswer((_) async => const ValidationResult.invalid('Save failed'));

      await tester.pumpWidget(createSubject());
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Save failed'), findsOneWidget);
      expect(find.byType(ThemeEditorScreen), findsOneWidget);
    });
  });
}
