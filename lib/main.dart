import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final authRepository = AuthRepository(database: database);
  final restoredSession = await authRepository.restoreSession();
  final authBloc = AuthBloc(
    authRepository: authRepository,
    initialState: restoredSession != null
        ? AuthState.authenticated(restoredSession)
        : const AuthState.unauthenticated(),
  );

  final settingsCubit = SettingsCubit(database: database);
  await settingsCubit.loadSettings();

  runApp(LazuriteApp(authBloc: authBloc, database: database, settingsCubit: settingsCubit));
}

class LazuriteApp extends StatelessWidget {
  const LazuriteApp({super.key, required this.authBloc, required this.database, required this.settingsCubit});

  final AuthBloc authBloc;
  final AppDatabase database;
  final SettingsCubit settingsCubit;

  Bluesky? _createBluesky(AuthState state) {
    if (!state.isAuthenticated || state.tokens == null) {
      return null;
    }

    final tokens = state.tokens!;
    final service = tokens.service ?? 'bsky.social';

    if (tokens.usesOAuth) {
      if (tokens.dpopPublicKey == null || tokens.dpopPrivateKey == null || tokens.refreshToken == null) {
        return null;
      }

      final oauthSession = atp_core.restoreOAuthSession(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken!,
        dPoPNonce: tokens.dpopNonce,
        publicKey: tokens.dpopPublicKey!,
        privateKey: tokens.dpopPrivateKey!,
      );
      return Bluesky.fromOAuthSession(oauthSession, service: service);
    }

    if (tokens.refreshToken == null) {
      return null;
    }

    final session = atp_core.Session(
      did: tokens.did,
      handle: tokens.handle,
      accessJwt: tokens.accessToken,
      refreshJwt: tokens.refreshToken!,
    );
    return Bluesky.fromSession(session, service: service);
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(authBloc: authBloc).router;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: settingsCubit),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final bluesky = _createBluesky(authState);

          return MultiBlocProvider(
            providers: [
              if (bluesky != null) ...[
                BlocProvider(
                  create: (_) => ProfileBloc(
                    profileRepository: ProfileRepository(database: database, bluesky: bluesky),
                  ),
                ),
                BlocProvider(
                  create: (_) => FeedBloc(feedRepository: FeedRepository(bluesky: bluesky)),
                ),
              ],
            ],
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final themeMode = settingsState.useSystemTheme
                    ? ThemeMode.system
                    : (settingsState.themeVariant == AppThemeVariant.light ? ThemeMode.light : ThemeMode.dark);

                final lightTheme = AppTheme.getTheme(settingsState.themePalette, AppThemeVariant.light);
                final darkTheme = AppTheme.getTheme(settingsState.themePalette, AppThemeVariant.dark);

                return MaterialApp.router(
                  title: 'Lazurite',
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeMode,
                  routerConfig: router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
