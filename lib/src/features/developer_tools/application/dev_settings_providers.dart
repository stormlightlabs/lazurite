import 'package:lazurite/src/app/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dev_settings_providers.g.dart';

/// Provides access to developer tools settings.
///
/// Manages whether developer tools are enabled in production builds.
/// In kDebugMode, developer tools are always accessible regardless of this setting.
@riverpod
class DevToolsEnabled extends _$DevToolsEnabled {
  static const String _key = 'dev_tools_enabled';

  @override
  Future<bool> build() async {
    final db = ref.watch(appDatabaseProvider);
    final value = await db.devToolsDao.getSetting(_key);
    return value == 'true';
  }

  /// Enables developer tools in production builds.
  Future<void> enable() async {
    final db = ref.read(appDatabaseProvider);
    await db.devToolsDao.setSetting(_key, 'true', 'boolean');
    ref.invalidateSelf();
  }

  /// Disables developer tools in production builds.
  Future<void> disable() async {
    final db = ref.read(appDatabaseProvider);
    await db.devToolsDao.setSetting(_key, 'false', 'boolean');
    ref.invalidateSelf();
  }

  /// Toggles developer tools setting.
  Future<void> toggle() async {
    final current = await future;
    if (current) {
      await disable();
    } else {
      await enable();
    }
  }
}

/// Provides access to the 'allow other repos' developer setting.
@riverpod
class AllowOtherRepos extends _$AllowOtherRepos {
  static const String _key = 'dev_tools_allow_other_repos';

  @override
  Future<bool> build() async {
    final db = ref.watch(appDatabaseProvider);
    final value = await db.devToolsDao.getSetting(_key);
    return value == 'true';
  }

  Future<void> toggle() async {
    final current = await future;
    final db = ref.read(appDatabaseProvider);
    await db.devToolsDao.setSetting(_key, (!current).toString(), 'boolean');
    ref.invalidateSelf();
  }
}

/// Provides access to the 'enable record editing' developer setting.
@riverpod
class EnableRecordEditing extends _$EnableRecordEditing {
  static const String _key = 'dev_tools_enable_record_editing';

  @override
  Future<bool> build() async {
    final db = ref.watch(appDatabaseProvider);
    final value = await db.devToolsDao.getSetting(_key);
    return value == 'true';
  }

  Future<void> toggle() async {
    final current = await future;
    final db = ref.read(appDatabaseProvider);
    await db.devToolsDao.setSetting(_key, (!current).toString(), 'boolean');
    ref.invalidateSelf();
  }
}
