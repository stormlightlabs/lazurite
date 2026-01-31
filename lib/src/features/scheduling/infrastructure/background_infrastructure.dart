import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/post_publisher.dart';
import 'package:lazurite/src/infrastructure/auth/auth_repository.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_nonce_store.dart';
import 'package:lazurite/src/infrastructure/auth/oauth_client.dart';
import 'package:lazurite/src/infrastructure/auth/server_metadata.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/identity/identity_repository.dart';
import 'package:lazurite/src/infrastructure/network/dio_clients.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Helper class to initialize minimal app infrastructure in a background isolate.
///
/// Since Riverpod providers are not available in background isolates, this class
/// manually wires the necessary dependencies for background post publishing.
class BackgroundInfrastructure {
  BackgroundInfrastructure._({required this.database, required this.postPublisher});

  final AppDatabase database;
  final PostPublisher postPublisher;

  static Future<BackgroundInfrastructure> initialize() async {
    const logger = Logger('BackgroundInfrastructure');
    logger.info('Initializing background infrastructure');

    final db = AppDatabase();
    const secureStorage = FlutterSecureStorage();
    final sessionStorage = SessionStorage(storage: secureStorage);
    final nonceStore = DPoPNonceStore();

    final authSupportDio = createPublicDio();
    final identityRepo = IdentityRepository(
      dio: authSupportDio,
      logger: const Logger('IdentityRepository'),
    );
    final oauthClient = OAuthClient(
      dio: Dio(),
      logger: const Logger('OAuthClient'),
      nonceStore: nonceStore,
    );
    final metadataRepo = ServerMetadataRepository(dio: authSupportDio);

    final authRepo = AuthRepository(
      identityRepository: identityRepo,
      oauthClient: oauthClient,
      sessionStorage: sessionStorage,
      metadataRepository: metadataRepo,
      secureStorage: secureStorage,
      nonceStore: nonceStore,
      logger: const Logger('AuthRepository'),
    );

    final publicDio = createPublicDio(
      getSession: sessionStorage.getSession,
      refreshSession: () async {
        final session = await sessionStorage.getSession();
        if (session == null) return null;
        final refreshed = await authRepo.refreshSession(session);
        await sessionStorage.saveSession(refreshed);
        return refreshed;
      },
      nonceStore: nonceStore,
    );

    final videoDio = createVideoServiceDio();
    final tenorDio = createTenorDio();

    Dio? pdsDio;
    final session = await sessionStorage.getSession();
    if (session != null) {
      pdsDio = createPdsDio(
        pdsUrl: session.pdsUrl,
        getSession: sessionStorage.getSession,
        refreshSession: () async {
          final s = await sessionStorage.getSession();
          if (s == null) return null;
          final refreshed = await authRepo.refreshSession(s);
          await sessionStorage.saveSession(refreshed);
          return refreshed;
        },
        nonceStore: nonceStore,
      );
    }

    final xrpcClient = XrpcClient(
      publicDio: publicDio,
      pdsDio: pdsDio,
      videoServiceDio: videoDio,
      tenorDio: tenorDio,
      logger: const Logger('XrpcClient'),
    );

    final facetParser = FacetParser(api: xrpcClient, logger: const Logger('FacetParser'));

    final draftRepo = DraftRepository(
      dao: db.draftsDao,
      api: xrpcClient,
      sessionStorage: sessionStorage,
      logger: const Logger('DraftRepository'),
      facetParser: facetParser,
    );

    final postPublisher = PostPublisher(
      draftsDao: db.draftsDao,
      schedulesDao: db.schedulesDao,
      sessionStorage: sessionStorage,
      authRepository: authRepo,
      draftRepository: draftRepo,
      logger: const Logger('PostPublisher'),
    );

    return BackgroundInfrastructure._(database: db, postPublisher: postPublisher);
  }
}
