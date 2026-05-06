import 'dart:async';

import 'package:atproto_core/atproto_core.dart'
    show HttpMethod, HttpStatus, RateLimit, UnauthorizedException, XRPCError, XRPCRequest, XRPCResponse;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/push_registration_service.dart';
import 'package:lazurite/features/notifications/domain/push_token_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

class FakePushTokenProvider implements PushTokenProvider {
  String? token;
  final controller = StreamController<String>.broadcast();

  @override
  Future<void> dispose() async {
    await controller.close();
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> initialize() async {}

  @override
  Stream<String> get onTokenRefresh => controller.stream;
}

void main() {
  late FakePushTokenProvider tokenProvider;
  late MockNotificationRepository accountARepository;
  late MockNotificationRepository accountBRepository;

  const accountATokens = AuthTokens(
    accessToken: 'access-a',
    refreshToken: 'refresh-a',
    did: 'did:plc:account-a',
    handle: 'account-a.bsky.social',
    service: 'bsky.social',
  );
  const accountBTokens = AuthTokens(
    accessToken: 'access-b',
    refreshToken: 'refresh-b',
    did: 'did:plc:account-b',
    handle: 'account-b.bsky.social',
    service: 'bsky.social',
  );
  const refreshedAccountATokens = AuthTokens(
    accessToken: 'fresh-access-a',
    refreshToken: 'fresh-refresh-a',
    did: 'did:plc:account-a',
    handle: 'account-a.bsky.social',
    service: 'bsky.social',
  );

  setUp(() {
    tokenProvider = FakePushTokenProvider();
    accountARepository = MockNotificationRepository();
    accountBRepository = MockNotificationRepository();

    when(
      () => accountARepository.registerPush(
        token: any(named: 'token'),
        appId: any(named: 'appId'),
        platform: any(named: 'platform'),
        ageRestricted: any(named: 'ageRestricted'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => accountARepository.unregisterPush(
        token: any(named: 'token'),
        appId: any(named: 'appId'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => accountBRepository.registerPush(
        token: any(named: 'token'),
        appId: any(named: 'appId'),
        platform: any(named: 'platform'),
        ageRestricted: any(named: 'ageRestricted'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => accountBRepository.unregisterPush(
        token: any(named: 'token'),
        appId: any(named: 'appId'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(NotificationPushPlatform.android);
  });

  NotificationRepository repositoryFactory(AuthTokens tokens) {
    if (tokens.did == accountATokens.did) {
      return accountARepository;
    }
    return accountBRepository;
  }

  PushRegistrationService buildService({
    int maxAttempts = 4,
    Duration initialBackoff = const Duration(milliseconds: 1),
    PushAuthRecoveryCallback? authRecovery,
  }) {
    return PushRegistrationService(
      tokenProvider: tokenProvider,
      notificationRepositoryFactory: repositoryFactory,
      maxAttempts: maxAttempts,
      initialBackoff: initialBackoff,
      delayFn: (_) async {},
      isPushPlatformSupported: () => true,
      authRecovery: authRecovery,
    );
  }

  group('PushRegistrationService', () {
    test('registers push token on startup for authenticated account', () async {
      tokenProvider.token = 'token-a';
      final service = buildService();
      addTearDown(service.dispose);

      await service.start(initialTokens: accountATokens);

      verify(
        () => accountARepository.registerPush(
          token: 'token-a',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
          ageRestricted: null,
        ),
      ).called(1);
      verifyNever(
        () => accountARepository.unregisterPush(
          token: any(named: 'token'),
          appId: any(named: 'appId'),
          platform: any(named: 'platform'),
        ),
      );
    });

    test('unregisters old account and registers new account on switch', () async {
      tokenProvider.token = 'shared-token';
      final service = buildService();
      addTearDown(service.dispose);

      await service.start(initialTokens: accountATokens);
      await service.updateSession(accountBTokens);

      verify(
        () => accountARepository.unregisterPush(
          token: 'shared-token',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
        ),
      ).called(1);
      verify(
        () => accountBRepository.registerPush(
          token: 'shared-token',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
          ageRestricted: null,
        ),
      ).called(1);
    });

    test('unregisters push token on logout', () async {
      tokenProvider.token = 'token-a';
      final service = buildService();
      addTearDown(service.dispose);

      await service.start(initialTokens: accountATokens);
      await service.updateSession(null);

      verify(
        () => accountARepository.unregisterPush(
          token: 'token-a',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
        ),
      ).called(1);
    });

    test('retries registration failures with backoff attempts', () async {
      tokenProvider.token = 'token-a';
      final service = buildService(maxAttempts: 3);
      addTearDown(service.dispose);

      var attempts = 0;
      when(
        () => accountARepository.registerPush(
          token: any(named: 'token'),
          appId: any(named: 'appId'),
          platform: any(named: 'platform'),
          ageRestricted: any(named: 'ageRestricted'),
        ),
      ).thenAnswer((_) async {
        attempts += 1;
        if (attempts < 3) {
          throw Exception('temporary failure');
        }
      });

      await service.start(initialTokens: accountATokens);

      expect(attempts, 3);
    });

    test('refreshes session and retries registration after unauthorized response', () async {
      tokenProvider.token = 'token-a';
      final refreshedRepository = MockNotificationRepository();
      when(
        () => refreshedRepository.registerPush(
          token: any(named: 'token'),
          appId: any(named: 'appId'),
          platform: any(named: 'platform'),
          ageRestricted: any(named: 'ageRestricted'),
        ),
      ).thenAnswer((_) async {});

      NotificationRepository factory(AuthTokens tokens) {
        if (tokens.accessToken == refreshedAccountATokens.accessToken) {
          return refreshedRepository;
        }
        return accountARepository;
      }

      var recoveryCalls = 0;
      final service = PushRegistrationService(
        tokenProvider: tokenProvider,
        notificationRepositoryFactory: factory,
        initialBackoff: const Duration(milliseconds: 1),
        delayFn: (_) async {},
        isPushPlatformSupported: () => true,
        authRecovery: () async {
          recoveryCalls += 1;
          return refreshedAccountATokens;
        },
      );
      addTearDown(service.dispose);

      when(
        () => accountARepository.registerPush(
          token: any(named: 'token'),
          appId: any(named: 'appId'),
          platform: any(named: 'platform'),
          ageRestricted: any(named: 'ageRestricted'),
        ),
      ).thenThrow(_unauthorizedException());

      await service.start(initialTokens: accountATokens);

      expect(recoveryCalls, 1);
      verify(
        () => accountARepository.registerPush(
          token: 'token-a',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
          ageRestricted: null,
        ),
      ).called(1);
      verify(
        () => refreshedRepository.registerPush(
          token: 'token-a',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
          ageRestricted: null,
        ),
      ).called(1);
    });

    test('re-registers on token refresh and unregisters old token first', () async {
      tokenProvider.token = 'token-a';
      final service = buildService();
      addTearDown(service.dispose);

      await service.start(initialTokens: accountATokens);
      tokenProvider.controller.add('token-b');
      await Future<void>.delayed(Duration.zero);

      verify(
        () => accountARepository.unregisterPush(
          token: 'token-a',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
        ),
      ).called(1);
      verify(
        () => accountARepository.registerPush(
          token: 'token-b',
          appId: 'org.stormlightlabs.lazurite',
          platform: any(named: 'platform'),
          ageRestricted: null,
        ),
      ).called(1);
    });
  });
}

UnauthorizedException _unauthorizedException() {
  return UnauthorizedException(
    XRPCResponse<XRPCError>(
      headers: const {},
      status: HttpStatus.unauthorized,
      request: XRPCRequest(
        method: HttpMethod.post,
        url: Uri.parse('https://example.com/xrpc/app.bsky.notification.registerPush'),
      ),
      rateLimit: RateLimit.unlimited(),
      data: const XRPCError(error: 'Unauthorized', message: '"exp" claim timestamp check failed'),
    ),
  );
}
