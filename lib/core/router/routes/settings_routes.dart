import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/presentation/screens/labeler_detail_screen.dart';
import 'package:lazurite/features/logs/presentation/logs_screen.dart';
import 'package:lazurite/features/moderation/presentation/screens/moderation_settings_screen.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';
import 'package:lazurite/features/profile/presentation/follow_audit_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/cubit/video_upload_limits_cubit.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';
import 'package:lazurite/features/settings/presentation/about_screen.dart';
import 'package:lazurite/features/settings/presentation/privacy_policy_screen.dart';
import 'package:lazurite/features/settings/presentation/settings_account_screen.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';
import 'package:lazurite/features/settings/presentation/terms_of_service_screen.dart';
import 'package:lazurite/features/settings/presentation/video_upload_limits_screen.dart';

/// Builds settings and legal-document routes.
///
/// The settings tree is shared by authenticated users and the unauthenticated
/// shell. Authenticated-only child screens read account-scoped dependencies from
/// the route context when they are opened; public settings children stay simple
/// screen routes. Keeping the group here lets [AppRouter] compose settings as a
/// route group without also owning every settings screen dependency.
List<RouteBase> buildSettingsRoutes({required Future<AuthTokens?> Function()? onUnauthorized}) {
  return [
    GoRoute(
      path: AppRoutePath.settings.path,
      pageBuilder: (context, state) => buildAppRoutePage(context, state, const SettingsScreen()),
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
          path: AppRoutePath.settingsAbout.childPath,
          pageBuilder: (context, state) => buildAppRoutePage(context, state, const AboutScreen()),
        ),
        GoRoute(
          path: AppRoutePath.settingsLogs.childPath,
          pageBuilder: (context, state) => buildAppRoutePage(context, state, const LogsScreen()),
        ),
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
                  onUnauthorized: onUnauthorized,
                ),
                ownDid: context.read<String>(),
              ),
              child: const FollowAuditScreen(),
            ),
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
      path: AppRoutePath.terms.path,
      pageBuilder: (context, state) => buildAppRoutePage(context, state, const TermsOfServiceScreen()),
    ),
    GoRoute(
      path: AppRoutePath.privacy.path,
      pageBuilder: (context, state) => buildAppRoutePage(context, state, const PrivacyPolicyScreen()),
    ),
  ];
}
