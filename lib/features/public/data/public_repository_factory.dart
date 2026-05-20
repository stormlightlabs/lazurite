import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/search/data/search_repository.dart';

class PublicRepositoryFactory {
  const PublicRepositoryFactory({required this.database});

  final AppDatabase database;

  Bluesky bluesky(String providerKey) {
    final provider = AppViewProviders.descriptorForSetting(providerKey);
    return Bluesky.anonymous(
      service: provider.publicBaseUrl.host,
      getClient: XrpcNetworkInterceptor.wrapGetClient(),
      postClient: XrpcNetworkInterceptor.wrapPostClient(),
    );
  }

  FeedRepository feedRepository(String providerKey) {
    final client = bluesky(providerKey);
    return FeedRepository(
      bluesky: client,
      database: database,
      accountDid: _publicAccountDid(providerKey),
      moderationService: _publicModerationService(client, providerKey),
      appViewProvider: providerKey,
    );
  }

  SearchRepository searchRepository(String providerKey) {
    return SearchRepository(bluesky: bluesky(providerKey), appViewProvider: providerKey);
  }

  ProfileRepository profileRepository(String providerKey) {
    final client = bluesky(providerKey);
    return ProfileRepository(
      database: database,
      bluesky: client,
      moderationService: _publicModerationService(client, providerKey),
      appViewProvider: providerKey,
    );
  }

  PostThreadRepository postThreadRepository(String providerKey) {
    final client = bluesky(providerKey);
    return PostThreadRepository(
      bluesky: client,
      database: database,
      accountDid: _publicAccountDid(providerKey),
      moderationService: _publicModerationService(client, providerKey),
      appViewProvider: providerKey,
    );
  }

  PublicContentRepository contentRepository(String providerKey) {
    return RepositoryPublicContentRepository(
      providerKey: providerKey,
      feedRepository: feedRepository(providerKey),
      searchRepository: searchRepository(providerKey),
    );
  }

  String _publicAccountDid(String providerKey) => 'public:${AppViewProviders.normalizeSettingKey(providerKey)}';

  ModerationService _publicModerationService(Bluesky client, String providerKey) {
    return ModerationService.public(bluesky: client, database: database, appViewProvider: providerKey);
  }
}
