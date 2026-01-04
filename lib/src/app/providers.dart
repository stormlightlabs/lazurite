import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/db/app_database.dart';

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
