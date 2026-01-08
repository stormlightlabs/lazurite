import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/custom_theme_draft.dart';

void main() {
  group('TypographyScale', () {
    test('scaleFactor returns correct values', () {
      expect(TypographyScale.small.scaleFactor, 0.9);
      expect(TypographyScale.normal.scaleFactor, 1.0);
      expect(TypographyScale.large.scaleFactor, 1.1);
    });

    test('fromString parses valid values', () {
      expect(TypographyScale.fromString('small'), TypographyScale.small);
      expect(TypographyScale.fromString('normal'), TypographyScale.normal);
      expect(TypographyScale.fromString('large'), TypographyScale.large);
    });

    test('fromString defaults to normal for invalid values', () {
      expect(TypographyScale.fromString(null), TypographyScale.normal);
      expect(TypographyScale.fromString('invalid'), TypographyScale.normal);
      expect(TypographyScale.fromString(''), TypographyScale.normal);
    });
  });

  group('ThemeRoleOverrides', () {
    test('empty has no overrides', () {
      const overrides = ThemeRoleOverrides.empty;
      expect(overrides.hasOverrides, isFalse);
      expect(overrides.primary, isNull);
      expect(overrides.secondary, isNull);
    });

    test('hasOverrides returns true when any field is set', () {
      const withPrimary = ThemeRoleOverrides(primary: Color(0xFF0085FF));
      expect(withPrimary.hasOverrides, isTrue);

      const withSurface = ThemeRoleOverrides(surface: Color(0xFF1A1A1A));
      expect(withSurface.hasOverrides, isTrue);
    });

    group('JSON serialization', () {
      test('toJson omits null values', () {
        const overrides = ThemeRoleOverrides(primary: Color(0xFF0085FF));
        final json = overrides.toJson();

        expect(json['primary'], '#0085FF');
        expect(json.containsKey('secondary'), isFalse);
        expect(json.containsKey('surface'), isFalse);
      });

      test('toJson includes all set values', () {
        const overrides = ThemeRoleOverrides(
          primary: Color(0xFF0085FF),
          secondary: Color(0xFF33FF57),
          surfaceContainerLow: Color(0xFF1A1A1A),
        );
        final json = overrides.toJson();

        expect(json['primary'], '#0085FF');
        expect(json['secondary'], '#33FF57');
        expect(json['surfaceContainerLow'], '#1A1A1A');
      });

      test('fromJson parses colors correctly', () {
        final json = {'primary': '#0085FF', 'secondary': '#33FF57'};
        final overrides = ThemeRoleOverrides.fromJson(json);

        expect(overrides.primary, const Color(0xFF0085FF));
        expect(overrides.secondary, const Color(0xFF33FF57));
        expect(overrides.tertiary, isNull);
      });

      test('fromJson handles empty map', () {
        final overrides = ThemeRoleOverrides.fromJson({});
        expect(overrides.hasOverrides, isFalse);
      });

      test('fromJson handles 8-character hex with alpha', () {
        final json = {'primary': '#FF0085FF'};
        final overrides = ThemeRoleOverrides.fromJson(json);
        expect(overrides.primary, const Color(0xFF0085FF));
      });

      test('roundtrip preserves values', () {
        const original = ThemeRoleOverrides(
          primary: Color(0xFF0085FF),
          secondary: Color(0xFF33FF57),
          tertiary: Color(0xFFFF5733),
          surface: Color(0xFF1A1A1A),
          surfaceContainerLow: Color(0xFF2A2A2A),
          surfaceContainerHigh: Color(0xFF3A3A3A),
          outlineVariant: Color(0xFF4A4A4A),
        );
        final json = original.toJson();
        final restored = ThemeRoleOverrides.fromJson(json);

        expect(restored, original);
      });
    });

    group('copyWith', () {
      test('updates specified fields', () {
        const original = ThemeRoleOverrides(primary: Color(0xFF0085FF));
        final updated = original.copyWith(secondary: const Color(0xFF33FF57));

        expect(updated.primary, const Color(0xFF0085FF));
        expect(updated.secondary, const Color(0xFF33FF57));
      });

      test('clear flags remove values', () {
        const original = ThemeRoleOverrides(
          primary: Color(0xFF0085FF),
          secondary: Color(0xFF33FF57),
        );
        final cleared = original.copyWith(clearPrimary: true);

        expect(cleared.primary, isNull);
        expect(cleared.secondary, const Color(0xFF33FF57));
      });
    });

    test('equality works correctly', () {
      const a = ThemeRoleOverrides(primary: Color(0xFF0085FF));
      const b = ThemeRoleOverrides(primary: Color(0xFF0085FF));
      const c = ThemeRoleOverrides(primary: Color(0xFFFF0000));

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('CustomThemeDraft', () {
    late DateTime testTime;

    setUp(() {
      testTime = DateTime(2024, 1, 1, 12, 0);
    });

    CustomThemeDraft createTestDraft({
      String id = 'test-id',
      String name = 'Test Theme',
      String basePackId = 'oxocarbon',
      ThemeRoleOverrides overrides = ThemeRoleOverrides.empty,
      TypographyScale typographyScale = TypographyScale.normal,
    }) {
      return CustomThemeDraft(
        id: id,
        name: name,
        basePackId: basePackId,
        overrides: overrides,
        typographyScale: typographyScale,
        createdAt: testTime,
        updatedAt: testTime,
      );
    }

    test('create factory generates unique ID', () async {
      final draft1 = CustomThemeDraft.create(name: 'Theme 1', basePackId: 'oxocarbon');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final draft2 = CustomThemeDraft.create(name: 'Theme 2', basePackId: 'oxocarbon');

      expect(draft1.id, startsWith('custom-'));
      expect(draft2.id, startsWith('custom-'));
      expect(draft1.id, isNot(draft2.id));
    });

    test('create factory sets timestamps', () {
      final before = DateTime.now();
      final draft = CustomThemeDraft.create(name: 'Test', basePackId: 'oxocarbon');
      final after = DateTime.now();

      expect(draft.createdAt.isAfter(before) || draft.createdAt.isAtSameMomentAs(before), isTrue);
      expect(draft.createdAt.isBefore(after) || draft.createdAt.isAtSameMomentAs(after), isTrue);
      expect(draft.updatedAt, draft.createdAt);
    });

    group('JSON serialization', () {
      test('toJson includes all fields', () {
        final draft = createTestDraft(
          overrides: const ThemeRoleOverrides(primary: Color(0xFF0085FF)),
          typographyScale: TypographyScale.large,
        );
        final json = draft.toJson();

        expect(json['version'], CustomThemeDraft.schemaVersion);
        expect(json['id'], 'test-id');
        expect(json['name'], 'Test Theme');
        expect(json['basePack'], 'oxocarbon');
        expect(json['overrides'], {'primary': '#0085FF'});
        expect(json['typography'], 'large');
        expect(json['createdAt'], testTime.toIso8601String());
        expect(json['updatedAt'], testTime.toIso8601String());
      });

      test('fromJson parses valid JSON', () {
        final json = {
          'version': 1,
          'id': 'my-theme',
          'name': 'My Theme',
          'basePack': 'nord',
          'overrides': {'primary': '#0085FF'},
          'typography': 'small',
          'createdAt': testTime.toIso8601String(),
          'updatedAt': testTime.toIso8601String(),
        };
        final draft = CustomThemeDraft.fromJson(json);

        expect(draft.id, 'my-theme');
        expect(draft.name, 'My Theme');
        expect(draft.basePackId, 'nord');
        expect(draft.overrides.primary, const Color(0xFF0085FF));
        expect(draft.typographyScale, TypographyScale.small);
        expect(draft.createdAt, testTime);
      });

      test('fromJson throws on missing id', () {
        final json = {'name': 'Test', 'basePack': 'oxocarbon'};
        expect(
          () => CustomThemeDraft.fromJson(json),
          throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('id'))),
        );
      });

      test('fromJson throws on missing name', () {
        final json = {'id': 'test', 'basePack': 'oxocarbon'};
        expect(
          () => CustomThemeDraft.fromJson(json),
          throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('name'))),
        );
      });

      test('fromJson throws on missing basePack', () {
        final json = {'id': 'test', 'name': 'Test'};
        expect(
          () => CustomThemeDraft.fromJson(json),
          throwsA(
            isA<FormatException>().having((e) => e.message, 'message', contains('basePack')),
          ),
        );
      });

      test('fromJson throws on unsupported version', () {
        final json = {'version': 999, 'id': 'test', 'name': 'Test', 'basePack': 'oxocarbon'};
        expect(
          () => CustomThemeDraft.fromJson(json),
          throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('version'))),
        );
      });

      test('fromJson handles missing optional fields', () {
        final json = {'id': 'test', 'name': 'Test', 'basePack': 'oxocarbon'};
        final draft = CustomThemeDraft.fromJson(json);

        expect(draft.overrides.hasOverrides, isFalse);
        expect(draft.typographyScale, TypographyScale.normal);
      });

      test('toJsonString produces valid JSON', () {
        final draft = createTestDraft();
        final jsonString = draft.toJsonString();

        expect(() => CustomThemeDraft.fromJsonString(jsonString), returnsNormally);
      });

      test('toJsonString pretty prints when requested', () {
        final draft = createTestDraft();
        final compact = draft.toJsonString(pretty: false);
        final pretty = draft.toJsonString(pretty: true);

        expect(pretty.contains('\n'), isTrue);
        expect(compact.contains('\n'), isFalse);
      });

      test('roundtrip preserves all values', () {
        final original = createTestDraft(
          overrides: const ThemeRoleOverrides(
            primary: Color(0xFF0085FF),
            secondary: Color(0xFF33FF57),
          ),
          typographyScale: TypographyScale.large,
        );
        final jsonString = original.toJsonString();
        final restored = CustomThemeDraft.fromJsonString(jsonString);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.basePackId, original.basePackId);
        expect(restored.overrides, original.overrides);
        expect(restored.typographyScale, original.typographyScale);
      });
    });

    group('copyWith', () {
      test('updates name and sets updatedAt', () {
        final original = createTestDraft();
        final before = DateTime.now();
        final updated = original.copyWith(name: 'New Name');

        expect(updated.name, 'New Name');
        expect(updated.id, original.id);
        expect(updated.basePackId, original.basePackId);
        expect(
          updated.updatedAt.isAfter(before) || updated.updatedAt.isAtSameMomentAs(before),
          isTrue,
        );
      });

      test('updates overrides', () {
        final original = createTestDraft();
        const newOverrides = ThemeRoleOverrides(primary: Color(0xFFFF0000));
        final updated = original.copyWith(overrides: newOverrides);

        expect(updated.overrides.primary, const Color(0xFFFF0000));
      });

      test('preserves createdAt', () {
        final original = createTestDraft();
        final updated = original.copyWith(name: 'New Name');

        expect(updated.createdAt, original.createdAt);
      });
    });

    test('equality works correctly', () {
      final a = createTestDraft();
      final b = createTestDraft();
      final c = createTestDraft(name: 'Different');

      expect(a, b);
      expect(a, isNot(c));
    });

    test('toString includes key info', () {
      final draft = createTestDraft();
      final str = draft.toString();

      expect(str, contains('test-id'));
      expect(str, contains('Test Theme'));
      expect(str, contains('oxocarbon'));
    });
  });
}
