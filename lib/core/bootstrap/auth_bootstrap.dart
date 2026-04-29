import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

class AuthBootstrapResult {
  const AuthBootstrapResult({required this.authRepository, required this.restoredSession});

  final AuthRepository authRepository;
  final AuthTokens? restoredSession;
}

Future<AuthBootstrapResult> bootstrapAuthDependencies({
  required Future<void> Function() loadSettings,
  required AuthRepository Function() createAuthRepository,
  required Future<AuthTokens?> Function(AuthRepository authRepository) restoreSession,
}) async {
  await loadSettings();
  final authRepository = createAuthRepository();
  final restoredSession = await restoreSession(authRepository);
  return AuthBootstrapResult(authRepository: authRepository, restoredSession: restoredSession);
}
