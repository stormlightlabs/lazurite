import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart' as atp;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/core/router/app_redirect_policy.dart';
import 'package:lazurite/core/router/content_route_factory.dart';
import 'package:lazurite/core/router/routes/authenticated_shell_routes.dart';
import 'package:lazurite/core/router/routes/media_routes.dart';
import 'package:lazurite/core/router/routes/root_routes.dart';
import 'package:lazurite/core/router/routes/unauthenticated_shell_routes.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';
import 'package:lazurite/features/devtools/presentation/dev_tools_screen.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';

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
  final GlobalKey<NavigatorState> _unauthHomeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'unauth-home');
  final GlobalKey<NavigatorState> _unauthExplorerNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'unauth-explorer',
  );
  final GlobalKey<NavigatorState> _unauthSettingsNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'unauth-settings',
  );
  final GlobalKey<NavigatorState> _unauthLoginNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'unauth-login');
  ContentRouteFactory get _contentRouteFactory =>
      ContentRouteFactory(authBloc: authBloc, onUnauthorized: onUnauthorized);

  List<GlobalKey<NavigatorState>> get _branchNavigatorKeys => [
    _homeNavigatorKey,
    _searchNavigatorKey,
    _atExplorerNavigatorKey,
    _notificationsNavigatorKey,
    _profileNavigatorKey,
  ];

  GoRouter get router => GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    observers: navigatorObserver != null ? [navigatorObserver!] : null,
    redirect: AppRedirectPolicy(authBloc: authBloc).redirect,
    routes: [
      buildUnauthenticatedShellRoute(
        authBloc: authBloc,
        homeNavigatorKey: _unauthHomeNavigatorKey,
        explorerNavigatorKey: _unauthExplorerNavigatorKey,
        settingsNavigatorKey: _unauthSettingsNavigatorKey,
        loginNavigatorKey: _unauthLoginNavigatorKey,
        contentRouteFactory: _contentRouteFactory,
        onUnauthorized: onUnauthorized,
        buildDevToolsRoute: _buildDevToolsRoute,
      ),
      ...buildRootRoutes(rootNavigatorKey: _rootNavigatorKey, onUnauthorized: onUnauthorized),
      ...buildMediaRoutes(rootNavigatorKey: _rootNavigatorKey),
      buildAuthenticatedShellRoute(
        branchNavigatorKeys: _branchNavigatorKeys,
        contentRouteFactory: _contentRouteFactory,
        buildAlertsRoute: _buildAlertsRoute,
        buildDevToolsRoute: _buildDevToolsRoute,
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
