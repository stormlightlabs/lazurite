import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/animation_controller.dart';
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';
import 'package:lazurite/src/infrastructure/db/daos/animation_preferences_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockAnimationPreferencesDao extends Mock implements AnimationPreferencesDao {}

/// Test-specific AnimationController that skips async loading to avoid
/// Riverpod lifecycle issues in unit tests.
class TestAnimationController extends AnimationController {
  @override
  AnimationState build() =>
      const AnimationState(preferences: AnimationPreferences.defaults, isLoading: false);

  @override
  Future<void> setMode(AnimationMode mode) async {
    state = state.copyWith(preferences: state.preferences.copyWith(mode: mode));
    await ref.read(animationPreferencesDaoProvider).set(AnimationSettingsKeys.mode, mode.name);
  }

  @override
  Future<void> setSpeedMultiplier(double multiplier) async {
    final clamped = multiplier.clamp(
      AnimationPreferences.minSpeedMultiplier,
      AnimationPreferences.maxSpeedMultiplier,
    );
    state = state.copyWith(preferences: state.preferences.copyWith(speedMultiplier: clamped));
    await ref
        .read(animationPreferencesDaoProvider)
        .set(AnimationSettingsKeys.speedMultiplier, clamped.toString());
  }

  @override
  Future<void> resetToDefaults() async {
    state = const AnimationState(preferences: AnimationPreferences.defaults, isLoading: false);
    await ref.read(animationPreferencesDaoProvider).clearAll();
  }
}

void main() {
  late MockAnimationPreferencesDao mockDao;
  late ProviderContainer container;

  setUp(() {
    mockDao = MockAnimationPreferencesDao();
    when(() => mockDao.get(any())).thenAnswer((_) async => null);
    when(() => mockDao.set(any(), any())).thenAnswer((_) async {});
    when(() => mockDao.clearAll()).thenAnswer((_) async => 0);
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        animationPreferencesDaoProvider.overrideWithValue(mockDao),
        animationControllerProvider.overrideWith(TestAnimationController.new),
      ],
    );
  }

  group('AnimationController', () {
    group('initial state', () {
      test('defaults to system mode and 1.0x speed', () {
        container = createContainer();

        final state = container.read(animationControllerProvider);

        expect(state.mode, AnimationMode.system);
        expect(state.speedMultiplier, 1.0);
        expect(state.isLoading, isFalse);
      });

      test('preferences use defaults', () {
        container = createContainer();

        final state = container.read(animationControllerProvider);

        expect(state.preferences, AnimationPreferences.defaults);
      });
    });

    group('setMode', () {
      test('updates state with new mode', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.reduced);

        expect(container.read(animationControllerProvider).mode, AnimationMode.reduced);
      });

      test('persists mode to database', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.full);

        verify(() => mockDao.set(AnimationSettingsKeys.mode, 'full')).called(1);
      });

      test('can set to minimal mode', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.minimal);

        expect(container.read(animationControllerProvider).mode, AnimationMode.minimal);
        verify(() => mockDao.set(AnimationSettingsKeys.mode, 'minimal')).called(1);
      });

      test('preserves speed multiplier when changing mode', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setSpeedMultiplier(1.5);
        await notifier.setMode(AnimationMode.reduced);

        final state = container.read(animationControllerProvider);
        expect(state.mode, AnimationMode.reduced);
        expect(state.speedMultiplier, 1.5);
      });
    });

    group('setSpeedMultiplier', () {
      test('updates state with new speed multiplier', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setSpeedMultiplier(1.5);

        expect(container.read(animationControllerProvider).speedMultiplier, 1.5);
      });

      test('persists speed multiplier to database', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setSpeedMultiplier(0.75);

        verify(() => mockDao.set(AnimationSettingsKeys.speedMultiplier, '0.75')).called(1);
      });

      test('clamps value to minimum', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setSpeedMultiplier(0.1);

        expect(
          container.read(animationControllerProvider).speedMultiplier,
          AnimationPreferences.minSpeedMultiplier,
        );
        verify(() => mockDao.set(AnimationSettingsKeys.speedMultiplier, '0.5')).called(1);
      });

      test('clamps value to maximum', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setSpeedMultiplier(5.0);

        expect(
          container.read(animationControllerProvider).speedMultiplier,
          AnimationPreferences.maxSpeedMultiplier,
        );
        verify(() => mockDao.set(AnimationSettingsKeys.speedMultiplier, '2.0')).called(1);
      });

      test('preserves mode when changing speed multiplier', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.full);
        await notifier.setSpeedMultiplier(0.5);

        final state = container.read(animationControllerProvider);
        expect(state.mode, AnimationMode.full);
        expect(state.speedMultiplier, 0.5);
      });
    });

    group('getEffectiveDuration', () {
      test('delegates to preferences', () {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        final duration = notifier.getEffectiveDuration(
          const Duration(milliseconds: 300),
          platformReduceMotion: false,
        );

        expect(duration, const Duration(milliseconds: 300));
      });

      test('returns zero for minimal mode', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.minimal);

        final duration = notifier.getEffectiveDuration(
          const Duration(milliseconds: 300),
          platformReduceMotion: false,
        );

        expect(duration, Duration.zero);
      });
    });

    group('resolveMode', () {
      test('returns effective mode considering platform settings', () {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        expect(notifier.resolveMode(platformReduceMotion: true), AnimationMode.reduced);
        expect(notifier.resolveMode(platformReduceMotion: false), AnimationMode.full);
      });

      test('returns explicit mode regardless of platform settings', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.full);

        expect(notifier.resolveMode(platformReduceMotion: true), AnimationMode.full);
      });
    });

    group('shouldDisableAnimations', () {
      test('returns true for minimal mode', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.minimal);

        expect(notifier.shouldDisableAnimations(platformReduceMotion: false), isTrue);
      });

      test('returns false for other modes', () {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        expect(notifier.shouldDisableAnimations(platformReduceMotion: false), isFalse);
      });
    });

    group('resetToDefaults', () {
      test('resets state to defaults', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.setMode(AnimationMode.full);
        await notifier.setSpeedMultiplier(1.5);

        await notifier.resetToDefaults();

        final state = container.read(animationControllerProvider);
        expect(state.mode, AnimationMode.system);
        expect(state.speedMultiplier, 1.0);
      });

      test('clears all preferences from database', () async {
        container = createContainer();
        final notifier = container.read(animationControllerProvider.notifier);

        await notifier.resetToDefaults();

        verify(() => mockDao.clearAll()).called(1);
      });
    });
  });

  group('AnimationState', () {
    test('copyWith creates modified copy', () {
      const original = AnimationState(
        preferences: AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.0),
        isLoading: true,
      );

      final copied = original.copyWith(isLoading: false);

      expect(copied.isLoading, isFalse);
      expect(copied.preferences, original.preferences);
    });

    test('mode convenience accessor works', () {
      const state = AnimationState(preferences: AnimationPreferences(mode: AnimationMode.reduced));

      expect(state.mode, AnimationMode.reduced);
    });

    test('speedMultiplier convenience accessor works', () {
      const state = AnimationState(preferences: AnimationPreferences(speedMultiplier: 1.5));

      expect(state.speedMultiplier, 1.5);
    });

    test('equality works', () {
      const a = AnimationState(
        preferences: AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5),
        isLoading: false,
      );
      const b = AnimationState(
        preferences: AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5),
        isLoading: false,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('AnimationSettingsKeys', () {
    test('has correct key values', () {
      expect(AnimationSettingsKeys.mode, 'mode');
      expect(AnimationSettingsKeys.speedMultiplier, 'speedMultiplier');
    });
  });
}
