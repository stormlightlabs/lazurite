import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jose/jose.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/image_compressor.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';
import 'package:lazurite/src/features/dms/infrastructure/dms_repository.dart';
import 'package:lazurite/src/features/dms/infrastructure/outbox_repository.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/features/notifications/infrastructure/notifications_repository.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:lazurite/src/infrastructure/auth/auth_repository.dart';
import 'package:lazurite/src/infrastructure/auth/handle_storage.dart';
import 'package:lazurite/src/infrastructure/auth/oauth_client.dart';
import 'package:lazurite/src/infrastructure/auth/server_metadata.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/notifications_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/dev_tools_dao.dart';
import 'package:lazurite/src/infrastructure/identity/identity_repository.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:lazurite/src/infrastructure/preferences/bluesky_preferences_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLogger extends Mock implements Logger {}

class MockImageCompressor extends Mock implements ImageCompressor {}

class MockFacetParser extends Mock implements FacetParser {}

class MockXrpcClient extends Mock implements XrpcClient {}

class MockDio extends Mock implements Dio {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionStorage extends Mock implements SessionStorage {}

class MockHandleStorage extends Mock implements HandleStorage {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockOAuthClient extends Mock implements OAuthClient {}

class MockIdentityRepository extends Mock implements IdentityRepository {}

class MockServerMetadataRepository extends Mock implements ServerMetadataRepository {}

class MockAuthStateAuthenticated extends Mock implements AuthStateAuthenticated {}

class MockSession extends Mock implements Session {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockFeedContentRepository extends Mock implements FeedContentRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockThreadRepository extends Mock implements ThreadRepository {}

class MockBlueskyPreferencesRepository extends Mock implements BlueskyPreferencesRepository {}

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

class MockNotificationsDao extends Mock implements NotificationsDao {}

class MockDmsRepository extends Mock implements DmsRepository {}

class MockOutboxRepository extends Mock implements OutboxRepository {}

class MockDevToolsDao extends Mock implements DevToolsDao {}

class MockPinnedFeedsNotifier extends Mock implements PinnedFeedsNotifier {
  @override
  String toString({DiagnosticLevel? minLevel}) => 'MockPinnedFeedsNotifier';

  @override
  Stream<List<SavedFeedData>> build() => Stream.value([]);
}

class MockActiveFeed extends Mock implements ActiveFeed {
  @override
  String toString({DiagnosticLevel? minLevel}) => 'MockActiveFeed';
}

/// Fake JsonWebKey for testing
class FakeJsonWebKey extends Fake implements JsonWebKey {
  @override
  String toString() => 'FakeJsonWebKey';
}

/// Fake Session for testing
class FakeSession extends Fake implements Session {}

/// Fake ServerMetadata for testing
class FakeServerMetadata extends Fake implements ServerMetadata {}
