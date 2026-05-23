import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/feed/presentation/feed_detail_screen.dart';
import 'package:lazurite/features/feed/presentation/post_thread_screen.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/cubit/profile_connections_cubit.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_connections_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/public/data/public_provider_context.dart';
import 'package:lazurite/features/public/data/public_repository_factory.dart';
import 'package:lazurite/features/public/presentation/public_home_screen.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/cubit/topic_cubit.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:lazurite/features/search/presentation/topic_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';

/// Builds content screens with the repositories and BLoCs required by routes.
///
/// Route group files own URL shapes and parameter decoding. This factory owns
/// the next step in the flow: turning decoded route data into feature widgets,
/// choosing authenticated vs public repositories, and applying provider fallback
/// behavior when a route can render in public read-only mode.
class ContentRouteFactory {
  const ContentRouteFactory({required this.authBloc, required this.onUnauthorized});

  final AuthBloc authBloc;
  final Future<AuthTokens?> Function()? onUnauthorized;

  /// Builds the public home tab and supplies a public-content resolver.
  Widget publicHome(BuildContext context, PublicRouteState routeState) {
    try {
      context.read<PublicContentRepositoryResolver>();
      return PublicHomeScreen(providerKey: routeState.providerKey, contentTab: routeState.contentTab);
    } catch (_) {
      log.d('PublicContentRepositoryResolver not found, creating public repository resolver for route');
    }

    try {
      final repository = context.read<PublicContentRepository>();
      return RepositoryProvider<PublicContentRepositoryResolver>.value(
        value: SinglePublicContentRepositoryResolver(repository),
        child: PublicHomeScreen(providerKey: routeState.providerKey, contentTab: routeState.contentTab),
      );
    } catch (_) {
      log.d('PublicContentRepository not found, creating public repository resolver for route');
    }

    AppDatabase database;
    try {
      database = context.read<AppDatabase>();
    } catch (error, stackTrace) {
      log.d('AppDatabase not found for public route provider setup', error: error, stackTrace: stackTrace);
      return RepositoryProvider<PublicContentRepositoryResolver>.value(
        value: const SinglePublicContentRepositoryResolver(EmptyPublicContentRepository()),
        child: PublicHomeScreen(providerKey: routeState.providerKey, contentTab: routeState.contentTab),
      );
    }

    final factory = PublicRepositoryFactory(database: database);
    return RepositoryProvider<PublicContentRepositoryResolver>(
      create: (_) => FactoryPublicContentRepositoryResolver(factory: factory),
      child: PublicHomeScreen(providerKey: routeState.providerKey, contentTab: routeState.contentTab),
    );
  }

  /// Builds a feed detail route using authenticated or public provider routing.
  Widget feedDetail(
    BuildContext context, {
    required AtUri? feedUri,
    required String? actor,
    required String? rkey,
    required String? provider,
  }) {
    if (authBloc.state.isAuthenticated) {
      final providerKey = PublicRouteState.isSupportedProvider(provider)
          ? PublicRouteState.normalizeProvider(provider)
          : null;
      if (providerKey == null) {
        return FeedDetailScreen(feedUri: feedUri, actor: actor, rkey: rkey);
      }
      return RepositoryProvider<FeedRepository>(
        key: ValueKey<String>('authenticated-feed-repository-$providerKey'),
        create: (_) => _authenticatedFeedRepository(context, providerKey),
        child: FeedDetailScreen(feedUri: feedUri, actor: actor, rkey: rkey),
      );
    }

    String? fallbackProvider;
    try {
      fallbackProvider = context.read<SettingsCubit>().state.appViewProvider;
    } catch (_) {
      log.d('SettingsCubit not found for public feed detail provider fallback');
    }

    final providerContext = PublicProviderContext.fromRoute(
      queryProvider: provider,
      fallbackProvider: fallbackProvider,
    );
    final screen = FeedDetailScreen(
      feedUri: feedUri,
      actor: actor,
      rkey: rkey,
      publicProviderKey: providerContext.providerKey,
    );

    try {
      final database = context.read<AppDatabase>();
      final factory = PublicRepositoryFactory(database: database);
      return RepositoryProvider(
        key: ValueKey<String>('public-feed-repository-${providerContext.providerKey}'),
        create: (_) => factory.feedRepository(providerContext.providerKey),
        child: screen,
      );
    } catch (error, stackTrace) {
      log.d('AppDatabase not found for public feed detail provider setup', error: error, stackTrace: stackTrace);
    }

    try {
      context.read<FeedRepository>();
      return screen;
    } catch (_) {
      log.d('FeedRepository not found for public feed detail route');
    }

    return screen;
  }

  /// Builds a post thread route using authenticated or public provider routing.
  Widget postThread(BuildContext context, {required String postUri, required String? provider}) {
    if (authBloc.state.isAuthenticated) {
      final providerKey = PublicRouteState.isSupportedProvider(provider)
          ? PublicRouteState.normalizeProvider(provider)
          : null;
      if (providerKey == null) {
        return PostThreadScreen(postUri: postUri);
      }
      return RepositoryProvider<PostThreadRepository>(
        key: ValueKey<String>('authenticated-post-thread-repository-$providerKey'),
        create: (_) => _authenticatedPostThreadRepository(context, providerKey),
        child: PostThreadScreen(postUri: postUri),
      );
    }

    final providerContext = PublicProviderContext.fromRoute(
      queryProvider: provider,
      fallbackProvider: _settingsProviderOrNull(context),
    );
    final screen = PostThreadScreen(postUri: postUri, publicProviderKey: providerContext.providerKey);

    try {
      final database = context.read<AppDatabase>();
      final factory = PublicRepositoryFactory(database: database);
      return RepositoryProvider(
        key: ValueKey<String>('public-post-thread-repository-${providerContext.providerKey}'),
        create: (_) => factory.postThreadRepository(providerContext.providerKey),
        child: screen,
      );
    } catch (error, stackTrace) {
      log.d('AppDatabase not found for public post thread provider setup', error: error, stackTrace: stackTrace);
    }

    try {
      context.read<PostThreadRepository>();
      return screen;
    } catch (_) {
      log.d('PostThreadRepository not found for public post thread route');
    }

    return screen;
  }

  /// Builds a profile route and wires the matching profile/feed dependencies.
  Widget contextualProfile(BuildContext context, String actor, {String? provider}) {
    if (!authBloc.state.isAuthenticated) {
      final providerContext = PublicProviderContext.fromRoute(
        queryProvider: provider,
        fallbackProvider: _settingsProviderOrNull(context),
      );
      final screen = ProfileScreen(actor: actor, showBackButton: true, publicProviderKey: providerContext.providerKey);

      try {
        final database = context.read<AppDatabase>();
        final factory = PublicRepositoryFactory(database: database);
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ProfileBloc(profileRepository: factory.profileRepository(providerContext.providerKey)),
            ),
            BlocProvider(create: (_) => FeedBloc(feedRepository: factory.feedRepository(providerContext.providerKey))),
          ],
          child: screen,
        );
      } catch (error, stackTrace) {
        log.d('AppDatabase not found for public profile provider setup', error: error, stackTrace: stackTrace);
      }

      try {
        context.read<ProfileRepository>();
        context.read<FeedRepository>();
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProfileBloc(profileRepository: context.read<ProfileRepository>())),
            BlocProvider(create: (_) => FeedBloc(feedRepository: context.read<FeedRepository>())),
          ],
          child: screen,
        );
      } catch (_) {
        log.d('ProfileRepository or FeedRepository not found for public profile route');
      }
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileBloc(profileRepository: context.read<ProfileRepository>())),
        BlocProvider(create: (_) => FeedBloc(feedRepository: context.read<FeedRepository>())),
      ],
      child: ProfileScreen(actor: actor, showBackButton: true),
    );
  }

  /// Builds a topic route using authenticated search or public provider search.
  Widget topic(BuildContext context, {required String topic, required String? provider}) {
    final providerContext = PublicProviderContext.fromRoute(
      queryProvider: provider,
      fallbackProvider: _settingsProviderOrNull(context),
    );

    Widget screenWithRepository(SearchRepository repository, {String? publicProviderKey}) => BlocProvider(
      key: ValueKey('topic-$topic-${publicProviderKey ?? 'authenticated'}'),
      create: (_) => TopicCubit(searchRepository: repository, topic: topic),
      child: TopicScreen(topic: topic, publicProviderKey: publicProviderKey),
    );

    if (authBloc.state.isAuthenticated) {
      if (PublicRouteState.isSupportedProvider(provider)) {
        return screenWithRepository(_authenticatedSearchRepository(context, providerContext.providerKey));
      }
      return screenWithRepository(context.read<SearchRepository>());
    }

    try {
      return screenWithRepository(context.read<SearchRepository>(), publicProviderKey: providerContext.providerKey);
    } catch (_) {
      log.d('SearchRepository not found for public topic route');
    }

    final database = context.read<AppDatabase>();
    final factory = PublicRepositoryFactory(database: database);
    return screenWithRepository(
      factory.searchRepository(providerContext.providerKey),
      publicProviderKey: providerContext.providerKey,
    );
  }

  /// Builds authenticated-only profile-scoped post search.
  Widget profileSearch(BuildContext context, String actor) {
    return BlocProvider(
      create: (_) => SearchBloc(
        searchRepository: context.read<SearchRepository>(),
        typeaheadRepository: context.read<TypeaheadRepository>(),
        database: context.read<AppDatabase>(),
        accountDid: context.read<String>(),
        config: SearchBlocConfig.profileScoped(fixedPostAuthor: actor),
      ),
      child: SearchScreen(
        postsOnlyMode: true,
        fixedPostAuthor: actor,
        showBackButton: true,
        title: 'Search @${actor.startsWith('did:') ? actor : actor}',
        showJumpToProfileAction: false,
      ),
    );
  }

  /// Builds authenticated-only profile relationship routes.
  Widget profileConnections(BuildContext context, GoRouterState state, String actor) {
    final normalizedActor = actor.trim();
    final initialTab = ProfileConnectionsTabX.fromRouteValue(state.uri.queryParameters['tab']);
    final constellationUrl = context.read<SettingsCubit>().state.constellationUrl;
    final handle = normalizedActor.startsWith('did:') || normalizedActor == context.read<String>()
        ? null
        : normalizedActor;
    return BlocProvider(
      create: (_) => ProfileConnectionsCubit(
        repository: context.read<ProfileRepository>(),
        actor: normalizedActor,
        constellationClient: ConstellationClient(baseUrl: constellationUrl),
      ),
      child: ProfileConnectionsScreen(actor: normalizedActor, handle: handle, initialTab: initialTab),
    );
  }

  String? _settingsProviderOrNull(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.appViewProvider;
    } catch (_) {
      log.d('SettingsCubit not found for public provider fallback');
      return null;
    }
  }

  FeedRepository _authenticatedFeedRepository(BuildContext context, String providerKey) {
    final settingsCubit = context.read<SettingsCubit>();
    return FeedRepository(
      bluesky: context.read<Bluesky>(),
      database: context.read<AppDatabase>(),
      accountDid: context.read<String>(),
      moderationService: _moderationServiceOrNull(context),
      appViewProvider: providerKey,
      crossProviderFallbackEnabledResolver: () => settingsCubit.state.crossProviderFallbackEnabled,
      routingEpoch: settingsCubit.state.routingEpoch,
      routingEpochResolver: () => settingsCubit.state.routingEpoch,
      onUnauthorized: onUnauthorized,
    );
  }

  SearchRepository _authenticatedSearchRepository(BuildContext context, String providerKey) {
    final settingsCubit = context.read<SettingsCubit>();
    return SearchRepository(
      bluesky: context.read<Bluesky>(),
      moderationService: _moderationServiceOrNull(context),
      appViewProvider: providerKey,
      crossProviderFallbackEnabledResolver: () => settingsCubit.state.crossProviderFallbackEnabled,
      routingEpoch: settingsCubit.state.routingEpoch,
      routingEpochResolver: () => settingsCubit.state.routingEpoch,
      onUnauthorized: onUnauthorized,
    );
  }

  PostThreadRepository _authenticatedPostThreadRepository(BuildContext context, String providerKey) =>
      PostThreadRepository(
        bluesky: context.read<Bluesky>(),
        database: context.read<AppDatabase>(),
        accountDid: context.read<String>(),
        moderationService: _moderationServiceOrNull(context),
        appViewProvider: providerKey,
        onUnauthorized: onUnauthorized,
      );

  ModerationService? _moderationServiceOrNull(BuildContext context) {
    try {
      return context.read<ModerationService>();
    } catch (error, stackTrace) {
      log.d('ModerationService not found for provider-scoped route', error: error, stackTrace: stackTrace);
      return null;
    }
  }
}
