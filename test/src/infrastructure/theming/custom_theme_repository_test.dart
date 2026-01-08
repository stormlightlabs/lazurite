import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/custom_theme_draft.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/daos/custom_theme_dao.dart';
import 'package:lazurite/src/infrastructure/theming/custom_theme_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomThemeDao extends Mock implements CustomThemeDao {}

class FakeCustomThemeDraft extends Fake implements CustomThemeDraft {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCustomThemeDraft());
  });

  late MockCustomThemeDao mockDao;
  late CustomThemeRepository repository;
  late List<ThemePack> availablePacks;

  setUp(() {
    mockDao = MockCustomThemeDao();

    availablePacks = [
      ThemePack(
        id: 'oxocarbon',
        name: 'Oxocarbon',
        author: 'IBM',
        variants: [
          ThemeVariant(
            id: 'oxocarbon-dark',
            name: 'Dark',
            brightness: Brightness.dark,
            spec: const ThemeSpec(surface: Color(0xFF1A1A1A)),
            derivedScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
      ThemePack(
        id: 'nord',
        name: 'Nord',
        author: 'Arctic Ice Studio',
        variants: [
          ThemeVariant(
            id: 'nord-dark',
            name: 'Dark',
            brightness: Brightness.dark,
            spec: const ThemeSpec(surface: Color(0xFF2E3440)),
            derivedScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    ];

    repository = CustomThemeRepository(
      mockDao,
      availablePacks,
      const Logger('CustomThemeRepositoryTest'),
    );
  });

  CustomThemeDraft createTestDraft({
    String id = 'test-id',
    String name = 'Test Theme',
    String basePackId = 'oxocarbon',
    ThemeRoleOverrides overrides = ThemeRoleOverrides.empty,
  }) {
    final now = DateTime.now();
    return CustomThemeDraft(
      id: id,
      name: name,
      basePackId: basePackId,
      overrides: overrides,
      typographyScale: TypographyScale.normal,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('validate', () {
    test('returns valid for correct draft', () {
      final draft = createTestDraft();
      final result = repository.validate(draft);

      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });

    test('returns invalid for empty id', () {
      final draft = createTestDraft(id: '');
      final result = repository.validate(draft);

      expect(result.isValid, isFalse);
      expect(result.error, contains('ID'));
    });

    test('returns invalid for empty name', () {
      final draft = createTestDraft(name: '');
      final result = repository.validate(draft);

      expect(result.isValid, isFalse);
      expect(result.error, contains('name'));
    });

    test('returns invalid for unknown base pack', () {
      final draft = createTestDraft(basePackId: 'unknown-pack');
      final result = repository.validate(draft);

      expect(result.isValid, isFalse);
      expect(result.error, contains('unknown-pack'));
      expect(result.error, contains('not found'));
    });

    test('returns valid for known base pack', () {
      final draft = createTestDraft(basePackId: 'nord');
      final result = repository.validate(draft);

      expect(result.isValid, isTrue);
    });
  });

  group('save', () {
    test('saves valid draft', () async {
      final draft = createTestDraft();
      when(() => mockDao.save(draft)).thenAnswer((_) async {});

      final result = await repository.save(draft);

      expect(result.isValid, isTrue);
      verify(() => mockDao.save(draft)).called(1);
    });

    test('does not save invalid draft', () async {
      final draft = createTestDraft(basePackId: 'unknown');

      final result = await repository.save(draft);

      expect(result.isValid, isFalse);
      verifyNever(() => mockDao.save(any()));
    });
  });

  group('delete', () {
    test('calls dao deleteById', () async {
      when(() => mockDao.deleteById('test-id')).thenAnswer((_) async => 1);

      await repository.delete('test-id');

      verify(() => mockDao.deleteById('test-id')).called(1);
    });
  });

  group('importFromJson', () {
    test('imports valid JSON', () async {
      const json = '''
{
  "version": 1,
  "id": "imported-theme",
  "name": "Imported Theme",
  "basePack": "oxocarbon",
  "overrides": {"primary": "#0085FF"},
  "typography": "normal",
  "createdAt": "2024-01-01T00:00:00.000",
  "updatedAt": "2024-01-01T00:00:00.000"
}
''';
      when(() => mockDao.save(any())).thenAnswer((_) async {});

      final draft = await repository.importFromJson(json);

      expect(draft.id, 'imported-theme');
      expect(draft.name, 'Imported Theme');
      expect(draft.overrides.primary, const Color(0xFF0085FF));
      verify(() => mockDao.save(any())).called(1);
    });

    test('throws on invalid JSON', () async {
      expect(() => repository.importFromJson('not valid json'), throwsA(isA<FormatException>()));
      verifyNever(() => mockDao.save(any()));
    });

    test('throws on unknown base pack', () async {
      const json = '''
{
  "version": 1,
  "id": "bad-theme",
  "name": "Bad Theme",
  "basePack": "unknown-pack",
  "overrides": {},
  "typography": "normal"
}
''';

      expect(
        () => repository.importFromJson(json),
        throwsA(
          isA<FormatException>().having((e) => e.message, 'message', contains('unknown-pack')),
        ),
      );
    });
  });

  group('exportToJson', () {
    test('exports existing theme', () async {
      final draft = createTestDraft(id: 'export-test', name: 'Export Test');
      when(() => mockDao.getById('export-test')).thenAnswer((_) async => draft);

      final json = await repository.exportToJson('export-test');

      expect(json, contains('"name": "Export Test"'));
      expect(json, contains('"basePack": "oxocarbon"'));
    });

    test('throws for nonexistent theme', () async {
      when(() => mockDao.getById('nonexistent')).thenAnswer((_) async => null);

      expect(() => repository.exportToJson('nonexistent'), throwsA(isA<ArgumentError>()));
    });
  });

  group('createFromPack', () {
    test('creates draft with generated id', () {
      final draft = repository.createFromPack(name: 'New Theme', basePackId: 'oxocarbon');

      expect(draft.id, startsWith('custom-'));
      expect(draft.name, 'New Theme');
      expect(draft.basePackId, 'oxocarbon');
    });

    test('creates draft with overrides', () {
      final draft = repository.createFromPack(
        name: 'Customized',
        basePackId: 'nord',
        overrides: const ThemeRoleOverrides(primary: Color(0xFFFF0000)),
        typographyScale: TypographyScale.large,
      );

      expect(draft.overrides.primary, const Color(0xFFFF0000));
      expect(draft.typographyScale, TypographyScale.large);
    });
  });

  group('pass-through methods', () {
    test('watchAll calls dao', () {
      when(() => mockDao.watchAll()).thenAnswer((_) => Stream.value([]));

      repository.watchAll();

      verify(() => mockDao.watchAll()).called(1);
    });

    test('getAll calls dao', () async {
      when(() => mockDao.getAll()).thenAnswer((_) async => []);

      await repository.getAll();

      verify(() => mockDao.getAll()).called(1);
    });

    test('getById calls dao', () async {
      when(() => mockDao.getById('id')).thenAnswer((_) async => null);

      await repository.getById('id');

      verify(() => mockDao.getById('id')).called(1);
    });

    test('watchById calls dao', () {
      when(() => mockDao.watchById('id')).thenAnswer((_) => Stream.value(null));

      repository.watchById('id');

      verify(() => mockDao.watchById('id')).called(1);
    });
  });
}
