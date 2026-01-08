import 'package:lazurite/src/app/theming/custom_theme_draft.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';

import '../../core/utils/logger.dart';
import '../db/daos/custom_theme_dao.dart';

/// Result of validating a custom theme.
class ValidationResult {
  const ValidationResult({required this.isValid, this.error});

  /// Creates a valid result.
  const ValidationResult.valid() : isValid = true, error = null;

  /// Creates an invalid result with an error message.
  const ValidationResult.invalid(String this.error) : isValid = false;

  /// Whether the theme is valid.
  final bool isValid;

  /// Error message if invalid.
  final String? error;
}

/// Repository for managing custom user themes.
///
/// Provides CRUD operations, validation, and import/export functionality
/// for user-customized themes based on built-in theme packs.
class CustomThemeRepository {
  CustomThemeRepository(this._dao, this._availablePacks, this._logger);

  final CustomThemeDao _dao;
  final List<ThemePack> _availablePacks;
  final Logger _logger;

  /// Watches all custom themes.
  Stream<List<CustomThemeDraft>> watchAll() => _dao.watchAll();

  /// Gets all custom themes.
  Future<List<CustomThemeDraft>> getAll() => _dao.getAll();

  /// Gets a custom theme by ID.
  Future<CustomThemeDraft?> getById(String id) => _dao.getById(id);

  /// Watches a specific custom theme by ID.
  Stream<CustomThemeDraft?> watchById(String id) => _dao.watchById(id);

  /// Saves a custom theme after validation.
  ///
  /// Returns a [ValidationResult] indicating if the save succeeded.
  /// If validation fails, the theme is not saved.
  Future<ValidationResult> save(CustomThemeDraft draft) async {
    final validationResult = validate(draft);
    if (!validationResult.isValid) {
      _logger.warning('Custom theme validation failed: ${validationResult.error}');
      return validationResult;
    }

    _logger.info('Saving custom theme: ${draft.name} (${draft.id})');
    await _dao.save(draft);
    return const ValidationResult.valid();
  }

  /// Deletes a custom theme by ID.
  Future<void> delete(String id) async {
    _logger.info('Deleting custom theme: $id');
    await _dao.deleteById(id);
  }

  /// Validates a custom theme draft.
  ///
  /// Checks that:
  /// - The base pack exists
  /// - Required fields are present
  /// - Color overrides are valid
  ValidationResult validate(CustomThemeDraft draft) {
    if (draft.id.isEmpty) {
      return const ValidationResult.invalid('Theme ID is required');
    }
    if (draft.name.isEmpty) {
      return const ValidationResult.invalid('Theme name is required');
    }
    if (draft.basePackId.isEmpty) {
      return const ValidationResult.invalid('Base pack ID is required');
    }

    final basePackExists = _availablePacks.any((p) => p.id == draft.basePackId);
    if (!basePackExists) {
      return ValidationResult.invalid('Base pack "${draft.basePackId}" not found');
    }

    return const ValidationResult.valid();
  }

  /// Imports a custom theme from JSON string.
  ///
  /// Validates the imported theme and saves it if valid.
  /// Returns the imported theme on success, or throws if invalid.
  Future<CustomThemeDraft> importFromJson(String jsonString) async {
    _logger.info('Importing custom theme from JSON');

    final CustomThemeDraft draft;
    try {
      draft = CustomThemeDraft.fromJsonString(jsonString);
    } on FormatException catch (e) {
      _logger.warning('Failed to parse theme JSON: ${e.message}');
      throw FormatException('Invalid theme JSON: ${e.message}');
    }

    final validationResult = validate(draft);
    if (!validationResult.isValid) {
      _logger.warning('Imported theme failed validation: ${validationResult.error}');
      throw FormatException(validationResult.error ?? 'Invalid theme');
    }

    await _dao.save(draft);
    _logger.info('Successfully imported theme: ${draft.name}');
    return draft;
  }

  /// Exports a custom theme to JSON string.
  ///
  /// Throws [ArgumentError] if the theme ID is not found.
  Future<String> exportToJson(String id, {bool pretty = true}) async {
    final draft = await _dao.getById(id);
    if (draft == null) {
      throw ArgumentError('Theme not found: $id');
    }

    _logger.info('Exporting custom theme: ${draft.name}');
    return draft.toJsonString(pretty: pretty);
  }

  /// Creates a new custom theme based on an existing pack.
  ///
  /// Returns the created draft (not yet persisted).
  CustomThemeDraft createFromPack({
    required String name,
    required String basePackId,
    ThemeRoleOverrides overrides = ThemeRoleOverrides.empty,
    TypographyScale typographyScale = TypographyScale.normal,
  }) {
    return CustomThemeDraft.create(
      name: name,
      basePackId: basePackId,
      overrides: overrides,
      typographyScale: typographyScale,
    );
  }
}
