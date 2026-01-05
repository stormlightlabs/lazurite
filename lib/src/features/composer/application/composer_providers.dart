import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart' as composer;
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer_providers.g.dart';

@riverpod
DraftRepository draftRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(xrpcClientProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  final logger = ref.watch(loggerProvider('DraftRepository'));

  return DraftRepository(
    dao: db.draftsDao,
    api: api,
    sessionStorage: sessionStorage,
    logger: logger,
  );
}

@riverpod
Stream<List<composer.Draft>> drafts(Ref ref) {
  return ref.watch(draftRepositoryProvider).watchDrafts();
}

@riverpod
Stream<composer.Draft?> draft(Ref ref, String id) {
  return ref.watch(draftRepositoryProvider).watchDraft(id);
}
