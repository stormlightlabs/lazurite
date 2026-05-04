import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/data/firebase_push_token_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  const grantedSettings = NotificationSettings(
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.enabled,
    authorizationStatus: AuthorizationStatus.authorized,
    badge: AppleNotificationSetting.enabled,
    carPlay: AppleNotificationSetting.notSupported,
    lockScreen: AppleNotificationSetting.enabled,
    notificationCenter: AppleNotificationSetting.enabled,
    showPreviews: AppleShowPreviewSetting.always,
    timeSensitive: AppleNotificationSetting.notSupported,
    criticalAlert: AppleNotificationSetting.notSupported,
    sound: AppleNotificationSetting.enabled,
    providesAppNotificationSettings: AppleNotificationSetting.notSupported,
  );

  group('FirebasePushTokenProvider', () {
    late MockFirebaseMessaging messaging;
    late StreamController<String> tokenRefreshController;

    setUp(() {
      messaging = MockFirebaseMessaging();
      tokenRefreshController = StreamController<String>.broadcast();
      when(() => messaging.onTokenRefresh).thenAnswer((_) => tokenRefreshController.stream);
      when(
        () => messaging.requestPermission(
          alert: any(named: 'alert'),
          badge: any(named: 'badge'),
          sound: any(named: 'sound'),
          provisional: any(named: 'provisional'),
        ),
      ).thenAnswer((_) async => grantedSettings);
      when(() => messaging.setAutoInitEnabled(any())).thenAnswer((_) async {});
    });

    tearDown(() async {
      await tokenRefreshController.close();
    });

    test('waits for APNs token availability on Apple platforms before requesting FCM token', () async {
      var apnsCalls = 0;
      when(() => messaging.getAPNSToken()).thenAnswer((_) async {
        apnsCalls += 1;
        return apnsCalls >= 2 ? 'apns-token' : null;
      });
      when(() => messaging.getToken(vapidKey: any(named: 'vapidKey'))).thenAnswer((_) async => 'fcm-token');

      final provider = FirebasePushTokenProvider(
        messaging: messaging,
        isApplePlatform: () => true,
        apnsTokenRetryAttempts: 3,
        apnsTokenRetryDelay: Duration.zero,
        delayFn: (_) async {},
      );
      addTearDown(provider.dispose);

      final token = await provider.getToken();

      expect(token, 'fcm-token');
      expect(apnsCalls, greaterThanOrEqualTo(2));
      verify(() => messaging.setAutoInitEnabled(true)).called(1);
    });

    test('does not query APNs token on non-Apple platforms', () async {
      when(() => messaging.getToken(vapidKey: any(named: 'vapidKey'))).thenAnswer((_) async => 'fcm-token');

      final provider = FirebasePushTokenProvider(
        messaging: messaging,
        isApplePlatform: () => false,
        apnsTokenRetryAttempts: 1,
      );
      addTearDown(provider.dispose);

      final token = await provider.getToken();

      expect(token, 'fcm-token');
      verifyNever(() => messaging.getAPNSToken());
    });

    test('forwards non-empty refreshed tokens', () async {
      when(() => messaging.getAPNSToken()).thenAnswer((_) async => 'apns-token');
      when(() => messaging.getToken(vapidKey: any(named: 'vapidKey'))).thenAnswer((_) async => 'fcm-token');

      final provider = FirebasePushTokenProvider(
        messaging: messaging,
        isApplePlatform: () => true,
        apnsTokenRetryAttempts: 1,
      );
      addTearDown(provider.dispose);

      await provider.initialize();
      final firstTokenFuture = provider.onTokenRefresh.first;
      tokenRefreshController.add('  ');
      tokenRefreshController.add('new-token');
      final emitted = await firstTokenFuture;
      expect(emitted, 'new-token');
    });
  });
}
