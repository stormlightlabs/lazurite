import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/utils/logger_provider.dart';
import '../infrastructure/db/app_database.dart';
import '../infrastructure/preferences/local_preferences_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

/// Provides the app's [GoRouter] instance.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return createRouter(ref);
}

/// Provides the local preferences repository for managing on-device settings.
///
/// This repository handles local app preferences that don't sync with Bluesky,
/// such as theme mode, font scale, and other UI preferences.
@Riverpod(keepAlive: true)
LocalPreferencesRepository localPreferencesRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('LocalPreferencesRepository'));
  return LocalPreferencesRepository(db.localSettingsDao, logger);
}
