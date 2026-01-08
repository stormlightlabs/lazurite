import 'package:dio/dio.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart' as composer;
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/composer/infrastructure/link_metadata_service.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer_providers.g.dart';

@riverpod
FacetParser facetParser(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final logger = ref.watch(loggerProvider('FacetParser'));
  return FacetParser(api: api, logger: logger);
}

@riverpod
LinkMetadataService linkMetadataService(Ref ref) {
  final logger = ref.watch(loggerProvider('LinkMetadataService'));
  return LinkMetadataService(dio: Dio(), logger: logger);
}

@riverpod
DraftRepository draftRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(xrpcClientProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  final logger = ref.watch(loggerProvider('DraftRepository'));
  final facetParser = ref.watch(facetParserProvider);

  return DraftRepository(
    dao: db.draftsDao,
    api: api,
    sessionStorage: sessionStorage,
    logger: logger,
    facetParser: facetParser,
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
