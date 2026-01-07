import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/features/settings/presentation/screens/theme_settings_screen.dart';

void main() {
  Widget buildTestWidget({
    ThemeMode themeMode = ThemeMode.dark,
    String currentPackId = 'oxocarbon',
    List<ThemePack>? packs,
    void Function(ThemeMode)? onThemeModeChanged,
    void Function(String)? onThemePackChanged,
  }) {
    return ProviderScope(
      overrides: [
        themeControllerProvider.overrideWith(
          () => _TestThemeController(
            initialMode: themeMode,
            initialPackId: currentPackId,
            onThemeModeChanged: onThemeModeChanged,
            onThemePackChanged: onThemePackChanged,
          ),
        ),
        availableThemePacksProvider.overrideWithValue(packs ?? [oxocarbonPack]),
      ],
      child: MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: themeMode,
        home: const ThemeSettingsScreen(),
      ),
    );
  }

  group('ThemeSettingsScreen', () {
    testWidgets('renders all sections', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('THEME MODE'), findsOneWidget);
      expect(find.text('THEME PACK'), findsOneWidget);
      expect(find.text('PREVIEW'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('EXPORT'), findsOneWidget);
    });

    testWidgets('displays theme mode options', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(RadioListTile<ThemeMode>, 'Light'), findsOneWidget);
      expect(find.widgetWithText(RadioListTile<ThemeMode>, 'Dark'), findsOneWidget);
      expect(find.widgetWithText(RadioListTile<ThemeMode>, 'System'), findsOneWidget);
    });

    testWidgets('shows current theme mode as selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      final lightRadio = tester.widget<RadioListTile<ThemeMode>>(
        find.widgetWithText(RadioListTile<ThemeMode>, 'Light'),
      );
      expect(lightRadio.value, ThemeMode.light);
    });

    testWidgets('tapping theme mode calls controller', (tester) async {
      ThemeMode? selectedMode;

      await tester.pumpWidget(
        buildTestWidget(
          themeMode: ThemeMode.dark,
          onThemeModeChanged: (mode) => selectedMode = mode,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<ThemeMode>, 'Light'));
      await tester.pumpAndSettle();

      expect(selectedMode, ThemeMode.light);
    });

    testWidgets('displays available theme packs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Oxocarbon'), findsOneWidget);
      expect(find.text('by IBM'), findsOneWidget);
    });

    testWidgets('displays preview cards', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('displays export button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Export theme JSON'), findsOneWidget);
      expect(find.text('Copy theme spec to clipboard'), findsOneWidget);
    });

    testWidgets('export button copies to clipboard', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export theme JSON'));
      await tester.pumpAndSettle();

      expect(find.text('Theme JSON copied to clipboard'), findsOneWidget);
    });

    testWidgets('system theme shows current brightness', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('Currently:'), findsOneWidget);
    });
  });
}

class _TestThemeController extends ThemeController {
  _TestThemeController({
    required this.initialMode,
    required this.initialPackId,
    this.onThemeModeChanged,
    this.onThemePackChanged,
  });

  final ThemeMode initialMode;
  final String initialPackId;
  final void Function(ThemeMode)? onThemeModeChanged;
  final void Function(String)? onThemePackChanged;

  @override
  ThemeState build() => ThemeState(
    themeMode: initialMode,
    currentPackId: initialPackId,
    lightTheme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
  );

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    onThemeModeChanged?.call(mode);
    state = state.copyWith(themeMode: mode);
  }

  @override
  Future<void> setThemePack(String packId) async {
    onThemePackChanged?.call(packId);
    state = state.copyWith(currentPackId: packId);
  }
}
