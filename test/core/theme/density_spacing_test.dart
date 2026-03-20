import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/density_spacing.dart';
import 'package:lazurite/core/theme/ui_density.dart';

void main() {
  group('DensitySpacing', () {
    group('fromDensity', () {
      test('compact uses 0.75 scale', () {
        final spacing = DensitySpacing.fromDensity(UiDensity.compact);
        expect(spacing.scale, 0.75);
      });

      test('standard uses 1.0 scale', () {
        final spacing = DensitySpacing.fromDensity(UiDensity.standard);
        expect(spacing.scale, 1.0);
      });

      test('relaxed uses 1.25 scale', () {
        final spacing = DensitySpacing.fromDensity(UiDensity.relaxed);
        expect(spacing.scale, 1.25);
      });
    });

    group('spacing values at standard (1.0) scale', () {
      late DensitySpacing spacing;

      setUp(() {
        spacing = DensitySpacing.fromDensity(UiDensity.standard);
      });

      test('xs is 4.0', () => expect(spacing.xs, 4.0));
      test('sm is 8.0', () => expect(spacing.sm, 8.0));
      test('md is 16.0', () => expect(spacing.md, 16.0));
      test('lg is 24.0', () => expect(spacing.lg, 24.0));
      test('xl is 32.0', () => expect(spacing.xl, 32.0));
      test('xxl is 48.0', () => expect(spacing.xxl, 48.0));
    });

    group('spacing values scale correctly', () {
      test('compact halves relative to relaxed', () {
        final compact = DensitySpacing.fromDensity(UiDensity.compact);
        final relaxed = DensitySpacing.fromDensity(UiDensity.relaxed);
        expect(compact.md, lessThan(relaxed.md));
      });

      test('all spacing values are proportional to scale', () {
        const scale = 2.0;
        const spacing = DensitySpacing(scale: scale);
        expect(spacing.xs, 4.0 * scale);
        expect(spacing.sm, 8.0 * scale);
        expect(spacing.md, 16.0 * scale);
        expect(spacing.lg, 24.0 * scale);
        expect(spacing.xl, 32.0 * scale);
        expect(spacing.xxl, 48.0 * scale);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated scale', () {
        const original = DensitySpacing(scale: 1.0);
        final copy = original.copyWith(scale: 0.5);
        expect(copy.scale, 0.5);
        expect(original.scale, 1.0);
      });

      test('preserves scale when not provided', () {
        const original = DensitySpacing(scale: 1.25);
        final copy = original.copyWith();
        expect(copy.scale, 1.25);
      });
    });

    group('lerp', () {
      test('lerps scale between two instances', () {
        const a = DensitySpacing(scale: 0.75);
        const b = DensitySpacing(scale: 1.25);
        final mid = a.lerp(b, 0.5);
        expect(mid.scale, closeTo(1.0, 0.001));
      });

      test('lerp at t=0 returns self values', () {
        const a = DensitySpacing(scale: 0.75);
        const b = DensitySpacing(scale: 1.25);
        final result = a.lerp(b, 0.0);
        expect(result.scale, 0.75);
      });

      test('lerp at t=1 returns other values', () {
        const a = DensitySpacing(scale: 0.75);
        const b = DensitySpacing(scale: 1.25);
        final result = a.lerp(b, 1.0);
        expect(result.scale, 1.25);
      });

      test('lerp with null returns self', () {
        const a = DensitySpacing(scale: 1.0);
        final result = a.lerp(null, 0.5);
        expect(result, a);
      });
    });

    group('equality', () {
      test('equal when scale is the same', () {
        const a = DensitySpacing(scale: 1.0);
        const b = DensitySpacing(scale: 1.0);
        expect(a, equals(b));
      });

      test('not equal when scale differs', () {
        const a = DensitySpacing(scale: 1.0);
        const b = DensitySpacing(scale: 1.25);
        expect(a, isNot(equals(b)));
      });

      test('hashCode is equal for same scale', () {
        const a = DensitySpacing(scale: 1.0);
        const b = DensitySpacing(scale: 1.0);
        expect(a.hashCode, b.hashCode);
      });
    });
  });
}
