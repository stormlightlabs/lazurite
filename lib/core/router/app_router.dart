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
import 'package:lazurite/features/moderation/presentation/screens/labeler_detail_screen.dart';
import 'package:lazurite/features/moderation/presentation/screens/moderation_settings_screen.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
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
  final GlobalKey<NavigatorState> _notificationsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'notifications');
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
  List<GlobalKey<NavigatorState>> get _branchNavigatorKeys => [
    _homeNavigatorKey,
    _searchNavigatorKey,
    _notificationsNavigatorKey,
    _profileNavigatorKey,
  ];

  Page<dynamic> _page(BuildContext context, GoRouterState state, Widget child) =>
      buildAppRoutePage(context: context, state: state, child: child);

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
        OAuthCallbackScreen.routePath,
        OAuthCallbackScreen.compatibilityRoutePath,
      };
      final isLoggingIn = path == '/login';
      final isReauthLogin = state.uri.queryParameters['reauth'] == '1';
      final isPublicPath = publicPaths.contains(path);

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
          return _page(
            context,
            state,
            LoginScreen(initialHandle: hasInitialHandle ? initialHandle : null, autoStartOAuth: autoStartOAuth),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _page(context, state, const SettingsScreen()),
        routes: [
          GoRoute(
            path: 'moderation',
            pageBuilder: (context, state) => _page(context, state, const ModerationSettingsScreen()),
            routes: [
              GoRoute(
                path: 'detail',
                pageBuilder: (context, state) =>
                    _page(context, state, LabelerDetailScreen(did: state.uri.queryParameters['did'] ?? '')),
              ),
            ],
          ),
          GoRoute(path: 'about', pageBuilder: (context, state) => _page(context, state, const AboutScreen())),
          GoRoute(path: 'logs', pageBuilder: (context, state) => _page(context, state, const LogsScreen())),
          GoRoute(
            path: 'clean-follows',
            pageBuilder: (context, state) => _page(
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
            pageBuilder: (context, state) => _page(context, state, _buildDevToolsRoute(context, state)),
          ),
          GoRoute(
            path: 'video-limits',
            pageBuilder: (context, state) => _page(
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
        pageBuilder: (context, state) => _page(context, state, OAuthCallbackScreen(callbackUri: state.uri)),
      ),
      GoRoute(
        path: OAuthCallbackScreen.compatibilityRoutePath,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _page(context, state, OAuthCallbackScreen(callbackUri: state.uri)),
      ),
      GoRoute(path: '/terms', pageBuilder: (context, state) => _page(context, state, const TermsOfServiceScreen())),
      GoRoute(path: '/privacy', pageBuilder: (context, state) => _page(context, state, const PrivacyPolicyScreen())),
      GoRoute(path: '/notifications', redirect: (_, _) => '/alerts'),
      GoRoute(path: '/messages', redirect: (_, _) => '/alerts/messages'),
      GoRoute(
        path: '/compose',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = ComposeRouteArgs.parseExtra(state.extra);
          return _page(
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
          return _page(context, state, PostThreadScreen(postUri: Uri.decodeComponent(uri)));
        },
      ),
      GoRoute(
        path: '/hashtag',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final normalizedTag = normalizeHashtag(state.uri.queryParameters['tag'] ?? '');
          return _page(
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
          return _page(
            context,
            state,
            BlocProvider(
              key: ValueKey('topic-$topic'),
              create: (_) => TopicCubit(searchRepository: context.read<SearchRepository>(), topic: topic),
              child: TopicScreen(topic: topic),
            ),
          );
        },
      ),
      GoRoute(
        path: '/images',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as ImageViewerRouteArgs;
          return _page(context, state, ImageViewerScreen(args: args));
        },
      ),
      GoRoute(
        path: '/video',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as VideoPlayerRouteArgs;
          return _page(context, state, VideoPlayerScreen(args: args));
        },
      ),
      GoRoute(
        path: '/bookmarks',
        pageBuilder: (context, state) => _page(
          context,
          state,
          SavedPostsScreen(accountDid: context.read<String>(), initialTab: SavedPostsInitialTab.bookmarks),
        ),
      ),
      GoRoute(
        path: '/liked',
        pageBuilder: (context, state) => _page(
          context,
          state,
          SavedPostsScreen(accountDid: context.read<String>(), initialTab: SavedPostsInitialTab.liked),
        ),
      ),
      GoRoute(path: '/lists', pageBuilder: (context, state) => _page(context, state, const MyListsScreen())),
      GoRoute(
        path: '/create-starter-pack',
        pageBuilder: (context, state) {
          return _page(
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
          return _page(context, state, StarterPackDetailScreen(packUri: packUri));
        },
      ),
      GoRoute(
        path: '/starter-packs',
        pageBuilder: (context, state) {
          final actor = state.uri.queryParameters['actor'] ?? '';
          return _page(context, state, ActorStarterPacksScreen(actor: actor));
        },
      ),
      GoRoute(
        path: '/list',
        pageBuilder: (context, state) {
          final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
          final listUri = AtUri.parse(uriStr);
          return _page(context, state, ListDetailScreen(listUri: listUri));
        },
        routes: [
          GoRoute(
            path: 'members',
            pageBuilder: (context, state) {
              final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
              final listUri = AtUri.parse(uriStr);
              return _page(
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
          return _page(
            context,
            state,
            BlocProvider(
              create: (_) => ProfileContextCubit(repository: repository, did: did, isOwnProfile: isOwnProfile),
              child: ProfileContextScreen(handle: handle),
            ),
          );
        },
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
                pageBuilder: (context, state) => _page(context, state, const HomeFeedScreen()),
                routes: [
                  GoRoute(
                    path: 'feeds',
                    pageBuilder: (context, state) => _page(context, state, const FeedManagementScreen()),
                  ),
                  GoRoute(
                    path: 'feed',
                    pageBuilder: (context, state) {
                      final encodedUri = state.uri.queryParameters['uri'];
                      final encodedActor = state.uri.queryParameters['actor'];
                      final encodedRkey = state.uri.queryParameters['rkey'];

                      AtUri? feedUri;
                      if (encodedUri != null && encodedUri.trim().isNotEmpty) {
                        final rawUri = Uri.decodeComponent(encodedUri);
                        feedUri = AtUri.parse(rawUri);
                      }

                      final actor = encodedActor == null ? null : Uri.decodeComponent(encodedActor);
                      final rkey = encodedRkey == null ? null : Uri.decodeComponent(encodedRkey);
                      return _page(context, state, FeedDetailScreen(feedUri: feedUri, actor: actor, rkey: rkey));
                    },
                  ),
                  GoRoute(
                    path: 'trending',
                    pageBuilder: (context, state) => _page(context, state, const TrendingScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(path: '/search', pageBuilder: (context, state) => _page(context, state, const SearchScreen())),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _notificationsNavigatorKey,
            routes: [
              GoRoute(
                path: '/alerts',
                pageBuilder: (context, state) =>
                    _page(context, state, _buildAlertsRoute(context, const AlertsScreen())),
                routes: [
                  GoRoute(
                    path: 'messages',
                    pageBuilder: (context, state) => _page(
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
                          return _page(
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
                    pageBuilder: (context, state) => _page(
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
                pageBuilder: (context, state) => _page(context, state, const ProfileScreen(actor: 'me')),
                routes: [
                  GoRoute(
                    path: 'connections',
                    pageBuilder: (context, state) =>
                        _page(context, state, _buildProfileConnectionsRoute(context, state, context.read<String>())),
                  ),
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => _page(context, state, const ProfileEditScreen()),
                  ),
                ],
              ),
              GoRoute(
                path: '/profile/:actor',
                redirect: (_, state) {
                  final actor = (state.pathParameters['actor'] ?? '').trim().toLowerCase();
                  if (actor == 'me') {
                    return '/profile/me';
                  }
                  return null;
                },
                pageBuilder: (context, state) => _page(
                  context,
                  state,
                  ProfileScreen(actor: Uri.decodeComponent(state.pathParameters['actor'] ?? ''), showBackButton: true),
                ),
                routes: [
                  GoRoute(
                    path: 'connections',
                    pageBuilder: (context, state) => _page(
                      context,
                      state,
                      _buildProfileConnectionsRoute(
                        context,
                        state,
                        Uri.decodeComponent(state.pathParameters['actor'] ?? ''),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'search-posts',
                    pageBuilder: (context, state) {
                      final actor = Uri.decodeComponent(state.pathParameters['actor'] ?? '');
                      return _page(
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
    } catch (_) {
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
