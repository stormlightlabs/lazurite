import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';

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

  runApp(LazuriteApp(authBloc: authBloc, database: database));
}

class LazuriteApp extends StatelessWidget {
  const LazuriteApp({super.key, required this.authBloc, required this.database});

  final AuthBloc authBloc;
  final AppDatabase database;

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

    return BlocProvider.value(
      value: authBloc,
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
            child: MaterialApp.router(
              title: 'Lazurite',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }
}
