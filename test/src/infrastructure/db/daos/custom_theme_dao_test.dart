import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/custom_theme_draft.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/custom_theme_dao.dart';

void main() {
  late AppDatabase db;
  late CustomThemeDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.customThemeDao;
  });

  tearDown(() async {
    await db.close();
  });

  CustomThemeDraft createTestDraft({
    String? id,
    String name = 'Test Theme',
    String basePackId = 'oxocarbon',
    ThemeRoleOverrides overrides = ThemeRoleOverrides.empty,
    TypographyScale typographyScale = TypographyScale.normal,
  }) {
    final now = DateTime.now();
    return CustomThemeDraft(
      id: id ?? 'test-${now.millisecondsSinceEpoch}',
      name: name,
      basePackId: basePackId,
      overrides: overrides,
      typographyScale: typographyScale,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('getAll', () {
    test('returns empty list when no themes exist', () async {
      final result = await dao.getAll();
      expect(result, isEmpty);
    });

    test('returns all themes ordered by creation date descending', () async {
      final earlier = DateTime(2024, 1, 1, 10, 0);
      final later = DateTime(2024, 1, 1, 11, 0);

      final theme1 = CustomThemeDraft(
        id: 'theme-1',
        name: 'First',
        basePackId: 'oxocarbon',
        overrides: ThemeRoleOverrides.empty,
        typographyScale: TypographyScale.normal,
        createdAt: earlier,
        updatedAt: earlier,
      );
      await dao.save(theme1);

      final theme2 = CustomThemeDraft(
        id: 'theme-2',
        name: 'Second',
        basePackId: 'oxocarbon',
        overrides: ThemeRoleOverrides.empty,
        typographyScale: TypographyScale.normal,
        createdAt: later,
        updatedAt: later,
      );
      await dao.save(theme2);

      final result = await dao.getAll();

      expect(result, hasLength(2));
      expect(result[0].name, 'Second'); // Newer first
      expect(result[1].name, 'First');
    });
  });

  group('getById', () {
    test('returns null for nonexistent theme', () async {
      final result = await dao.getById('nonexistent');
      expect(result, isNull);
    });

    test('returns theme for existing id', () async {
      final draft = createTestDraft(id: 'my-theme', name: 'My Theme');
      await dao.save(draft);

      final result = await dao.getById('my-theme');

      expect(result, isNotNull);
      expect(result!.id, 'my-theme');
      expect(result.name, 'My Theme');
      expect(result.basePackId, 'oxocarbon');
    });

    test('preserves overrides and typography', () async {
      final draft = createTestDraft(
        id: 'themed',
        overrides: const ThemeRoleOverrides(
          primary: Color(0xFF0085FF),
          secondary: Color(0xFF33FF57),
        ),
        typographyScale: TypographyScale.large,
      );
      await dao.save(draft);

      final result = await dao.getById('themed');

      expect(result!.overrides.primary, const Color(0xFF0085FF));
      expect(result.overrides.secondary, const Color(0xFF33FF57));
      expect(result.typographyScale, TypographyScale.large);
    });
  });

  group('save', () {
    test('inserts new theme', () async {
      final draft = createTestDraft(id: 'new-theme');
      await dao.save(draft);

      final result = await dao.getById('new-theme');
      expect(result, isNotNull);
    });

    test('updates existing theme', () async {
      final draft = createTestDraft(id: 'update-test', name: 'Original');
      await dao.save(draft);

      final updated = draft.copyWith(name: 'Updated');
      await dao.save(updated);

      final result = await dao.getById('update-test');
      expect(result!.name, 'Updated');

      final all = await dao.getAll();
      expect(all, hasLength(1));
    });
  });

  group('deleteById', () {
    test('deletes existing theme', () async {
      final draft = createTestDraft(id: 'to-delete');
      await dao.save(draft);

      final deleted = await dao.deleteById('to-delete');
      expect(deleted, 1);

      final result = await dao.getById('to-delete');
      expect(result, isNull);
    });

    test('returns 0 when theme does not exist', () async {
      final deleted = await dao.deleteById('nonexistent');
      expect(deleted, 0);
    });
  });

  group('deleteAll', () {
    test('deletes all themes', () async {
      await dao.save(createTestDraft(id: 'theme-1'));
      await dao.save(createTestDraft(id: 'theme-2'));
      await dao.save(createTestDraft(id: 'theme-3'));

      final deleted = await dao.deleteAll();
      expect(deleted, 3);

      final result = await dao.getAll();
      expect(result, isEmpty);
    });
  });

  group('watchAll', () {
    test('emits empty list when no themes exist', () async {
      final result = await dao.watchAll().first;
      expect(result, isEmpty);
    });

    test('emits updates when themes change', () async {
      final emissions = <List<CustomThemeDraft>>[];
      final subscription = dao.watchAll().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.save(createTestDraft(id: 'watch-test', name: 'Test'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(emissions.last.any((d) => d.name == 'Test'), isTrue);
    });
  });

  group('watchById', () {
    test('emits null for nonexistent theme', () async {
      final result = await dao.watchById('nonexistent').first;
      expect(result, isNull);
    });

    test('emits updates when specific theme changes', () async {
      final draft = createTestDraft(id: 'watch-single', name: 'Original');
      await dao.save(draft);

      final emissions = <CustomThemeDraft?>[];
      final subscription = dao.watchById('watch-single').listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await dao.save(draft.copyWith(name: 'Updated'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(emissions.any((d) => d?.name == 'Original'), isTrue);
      expect(emissions.any((d) => d?.name == 'Updated'), isTrue);
    });
  });
}
