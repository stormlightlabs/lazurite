import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/core/router/route_query.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/presentation/oauth_callback_screen.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/compose/presentation/compose_screen.dart';
import 'package:lazurite/features/feed/presentation/saved_posts_screen.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/list_detail_screen.dart';
import 'package:lazurite/features/lists/presentation/list_members_screen.dart';
import 'package:lazurite/features/lists/presentation/my_lists_screen.dart';
import 'package:lazurite/features/profile/cubit/profile_context_cubit.dart';
import 'package:lazurite/features/profile/data/profile_context_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_context_screen.dart';
import 'package:lazurite/features/search/cubit/hashtag_cubit.dart';
import 'package:lazurite/features/search/data/hashtag_utils.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/presentation/hashtag_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/actor_starter_packs_screen.dart';
import 'package:lazurite/features/starter_packs/presentation/create_edit_starter_pack_screen.dart';
import 'package:lazurite/features/starter_packs/presentation/starter_pack_detail_screen.dart';

/// Builds root-level routes that sit outside the tabbed app shells.
///
/// These routes are opened as overlays or global destinations from many parts
/// of the app. They still read repositories/BLoCs from the route context, but
/// the URL shapes and query parsing live here instead of in `AppRouter`.
List<RouteBase> buildRootRoutes({
  required GlobalKey<NavigatorState> rootNavigatorKey,
  required Future<AuthTokens?> Function()? onUnauthorized,
}) {
  return [
    GoRoute(
      path: AppRoutePath.oauthCallback.path,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => buildAppRoutePage(context, state, OAuthCallbackScreen(callbackUri: state.uri)),
    ),
    GoRoute(
      path: AppRoutePath.oauthCallbackCompatibility.path,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => buildAppRoutePage(context, state, OAuthCallbackScreen(callbackUri: state.uri)),
    ),
    GoRoute(path: AppRoutePath.notifications.path, redirect: (_, _) => AppRoutePath.alerts.path),
    GoRoute(path: AppRoutePath.messages.path, redirect: (_, _) => '${AppRoutePath.alerts.path}/messages'),
    GoRoute(
      path: AppRoutePath.compose.path,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final args = ComposeRouteArgs.parseExtra(state.extra);
        return buildAppRoutePage(
          context,
          state,
          BlocProvider(
            create: (_) => ComposeBloc(
              composeRepository: ComposeRepository(bluesky: context.read<Bluesky>(), onUnauthorized: onUnauthorized),
              database: context.read<AppDatabase>(),
              accountDid: context.read<String>(),
            ),
            child: ComposeScreen.fromArgs(args),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.hashtag.path,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final normalizedTag = normalizeHashtag(state.uri.queryParameters['tag'] ?? '');
        return buildAppRoutePage(
          context,
          state,
          BlocProvider(
            key: ValueKey('hashtag-$normalizedTag'),
            create: (_) => HashtagCubit(searchRepository: context.read<SearchRepository>(), tag: normalizedTag),
            child: HashtagScreen(tag: normalizedTag),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.bookmarks.path,
      pageBuilder: (context, state) => buildAppRoutePage(
        context,
        state,
        SavedPostsScreen(accountDid: context.read<String>(), initialTab: SavedPostsInitialTab.bookmarks),
      ),
    ),
    GoRoute(
      path: AppRoutePath.liked.path,
      pageBuilder: (context, state) => buildAppRoutePage(
        context,
        state,
        SavedPostsScreen(accountDid: context.read<String>(), initialTab: SavedPostsInitialTab.liked),
      ),
    ),
    GoRoute(
      path: AppRoutePath.lists.path,
      pageBuilder: (context, state) => buildAppRoutePage(context, state, const MyListsScreen()),
    ),
    GoRoute(
      path: AppRoutePath.createStarterPack.path,
      pageBuilder: (context, state) {
        return buildAppRoutePage(
          context,
          state,
          BlocProvider(
            create: (_) => StarterPackBloc(starterPackRepository: context.read<StarterPackRepository>()),
            child: CreateStarterPackScreen(userDid: context.read<String>()),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.starterPack.path,
      pageBuilder: (context, state) {
        final packUri = AtUri.parse(RouteQuery(state).decodedOrEmpty('uri'));
        return buildAppRoutePage(context, state, StarterPackDetailScreen(packUri: packUri));
      },
    ),
    GoRoute(
      path: AppRoutePath.starterPacks.path,
      pageBuilder: (context, state) {
        final actor = state.uri.queryParameters['actor'] ?? '';
        return buildAppRoutePage(context, state, ActorStarterPacksScreen(actor: actor));
      },
    ),
    GoRoute(
      path: AppRoutePath.list.path,
      pageBuilder: (context, state) {
        final listUri = AtUri.parse(RouteQuery(state).decodedOrEmpty('uri'));
        return buildAppRoutePage(context, state, ListDetailScreen(listUri: listUri));
      },
      routes: [
        GoRoute(
          path: 'members',
          pageBuilder: (context, state) {
            final listUri = AtUri.parse(RouteQuery(state).decodedOrEmpty('uri'));
            return buildAppRoutePage(
              context,
              state,
              BlocProvider(
                create: (_) =>
                    ListBloc(listRepository: context.read<ListRepository>())..add(ListRequested(listUri: listUri)),
                child: ListMembersScreen(listUri: listUri),
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutePath.profileContext.path,
      pageBuilder: (context, state) {
        final did = state.uri.queryParameters['did'] ?? '';
        final handle = state.uri.queryParameters['handle'] ?? '';
        final isOwnProfile = did == context.read<String>();
        final settingsState = context.read<SettingsCubit>().state;
        final constellationUrl = settingsState.constellationUrl;
        final appViewProvider = AppViewProviders.descriptorForSetting(settingsState.appViewProvider);
        final repository = ProfileContextRepository(
          bluesky: context.read<Bluesky>(),
          publicBluesky: Bluesky.anonymous(
            service: appViewProvider.publicBaseUrl.host,
            getClient: XrpcNetworkInterceptor.wrapGetClient(),
            postClient: XrpcNetworkInterceptor.wrapPostClient(),
          ),
          constellationClient: ConstellationClient(baseUrl: constellationUrl),
          onUnauthorized: onUnauthorized,
        );
        return buildAppRoutePage(
          context,
          state,
          BlocProvider(
            create: (_) => ProfileContextCubit(repository: repository, did: did, isOwnProfile: isOwnProfile),
            child: ProfileContextScreen(handle: handle),
          ),
        );
      },
    ),
  ];
}
