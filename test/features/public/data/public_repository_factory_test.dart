import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/public/data/public_repository_factory.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  test('creates anonymous clients and public repositories for provider context', () {
    final factory = PublicRepositoryFactory(database: MockAppDatabase());

    expect(factory.bluesky(AppViewProviders.blackskyKey).service, 'api.blacksky.community');
    expect(factory.feedRepository(AppViewProviders.blackskyKey), isA<FeedRepository>());
    expect(factory.searchRepository(AppViewProviders.blackskyKey), isA<SearchRepository>());
    expect(factory.profileRepository(AppViewProviders.blackskyKey), isA<ProfileRepository>());
    expect(factory.postThreadRepository(AppViewProviders.blackskyKey), isA<PostThreadRepository>());
    expect(factory.contentRepository(AppViewProviders.blackskyKey), isA<PublicContentRepository>());
  });
}
