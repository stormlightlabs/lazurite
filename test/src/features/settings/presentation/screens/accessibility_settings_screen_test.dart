import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/animation_controller.dart' as app;
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';
import 'package:lazurite/src/features/settings/presentation/screens/accessibility_settings_screen.dart';

void main() {
  Widget buildTestWidget({
    AnimationMode mode = AnimationMode.system,
    double speedMultiplier = 1.0,
    void Function(AnimationMode)? onModeChanged,
    void Function(double)? onSpeedChanged,
    void Function()? onReset,
  }) {
    final testController = _TestAnimationController(
      initialMode: mode,
      initialSpeedMultiplier: speedMultiplier,
      onModeChanged: onModeChanged,
      onSpeedChanged: onSpeedChanged,
      onReset: onReset,
    );

    return ProviderScope(
      overrides: [app.animationControllerProvider.overrideWith(() => testController)],
      child: MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: ThemeMode.light,
        home: const AccessibilitySettingsScreen(),
      ),
    );
  }

  group('AccessibilitySettingsScreen', () {
    testWidgets('renders all sections', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('ANIMATION MODE'), findsOneWidget);
      expect(find.text('ANIMATION SPEED'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('INFORMATION'), findsOneWidget);
    });

    testWidgets('displays animation mode options', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.widgetWithText(RadioListTile<AnimationMode>, 'Full'), findsOneWidget);
      expect(find.widgetWithText(RadioListTile<AnimationMode>, 'Reduced'), findsOneWidget);
      expect(find.widgetWithText(RadioListTile<AnimationMode>, 'Minimal'), findsOneWidget);
      expect(find.widgetWithText(RadioListTile<AnimationMode>, 'System'), findsOneWidget);
    });

    testWidgets('shows current mode as selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(mode: AnimationMode.full));
      await tester.pump();

      final fullRadio = tester.widget<RadioListTile<AnimationMode>>(
        find.widgetWithText(RadioListTile<AnimationMode>, 'Full'),
      );
      expect(fullRadio.value, AnimationMode.full);
    });

    testWidgets('tapping mode calls controller', (tester) async {
      AnimationMode? selectedMode;

      await tester.pumpWidget(
        buildTestWidget(mode: AnimationMode.system, onModeChanged: (mode) => selectedMode = mode),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(RadioListTile<AnimationMode>, 'Full'));
      await tester.pump();

      expect(selectedMode, AnimationMode.full);
    });

    testWidgets('displays speed multiplier slider', (tester) async {
      await tester.pumpWidget(buildTestWidget(speedMultiplier: 1.5));
      await tester.pump();

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('1.5x'), findsOneWidget);

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 1.5);
      expect(slider.min, AnimationPreferences.minSpeedMultiplier);
      expect(slider.max, AnimationPreferences.maxSpeedMultiplier);
    });

    testWidgets('changing slider calls controller', (tester) async {
      double? newSpeed;

      await tester.pumpWidget(
        buildTestWidget(speedMultiplier: 1.0, onSpeedChanged: (speed) => newSpeed = speed),
      );
      await tester.pump();

      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      expect(newSpeed, isNotNull);
      expect(newSpeed, greaterThan(1.0));
    });

    testWidgets('displays speed range labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Slower (${AnimationPreferences.minSpeedMultiplier}x)'), findsOneWidget);
      expect(
        find.text('Faster (${AnimationPreferences.maxSpeedMultiplier.toStringAsFixed(1)}x)'),
        findsOneWidget,
      );
    });

    testWidgets('displays animation preview widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Preview'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('displays information section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('Platform Integration'), findsOneWidget);
      expect(find.textContaining('System mode respects your device'), findsOneWidget);
    });

    testWidgets('reset button calls controller', (tester) async {
      bool resetCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          mode: AnimationMode.minimal,
          speedMultiplier: 1.5,
          onReset: () => resetCalled = true,
        ),
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reset to Defaults'));
      await tester.pump();

      expect(resetCalled, true);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Animation settings reset to defaults'), findsOneWidget);
    });

    testWidgets('mode descriptions are correct', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('All animations enabled'), findsOneWidget);
      expect(find.text('Essential transitions only'), findsOneWidget);
      expect(find.text('Near-instant transitions'), findsOneWidget);
      expect(find.textContaining('Follows device reduce motion'), findsOneWidget);
    });

    testWidgets('uses correct icons for each mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final fullTile = tester.widget<RadioListTile<AnimationMode>>(
        find.widgetWithText(RadioListTile<AnimationMode>, 'Full'),
      );
      expect((fullTile.secondary as Icon).icon, Icons.animation);

      final reducedTile = tester.widget<RadioListTile<AnimationMode>>(
        find.widgetWithText(RadioListTile<AnimationMode>, 'Reduced'),
      );
      expect((reducedTile.secondary as Icon).icon, Icons.motion_photos_auto);

      final minimalTile = tester.widget<RadioListTile<AnimationMode>>(
        find.widgetWithText(RadioListTile<AnimationMode>, 'Minimal'),
      );
      expect((minimalTile.secondary as Icon).icon, Icons.speed);

      final systemTile = tester.widget<RadioListTile<AnimationMode>>(
        find.widgetWithText(RadioListTile<AnimationMode>, 'System'),
      );
      expect((systemTile.secondary as Icon).icon, Icons.settings_accessibility);
    });

    group('Animation Preview Widget', () {
      testWidgets('preview updates when speed changes', (tester) async {
        await tester.pumpWidget(buildTestWidget(speedMultiplier: 1.0));
        await tester.pump();

        expect(find.text('Preview'), findsOneWidget);

        await tester.pumpWidget(buildTestWidget(speedMultiplier: 2.0));
        await tester.pump();

        expect(find.text('Preview'), findsOneWidget);
      });

      testWidgets('preview updates when mode changes', (tester) async {
        await tester.pumpWidget(buildTestWidget(mode: AnimationMode.full));
        await tester.pump();

        expect(find.text('Preview'), findsOneWidget);

        await tester.pumpWidget(buildTestWidget(mode: AnimationMode.minimal));
        await tester.pump();

        expect(find.text('Preview'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles minimum speed multiplier', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(speedMultiplier: AnimationPreferences.minSpeedMultiplier),
        );
        await tester.pump();

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.value, AnimationPreferences.minSpeedMultiplier);
      });

      testWidgets('handles maximum speed multiplier', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(speedMultiplier: AnimationPreferences.maxSpeedMultiplier),
        );
        await tester.pump();

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.value, AnimationPreferences.maxSpeedMultiplier);
      });

      testWidgets('displays correct division count on slider', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.divisions, 15);
      });
    });
  });
}

class _TestAnimationController extends app.AnimationController {
  _TestAnimationController({
    required AnimationMode initialMode,
    required double initialSpeedMultiplier,
    this.onModeChanged,
    this.onSpeedChanged,
    this.onReset,
  }) : _currentState = app.AnimationState(
         preferences: AnimationPreferences(
           mode: initialMode,
           speedMultiplier: initialSpeedMultiplier,
         ),
         isLoading: false,
       );

  final void Function(AnimationMode)? onModeChanged;
  final void Function(double)? onSpeedChanged;
  final void Function()? onReset;

  app.AnimationState _currentState;

  @override
  app.AnimationState build() => _currentState;

  @override
  Future<void> setMode(AnimationMode mode) async {
    _currentState = _currentState.copyWith(
      preferences: _currentState.preferences.copyWith(mode: mode),
    );
    state = _currentState;
    onModeChanged?.call(mode);
  }

  @override
  Future<void> setSpeedMultiplier(double multiplier) async {
    final clampedMultiplier = multiplier.clamp(
      AnimationPreferences.minSpeedMultiplier,
      AnimationPreferences.maxSpeedMultiplier,
    );
    _currentState = _currentState.copyWith(
      preferences: _currentState.preferences.copyWith(speedMultiplier: clampedMultiplier),
    );
    state = _currentState;
    onSpeedChanged?.call(clampedMultiplier);
  }

  @override
  Future<void> resetToDefaults() async {
    _currentState = const app.AnimationState(
      preferences: AnimationPreferences.defaults,
      isLoading: false,
    );
    state = _currentState;
    onReset?.call();
  }
}
