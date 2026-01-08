import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';

void main() {
  group('AnimationMode', () {
    test('has all expected values', () {
      expect(AnimationMode.values, hasLength(4));
      expect(AnimationMode.values, contains(AnimationMode.full));
      expect(AnimationMode.values, contains(AnimationMode.reduced));
      expect(AnimationMode.values, contains(AnimationMode.minimal));
      expect(AnimationMode.values, contains(AnimationMode.system));
    });
  });

  group('AnimationPreferences', () {
    group('constructor', () {
      test('creates with default values', () {
        const prefs = AnimationPreferences();

        expect(prefs.mode, AnimationMode.system);
        expect(prefs.speedMultiplier, 1.0);
      });

      test('creates with custom values', () {
        const prefs = AnimationPreferences(mode: AnimationMode.reduced, speedMultiplier: 1.5);

        expect(prefs.mode, AnimationMode.reduced);
        expect(prefs.speedMultiplier, 1.5);
      });

      test('defaults matches expected values', () {
        expect(AnimationPreferences.defaults.mode, AnimationMode.system);
        expect(AnimationPreferences.defaults.speedMultiplier, 1.0);
      });
    });

    group('speed multiplier validation', () {
      test('allows minimum value', () {
        const prefs = AnimationPreferences(
          speedMultiplier: AnimationPreferences.minSpeedMultiplier,
        );
        expect(prefs.speedMultiplier, 0.5);
      });

      test('allows maximum value', () {
        const prefs = AnimationPreferences(
          speedMultiplier: AnimationPreferences.maxSpeedMultiplier,
        );
        expect(prefs.speedMultiplier, 2.0);
      });

      test('allows values within range', () {
        const prefs = AnimationPreferences(speedMultiplier: 1.25);
        expect(prefs.speedMultiplier, 1.25);
      });
    });

    group('resolveMode', () {
      test('returns mode when not system', () {
        const prefs = AnimationPreferences(mode: AnimationMode.full);

        expect(prefs.resolveMode(platformReduceMotion: false), AnimationMode.full);
        expect(prefs.resolveMode(platformReduceMotion: true), AnimationMode.full);
      });

      test('returns full when system and platform does not reduce motion', () {
        const prefs = AnimationPreferences(mode: AnimationMode.system);

        expect(prefs.resolveMode(platformReduceMotion: false), AnimationMode.full);
      });

      test('returns reduced when system and platform reduces motion', () {
        const prefs = AnimationPreferences(mode: AnimationMode.system);

        expect(prefs.resolveMode(platformReduceMotion: true), AnimationMode.reduced);
      });

      test('reduced mode is not affected by platform settings', () {
        const prefs = AnimationPreferences(mode: AnimationMode.reduced);

        expect(prefs.resolveMode(platformReduceMotion: false), AnimationMode.reduced);
      });

      test('minimal mode is not affected by platform settings', () {
        const prefs = AnimationPreferences(mode: AnimationMode.minimal);

        expect(prefs.resolveMode(platformReduceMotion: false), AnimationMode.minimal);
      });
    });

    group('getEffectiveDuration', () {
      test('returns zero for minimal mode', () {
        const prefs = AnimationPreferences(mode: AnimationMode.minimal);
        const baseDuration = Duration(milliseconds: 300);

        final result = prefs.getEffectiveDuration(baseDuration, platformReduceMotion: false);

        expect(result, Duration.zero);
      });

      test('returns 50% for reduced mode at 1.0x speed', () {
        const prefs = AnimationPreferences(mode: AnimationMode.reduced, speedMultiplier: 1.0);
        const baseDuration = Duration(milliseconds: 300);

        final result = prefs.getEffectiveDuration(baseDuration, platformReduceMotion: false);

        expect(result, const Duration(milliseconds: 150));
      });

      test('returns full duration for full mode at 1.0x speed', () {
        const prefs = AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.0);
        const baseDuration = Duration(milliseconds: 300);

        final result = prefs.getEffectiveDuration(baseDuration, platformReduceMotion: false);

        expect(result, const Duration(milliseconds: 300));
      });

      test('applies speed multiplier to full mode', () {
        const prefs = AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 2.0);
        const baseDuration = Duration(milliseconds: 300);

        final result = prefs.getEffectiveDuration(baseDuration, platformReduceMotion: false);

        expect(result, const Duration(milliseconds: 150));
      });

      test('applies speed multiplier to reduced mode', () {
        const prefs = AnimationPreferences(mode: AnimationMode.reduced, speedMultiplier: 0.5);
        const baseDuration = Duration(milliseconds: 300);

        final result = prefs.getEffectiveDuration(baseDuration, platformReduceMotion: false);

        expect(result, const Duration(milliseconds: 300));
      });

      test('system mode with reduce motion uses reduced calculation', () {
        const prefs = AnimationPreferences(mode: AnimationMode.system);
        const baseDuration = Duration(milliseconds: 300);

        final result = prefs.getEffectiveDuration(baseDuration, platformReduceMotion: true);

        expect(result, const Duration(milliseconds: 150));
      });

      test('system mode without reduce motion uses full calculation', () {
        const prefs = AnimationPreferences(mode: AnimationMode.system);
        const baseDuration = Duration(milliseconds: 300);

        final result = prefs.getEffectiveDuration(baseDuration, platformReduceMotion: false);

        expect(result, const Duration(milliseconds: 300));
      });
    });

    group('shouldDisableAnimations', () {
      test('returns true for minimal mode', () {
        const prefs = AnimationPreferences(mode: AnimationMode.minimal);

        expect(prefs.shouldDisableAnimations(platformReduceMotion: false), isTrue);
      });

      test('returns false for full mode', () {
        const prefs = AnimationPreferences(mode: AnimationMode.full);

        expect(prefs.shouldDisableAnimations(platformReduceMotion: false), isFalse);
      });

      test('returns false for reduced mode', () {
        const prefs = AnimationPreferences(mode: AnimationMode.reduced);

        expect(prefs.shouldDisableAnimations(platformReduceMotion: false), isFalse);
      });

      test('returns false for system mode without platform reduce motion', () {
        const prefs = AnimationPreferences(mode: AnimationMode.system);

        expect(prefs.shouldDisableAnimations(platformReduceMotion: false), isFalse);
      });
    });

    group('copyWith', () {
      test('copies with new mode', () {
        const original = AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5);

        final copied = original.copyWith(mode: AnimationMode.reduced);

        expect(copied.mode, AnimationMode.reduced);
        expect(copied.speedMultiplier, 1.5);
      });

      test('copies with new speed multiplier', () {
        const original = AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5);

        final copied = original.copyWith(speedMultiplier: 0.75);

        expect(copied.mode, AnimationMode.full);
        expect(copied.speedMultiplier, 0.75);
      });

      test('copies with no changes', () {
        const original = AnimationPreferences(mode: AnimationMode.reduced, speedMultiplier: 1.25);

        final copied = original.copyWith();

        expect(copied.mode, original.mode);
        expect(copied.speedMultiplier, original.speedMultiplier);
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const a = AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5);
        const b = AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different mode instances are not equal', () {
        const a = AnimationPreferences(mode: AnimationMode.full);
        const b = AnimationPreferences(mode: AnimationMode.reduced);

        expect(a, isNot(equals(b)));
      });

      test('different speed multiplier instances are not equal', () {
        const a = AnimationPreferences(speedMultiplier: 1.0);
        const b = AnimationPreferences(speedMultiplier: 1.5);

        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const prefs = AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5);

        expect(
          prefs.toString(),
          'AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.5)',
        );
      });
    });
  });
}
