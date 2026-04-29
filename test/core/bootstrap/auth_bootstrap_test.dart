import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/bootstrap/auth_bootstrap.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('bootstrapAuthDependencies', () {
    test('loads settings before creating and restoring auth repository', () async {
      final callOrder = <String>[];
      final authRepository = MockAuthRepository();
      const restoredSession = AuthTokens(accessToken: 'token', did: 'did:plc:test', handle: 'user.bsky.social');

      final result = await bootstrapAuthDependencies(
        loadSettings: () async {
          callOrder.add('loadSettings');
        },
        createAuthRepository: () {
          callOrder.add('createAuthRepository');
          return authRepository;
        },
        restoreSession: (repository) async {
          expect(repository, same(authRepository));
          callOrder.add('restoreSession');
          return restoredSession;
        },
      );

      expect(callOrder, equals(<String>['loadSettings', 'createAuthRepository', 'restoreSession']));
      expect(result.authRepository, same(authRepository));
      expect(result.restoredSession, same(restoredSession));
    });
  });
}
