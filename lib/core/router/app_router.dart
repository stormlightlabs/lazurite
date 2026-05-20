import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart' as atp;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/alerts/presentation/alerts_screen.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/auth/presentation/oauth_callback_screen.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/compose/presentation/compose_screen.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';
import 'package:lazurite/features/devtools/presentation/dev_tools_screen.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/feed/presentation/feed_detail_screen.dart';
import 'package:lazurite/features/feed/presentation/feed_management_screen.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_screen.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_screen.dart';
import 'package:lazurite/features/feed/presentation/post_thread_screen.dart';
import 'package:lazurite/features/feed/presentation/saved_posts_screen.dart';
import 'package:lazurite/features/feed/presentation/trending_screen.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/list_detail_screen.dart';
import 'package:lazurite/features/lists/presentation/list_members_screen.dart';
import 'package:lazurite/features/lists/presentation/my_lists_screen.dart';
import 'package:lazurite/features/logs/presentation/logs_screen.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/features/messages/presentation/message_thread_screen.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/screens/labeler_detail_screen.dart';
import 'package:lazurite/features/moderation/presentation/screens/moderation_settings_screen.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/cubit/profile_connections_cubit.dart';
import 'package:lazurite/features/profile/cubit/profile_context_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';
import 'package:lazurite/features/profile/data/profile_context_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/follow_audit_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_connections_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_context_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_edit_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/public/data/public_provider_context.dart';
import 'package:lazurite/features/public/data/public_repository_factory.dart';
import 'package:lazurite/features/public/presentation/public_home_screen.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';
import 'package:lazurite/features/public/presentation/unauthenticated_shell.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/cubit/hashtag_cubit.dart';
import 'package:lazurite/features/search/cubit/topic_cubit.dart';
import 'package:lazurite/features/search/data/hashtag_utils.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/presentation/hashtag_screen.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:lazurite/features/search/presentation/topic_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/cubit/video_upload_limits_cubit.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';
import 'package:lazurite/features/settings/presentation/about_screen.dart';
import 'package:lazurite/features/settings/presentation/privacy_policy_screen.dart';
import 'package:lazurite/features/settings/presentation/settings_account_screen.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';
import 'package:lazurite/features/settings/presentation/terms_of_service_screen.dart';
import 'package:lazurite/features/settings/presentation/video_upload_limits_screen.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/actor_starter_packs_screen.dart';
import 'package:lazurite/features/starter_packs/presentation/create_edit_starter_pack_screen.dart';
import 'package:lazurite/features/starter_packs/presentation/starter_pack_detail_screen.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';

class AppRouter {
  AppRouter({required this.authBloc, this.navigatorObserver, this.onUnauthorized});
  final AuthBloc authBloc;
  final NavigatorObserver? navigatorObserver;
  final Future<AuthTokens?> Function()? onUnauthorized;
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final GlobalKey<NavigatorState> _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
  final GlobalKey<NavigatorState> _atExplorerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'at-explorer');
  final GlobalKey<NavigatorState> _notificationsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'notifications');
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
  List<GlobalKey<NavigatorState>> get _branchNavigatorKeys => [
    _homeNavigatorKey,
    _searchNavigatorKey,
    _atExplorerNavigatorKey,
    _notificationsNavigatorKey,
    _profileNavigatorKey,
  ];

  // Page<dynamic> _page(BuildContext context, GoRouterState state, Widget child) =>
  //     buildAppRoutePage(context: context, state: state, child: child);

  GoRouter get router => GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    observers: navigatorObserver != null ? [navigatorObserver!] : null,
    redirect: (context, state) {
      final isAuthenticated = authBloc.state.isAuthenticated;
      final path = state.uri.path;
      final publicPaths = {
        '/login',
        '/settings',
        '/settings/about',
        '/settings/logs',
        '/settings/devtools',
        '/terms',
        '/privacy',
        '/feed',
        '/post',
        '/topic',
        OAuthCallbackScreen.routePath,
        OAuthCallbackScreen.compatibilityRoutePath,
      };
      final isLoggingIn = path == '/login';
      final isReauthLogin = state.uri.queryParameters['reauth'] == '1';
      final isPublicBrowsingPath = path == '/public' || path.startsWith('/public/');
      final isPublicProfilePath = path.startsWith('/profile/') && path != '/profile/me';
      final isPublicPath = publicPaths.contains(path) || isPublicBrowsingPath || isPublicProfilePath;

      if (!isAuthenticated && path == '/') {
        return const PublicRouteState(
          providerKey: AppViewProviders.blueskyKey,
          contentTab: PublicContentTab.discover,
        ).location;
      }

      if (!isAuthenticated && !isPublicPath) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn && !isReauthLogin) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          final initialHandle = state.uri.queryParameters['handle']?.trim();
          final hasInitialHandle = initialHandle != null && initialHandle.isNotEmpty;
          final autoStartOAuth = state.uri.queryParameters['reauth'] == '1' && hasInitialHandle;
          return buildAppRoutePage(
            context,
            state,
            _buildUnauthenticatedRouteShell(
              context,
              state,
              LoginScreen(
                initialHandle: hasInitialHandle ? initialHandle : null,
                initialProviderKey: state.uri.queryParameters['provider'],
                autoStartOAuth: autoStartOAuth,
              ),
            ),
          );
        },
      ),
      GoRoute(path: '/public', redirect: (_, _) => '/public/bluesky/discover'),
      GoRoute(
        path: '/public/:provider/:tab',
        redirect: (_, state) {
          final routeState = PublicRouteState.parse(
            provider: state.pathParameters['provider'],
            tab: state.pathParameters['tab'],
          );
          if (state.uri.path != routeState.location) {
            return routeState.location;
          }
          return null;
        },
        pageBuilder: (context, state) {
          final routeState = PublicRouteState.parse(
            provider: state.pathParameters['provider'],
            tab: state.pathParameters['tab'],
          );
          return MaterialPage<dynamic>(
            key: const ValueKey<String>('public-home-route'),
            child: _buildUnauthenticatedRouteShell(
              context,
              state,
              _buildPublicHomeRoute(context, routeState),
              publicProviderKey: routeState.providerKey,
              publicHomeLocation: routeState.location,
            ),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            buildAppRoutePage(context, state, _buildUnauthenticatedRouteShell(context, state, const SettingsScreen())),
        routes: [
          GoRoute(
            path: 'moderation',
            pageBuilder: (context, state) => buildAppRoutePage(context, state, const ModerationSettingsScreen()),
            routes: [
              GoRoute(
                path: 'detail',
                pageBuilder: (context, state) =>
                    buildAppRoutePage(context, state, LabelerDetailScreen(did: state.uri.queryParameters['did'] ?? '')),
              ),
            ],
          ),
          GoRoute(
            path: 'account',
            pageBuilder: (context, state) => buildAppRoutePage(context, state, const SettingsAccountScreen()),
          ),
          GoRoute(
            path: 'about',
            pageBuilder: (context, state) => buildAppRoutePage(context, state, const AboutScreen()),
          ),
          GoRoute(path: 'logs', pageBuilder: (context, state) => buildAppRoutePage(context, state, const LogsScreen())),
          GoRoute(
            path: 'clean-follows',
            pageBuilder: (context, state) => buildAppRoutePage(
              context,
              state,
              BlocProvider(
                create: (_) => FollowAuditCubit(
                  repository: FollowAuditRepository(
                    bluesky: context.read<Bluesky>(),
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                  ownDid: context.read<String>(),
                ),
                child: const FollowAuditScreen(),
              ),
            ),
          ),
          GoRoute(
            path: 'devtools',
            pageBuilder: (context, state) => buildAppRoutePage(
              context,
              state,
              _buildUnauthenticatedRouteShell(context, state, _buildDevToolsRoute(context, state)),
            ),
          ),
          GoRoute(
            path: 'video-limits',
            pageBuilder: (context, state) => buildAppRoutePage(
              context,
              state,
              BlocProvider(
                create: (_) => VideoUploadLimitsCubit(repository: context.read<VideoRepository>()),
                child: const VideoUploadLimitsScreen(),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: OAuthCallbackScreen.routePath,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildAppRoutePage(context, state, OAuthCallbackScreen(callbackUri: state.uri)),
      ),
      GoRoute(
        path: OAuthCallbackScreen.compatibilityRoutePath,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildAppRoutePage(context, state, OAuthCallbackScreen(callbackUri: state.uri)),
      ),
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) => buildAppRoutePage(context, state, const TermsOfServiceScreen()),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (context, state) => buildAppRoutePage(context, state, const PrivacyPolicyScreen()),
      ),
      GoRoute(path: '/notifications', redirect: (_, _) => '/alerts'),
      GoRoute(path: '/messages', redirect: (_, _) => '/alerts/messages'),
      GoRoute(
        path: '/compose',
        parentNavigatorKey: _rootNavigatorKey,
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
              child: ComposeScreen(
                replyParentUri: args.replyParentUri,
                replyParentCid: args.replyParentCid,
                replyRootUri: args.replyRootUri,
                replyRootCid: args.replyRootCid,
                replyAuthorHandle: args.replyAuthorHandle,
                quoteUri: args.quoteUri,
                quoteCid: args.quoteCid,
                quoteAuthorHandle: args.quoteAuthorHandle,
                quoteText: args.quoteText,
                draftId: args.draftId,
                initialText: args.initialText,
                editPostUri: args.editPostUri,
                editPostCid: args.editPostCid,
                editRecord: args.editRecord,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/post',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final uri = state.uri.queryParameters['uri'] ?? '';
          final provider = state.uri.queryParameters['provider'];
          return buildAppRoutePage(
            context,
            state,
            _buildPostThreadRoute(context, postUri: Uri.decodeComponent(uri), provider: provider),
          );
        },
      ),
      GoRoute(
        path: '/hashtag',
        parentNavigatorKey: _rootNavigatorKey,
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
        path: '/topic',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final rawTopic = state.uri.queryParameters['topic'] ?? '';
          final topic = Uri.decodeComponent(rawTopic).trim();
          return buildAppRoutePage(
            context,
            state,
            _buildTopicRoute(context, topic: topic, provider: state.uri.queryParameters['provider']),
          );
        },
      ),
      GoRoute(
        path: '/images',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as ImageViewerRouteArgs;
          return buildAppRoutePage(context, state, ImageViewerScreen(args: args));
        },
      ),
      GoRoute(
        path: '/video',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as VideoPlayerRouteArgs;
          return buildAppRoutePage(context, state, VideoPlayerScreen(args: args));
        },
      ),
      GoRoute(
        path: '/bookmarks',
        pageBuilder: (context, state) => buildAppRoutePage(
          context,
          state,
          SavedPostsScreen(accountDid: context.read<String>(), initialTab: SavedPostsInitialTab.bookmarks),
        ),
      ),
      GoRoute(
        path: '/liked',
        pageBuilder: (context, state) => buildAppRoutePage(
          context,
          state,
          SavedPostsScreen(accountDid: context.read<String>(), initialTab: SavedPostsInitialTab.liked),
        ),
      ),
      GoRoute(
        path: '/lists',
        pageBuilder: (context, state) => buildAppRoutePage(context, state, const MyListsScreen()),
      ),
      GoRoute(
        path: '/create-starter-pack',
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
        path: '/starter-pack',
        pageBuilder: (context, state) {
          final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
          final packUri = AtUri.parse(uriStr);
          return buildAppRoutePage(context, state, StarterPackDetailScreen(packUri: packUri));
        },
      ),
      GoRoute(
        path: '/starter-packs',
        pageBuilder: (context, state) {
          final actor = state.uri.queryParameters['actor'] ?? '';
          return buildAppRoutePage(context, state, ActorStarterPacksScreen(actor: actor));
        },
      ),
      GoRoute(
        path: '/list',
        pageBuilder: (context, state) {
          final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
          final listUri = AtUri.parse(uriStr);
          return buildAppRoutePage(context, state, ListDetailScreen(listUri: listUri));
        },
        routes: [
          GoRoute(
            path: 'members',
            pageBuilder: (context, state) {
              final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
              final listUri = AtUri.parse(uriStr);
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
        path: '/profile-context',
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
      GoRoute(
        path: r'/profile/:actor(m|[^m][^/]*|m[^e][^/]*|me[^/]+)',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (_, state) {
          final actor = (state.pathParameters['actor'] ?? '').trim().toLowerCase();
          if (actor == 'me') {
            return '/profile/me';
          }
          return null;
        },
        pageBuilder: (context, state) => buildAppRoutePage(
          context,
          state,
          _buildContextualProfileRoute(
            context,
            Uri.decodeComponent(state.pathParameters['actor'] ?? ''),
            provider: state.uri.queryParameters['provider'],
          ),
        ),
        routes: [
          GoRoute(
            path: 'connections',
            redirect: (_, state) => authBloc.state.isAuthenticated ? null : _publicProfileLocation(state),
            pageBuilder: (context, state) => buildAppRoutePage(
              context,
              state,
              _buildProfileConnectionsRoute(context, state, Uri.decodeComponent(state.pathParameters['actor'] ?? '')),
            ),
          ),
          GoRoute(
            path: 'search-posts',
            redirect: (_, state) => authBloc.state.isAuthenticated ? null : _publicProfileLocation(state),
            pageBuilder: (context, state) {
              final actor = Uri.decodeComponent(state.pathParameters['actor'] ?? '');
              return buildAppRoutePage(
                context,
                state,
                BlocProvider(
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
                ),
              );
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          if (!context.read<AuthBloc>().state.isAuthenticated) {
            return AppShell(navigationShell: navigationShell, branchNavigatorKeys: _branchNavigatorKeys);
          }

          UnreadCountCubit? existingUnreadCubit;
          try {
            existingUnreadCubit = context.read<UnreadCountCubit>();
          } catch (_) {
            log.d('UnreadCountCubit not found, creating new one');
          }

          if (existingUnreadCubit != null) {
            return AppShell(navigationShell: navigationShell, branchNavigatorKeys: _branchNavigatorKeys);
          }

          return MultiBlocProvider(
            providers: [
              if (existingUnreadCubit == null)
                BlocProvider(
                  create: (_) => UnreadCountCubit(
                    notificationDomainService: _readNotificationDomainService(context),
                    notificationRepository: context.read<NotificationRepository>(),
                  ),
                ),
            ],
            child: AppShell(navigationShell: navigationShell, branchNavigatorKeys: _branchNavigatorKeys),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => buildAppRoutePage(context, state, const HomeFeedScreen()),
                routes: [
                  GoRoute(
                    path: 'feeds',
                    pageBuilder: (context, state) => buildAppRoutePage(context, state, const FeedManagementScreen()),
                  ),
                  GoRoute(
                    path: 'feed',
                    pageBuilder: (context, state) {
                      final encodedUri = state.uri.queryParameters['uri'];
                      final encodedActor = state.uri.queryParameters['actor'];
                      final encodedRkey = state.uri.queryParameters['rkey'];
                      final encodedProvider = state.uri.queryParameters['provider'];

                      AtUri? feedUri;
                      if (encodedUri != null && encodedUri.trim().isNotEmpty) {
                        final rawUri = Uri.decodeComponent(encodedUri);
                        feedUri = AtUri.parse(rawUri);
                      }

                      final actor = encodedActor == null ? null : Uri.decodeComponent(encodedActor);
                      final rkey = encodedRkey == null ? null : Uri.decodeComponent(encodedRkey);
                      final provider = encodedProvider == null ? null : Uri.decodeComponent(encodedProvider);
                      return buildAppRoutePage(
                        context,
                        state,
                        _buildFeedDetailRoute(context, feedUri: feedUri, actor: actor, rkey: rkey, provider: provider),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'trending',
                    pageBuilder: (context, state) => buildAppRoutePage(context, state, const TrendingScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) => buildAppRoutePage(context, state, const SearchScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _atExplorerNavigatorKey,
            routes: [
              GoRoute(
                path: '/at-explorer',
                pageBuilder: (context, state) => buildAppRoutePage(context, state, _buildDevToolsRoute(context, state)),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _notificationsNavigatorKey,
            routes: [
              GoRoute(
                path: '/alerts',
                pageBuilder: (context, state) =>
                    buildAppRoutePage(context, state, _buildAlertsRoute(context, const AlertsScreen())),
                routes: [
                  GoRoute(
                    path: 'messages',
                    pageBuilder: (context, state) => buildAppRoutePage(
                      context,
                      state,
                      _buildAlertsRoute(context, const AlertsScreen(initialTab: AlertsTab.messages)),
                    ),
                    routes: [
                      GoRoute(
                        path: ':id',
                        pageBuilder: (context, state) {
                          final convoId = state.pathParameters['id']!;
                          final args = state.extra as MessageThreadRouteArgs?;
                          return buildAppRoutePage(
                            context,
                            state,
                            BlocProvider(
                              create: (_) => MessageBloc(
                                convoRepository: context.read<ConvoRepository>(),
                                currentUserDid: context.read<String>(),
                              ),
                              child: MessageThreadScreen(convoId: convoId, title: args?.title ?? 'Conversation'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'requests',
                    pageBuilder: (context, state) => buildAppRoutePage(
                      context,
                      state,
                      _buildAlertsRoute(context, const AlertsScreen(initialTab: AlertsTab.requests)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile/me',
                pageBuilder: (context, state) => buildAppRoutePage(context, state, const ProfileScreen(actor: 'me')),
                routes: [
                  GoRoute(
                    path: 'connections',
                    pageBuilder: (context, state) => buildAppRoutePage(
                      context,
                      state,
                      _buildProfileConnectionsRoute(context, state, context.read<String>()),
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => buildAppRoutePage(context, state, const ProfileEditScreen()),
                  ),
                  GoRoute(
                    path: 'search-posts',
                    pageBuilder: (context, state) {
                      final actor = context.read<String>();
                      return buildAppRoutePage(
                        context,
                        state,
                        BlocProvider(
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
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  Widget _buildUnauthenticatedRouteShell(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    String? publicProviderKey,
    String? publicHomeLocation,
  }) {
    if (authBloc.state.isAuthenticated) {
      return child;
    }

    return UnauthenticatedShell(
      location: state.uri.path,
      publicProviderKey: publicProviderKey,
      publicHomeLocation: publicHomeLocation ?? _publicHomeLocationFromQuery(state),
      child: child,
    );
  }

  Widget _buildPublicHomeRoute(BuildContext context, PublicRouteState routeState) {
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

  Widget _buildFeedDetailRoute(
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

  Widget _buildAlertsRoute(BuildContext context, Widget child) {
    NotificationBloc? existingNotificationBloc;
    try {
      existingNotificationBloc = context.read<NotificationBloc>();
    } catch (_) {
      log.d('NotificationBloc not found, creating new one for alerts route');
    }

    if (existingNotificationBloc != null) {
      return child;
    }

    return BlocProvider(
      create: (_) => NotificationBloc(
        notificationDomainService: _readNotificationDomainService(context),
        notificationRepository: context.read<NotificationRepository>(),
      ),
      child: child,
    );
  }

  Widget _buildPostThreadRoute(BuildContext context, {required String postUri, required String? provider}) {
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

  Widget _buildContextualProfileRoute(BuildContext context, String actor, {String? provider}) {
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

  String? _settingsProviderOrNull(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.appViewProvider;
    } catch (_) {
      log.d('SettingsCubit not found for public provider fallback');
      return null;
    }
  }

  String _publicProfileLocation(GoRouterState state) {
    final actor = Uri.decodeComponent(state.pathParameters['actor'] ?? '').trim();
    final encodedActor = Uri.encodeComponent(actor);
    final provider = state.uri.queryParameters['provider'];
    final providerQuery = provider == null ? '' : '?provider=${Uri.encodeQueryComponent(provider)}';
    return '/profile/$encodedActor$providerQuery';
  }

  String? _publicHomeLocationFromQuery(GoRouterState state) {
    final rawLocation = state.uri.queryParameters['publicHome']?.trim();
    if (rawLocation == null || rawLocation.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(rawLocation);
    final segments = uri?.pathSegments;
    if (segments == null || segments.length != 3 || segments.first != 'public') {
      return null;
    }

    final routeState = PublicRouteState.parse(provider: segments[1], tab: segments[2]);
    return routeState.location;
  }

  Widget _buildTopicRoute(BuildContext context, {required String topic, required String? provider}) {
    final providerContext = PublicProviderContext.fromRoute(
      queryProvider: provider,
      fallbackProvider: _settingsProviderOrNull(context),
    );

    Widget screenWithRepository(SearchRepository repository, {String? publicProviderKey}) {
      return BlocProvider(
        key: ValueKey('topic-$topic-${publicProviderKey ?? 'authenticated'}'),
        create: (_) => TopicCubit(searchRepository: repository, topic: topic),
        child: TopicScreen(topic: topic, publicProviderKey: publicProviderKey),
      );
    }

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
    );
  }

  PostThreadRepository _authenticatedPostThreadRepository(BuildContext context, String providerKey) {
    return PostThreadRepository(
      bluesky: context.read<Bluesky>(),
      database: context.read<AppDatabase>(),
      accountDid: context.read<String>(),
      moderationService: _moderationServiceOrNull(context),
      appViewProvider: providerKey,
      onUnauthorized: onUnauthorized,
    );
  }

  ModerationService? _moderationServiceOrNull(BuildContext context) {
    try {
      return context.read<ModerationService>();
    } catch (error, stackTrace) {
      log.d('ModerationService not found for provider-scoped route', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Widget _buildProfileConnectionsRoute(BuildContext context, GoRouterState state, String actor) {
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

  NotificationDomainService? _readNotificationDomainService(BuildContext context) {
    try {
      return context.read<NotificationDomainService>();
    } catch (error, stackTrace) {
      log.d('NotificationDomainService not found for route provider setup', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Widget _buildDevToolsRoute(BuildContext context, GoRouterState state) {
    atp.ATProto atproto;
    try {
      atproto = context.read<Bluesky>().atproto;
    } catch (_) {
      final providerKey = context.read<SettingsCubit>().state.appViewProvider;
      final provider = AppViewProviders.descriptorForSetting(providerKey);
      atproto = atp.ATProto.anonymous(
        service: provider.publicBaseUrl.host,
        getClient: XrpcNetworkInterceptor.wrapGetClient(),
        postClient: XrpcNetworkInterceptor.wrapPostClient(),
      );
    }

    return BlocProvider(
      create: (_) => DevToolsCubit(atproto: atproto),
      child: DevToolsScreen(initialQuery: state.uri.queryParameters['query']),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((state) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
