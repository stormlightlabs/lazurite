import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final authRepository = AuthRepository(database: database);
  final authBloc = AuthBloc(authRepository: authRepository);

  authBloc.add(const CheckSessionRequested());

  runApp(LazuriteApp(authBloc: authBloc));
}

class LazuriteApp extends StatelessWidget {
  const LazuriteApp({super.key, required this.authBloc});
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(authBloc: authBloc).router;

    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'Lazurite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
        routerConfig: router,
      ),
    );
  }
}
