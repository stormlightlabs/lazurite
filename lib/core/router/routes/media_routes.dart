import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_screen.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_screen.dart';

/// Builds full-screen media viewer routes that sit above the app shells.
///
/// These routes intentionally parse arguments from either [GoRouter] `extra`
/// or a URL payload so image/video viewers survive route restoration.
List<RouteBase> buildMediaRoutes({required GlobalKey<NavigatorState> rootNavigatorKey}) {
  return [
    GoRoute(
      path: '/images',
      parentNavigatorKey: rootNavigatorKey,
      redirect: (context, state) {
        if (ImageViewerRouteArgs.tryParse(state.extra, state.uri) != null) {
          return null;
        }
        log.w('Image viewer route opened without valid route arguments; redirecting home. uri=${state.uri}');
        return '/';
      },
      pageBuilder: (context, state) {
        final args = ImageViewerRouteArgs.tryParse(state.extra, state.uri)!;
        return buildAppRoutePage(context, state, ImageViewerScreen(args: args));
      },
    ),
    GoRoute(
      path: '/video',
      parentNavigatorKey: rootNavigatorKey,
      redirect: (context, state) {
        if (VideoPlayerRouteArgs.tryParse(state.extra, state.uri) != null) {
          return null;
        }
        log.w('Video player route opened without valid route arguments; redirecting home. uri=${state.uri}');
        return '/';
      },
      pageBuilder: (context, state) {
        final args = VideoPlayerRouteArgs.tryParse(state.extra, state.uri)!;
        return buildAppRoutePage(context, state, VideoPlayerScreen(args: args));
      },
    ),
  ];
}
