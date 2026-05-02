import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/background/notification_background_worker.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';

void main() {
  group('Notification background worker harness', () {
    test('reconcile task returns true when reconcile succeeds', () async {
      var called = 0;

      final result = await runNotificationReconcileTask(
        reconcile: ({int limit = 50}) async {
          called += 1;
          return 1;
        },
      );

      expect(result, isTrue);
      expect(called, 1);
    });

    test('reconcile task returns false when reconcile throws', () async {
      final result = await runNotificationReconcileTask(
        reconcile: ({int limit = 50}) async {
          throw Exception('boom');
        },
      );

      expect(result, isFalse);
    });

    test('push payload task delegates to provided processor', () async {
      Map<String, String>? capturedPayload;

      final result = await runNotificationPushPayloadTask(
        payload: const {'senderDid': 'did:plc:sender'},
        processPayload: (payload) async {
          capturedPayload = payload;
          return NotificationPushProcessingOutcome.processed;
        },
      );

      expect(capturedPayload, const {'senderDid': 'did:plc:sender'});
      expect(result, NotificationPushProcessingOutcome.processed);
    });
  });
}
